"""Lance une commande et tous ses processus enfants sur un bureau Windows caché.

Les fenêtres de jeu ouvertes par les vérifications et les captures n'apparaissent alors
ni à l'écran ni dans la barre des tâches, et ne prennent ni le clavier ni la souris.
Le bureau disparaît à la fin de la commande. Si ce lanceur est interrompu, ses enfants
sont arrêtés avec lui : aucun jeu invisible ne reste en mémoire.

Usage : python prototype/tests/hidden_desktop.py <commande> [arguments...]
"""
import ctypes
import msvcrt
import os
import subprocess
import sys
import uuid
from ctypes import wintypes

MARKER = "FORTRESS_HIDDEN_DESKTOP"
GENERIC_ALL = 0x10000000
CREATE_SUSPENDED = 0x00000004
CREATE_UNICODE_ENVIRONMENT = 0x00000400
CREATE_NO_WINDOW = 0x08000000
STARTF_USESTDHANDLES = 0x00000100
INFINITE = 0xFFFFFFFF
JOB_OBJECT_EXTENDED_LIMIT_INFORMATION = 9
JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE = 0x00002000


class STARTUPINFOW(ctypes.Structure):
    _fields_ = [("cb", wintypes.DWORD), ("lpReserved", wintypes.LPWSTR), ("lpDesktop", wintypes.LPWSTR), ("lpTitle", wintypes.LPWSTR),
                ("dwX", wintypes.DWORD), ("dwY", wintypes.DWORD), ("dwXSize", wintypes.DWORD), ("dwYSize", wintypes.DWORD),
                ("dwXCountChars", wintypes.DWORD), ("dwYCountChars", wintypes.DWORD), ("dwFillAttribute", wintypes.DWORD),
                ("dwFlags", wintypes.DWORD), ("wShowWindow", wintypes.WORD), ("cbReserved2", wintypes.WORD), ("lpReserved2", ctypes.c_void_p),
                ("hStdInput", wintypes.HANDLE), ("hStdOutput", wintypes.HANDLE), ("hStdError", wintypes.HANDLE)]


class PROCESS_INFORMATION(ctypes.Structure):
    _fields_ = [("hProcess", wintypes.HANDLE), ("hThread", wintypes.HANDLE), ("dwProcessId", wintypes.DWORD), ("dwThreadId", wintypes.DWORD)]


class IO_COUNTERS(ctypes.Structure):
    _fields_ = [(name, ctypes.c_ulonglong) for name in ("r", "w", "o", "rb", "wb", "ob")]


class BASIC_LIMITS(ctypes.Structure):
    _fields_ = [("PerProcessUserTimeLimit", ctypes.c_longlong), ("PerJobUserTimeLimit", ctypes.c_longlong), ("LimitFlags", wintypes.DWORD),
                ("MinimumWorkingSetSize", ctypes.c_size_t), ("MaximumWorkingSetSize", ctypes.c_size_t), ("ActiveProcessLimit", wintypes.DWORD),
                ("Affinity", ctypes.c_size_t), ("PriorityClass", wintypes.DWORD), ("SchedulingClass", wintypes.DWORD)]


class EXTENDED_LIMITS(ctypes.Structure):
    _fields_ = [("BasicLimitInformation", BASIC_LIMITS), ("IoInfo", IO_COUNTERS), ("ProcessMemoryLimit", ctypes.c_size_t),
                ("JobMemoryLimit", ctypes.c_size_t), ("PeakProcessMemoryUsed", ctypes.c_size_t), ("PeakJobMemoryUsed", ctypes.c_size_t)]


def on_hidden_desktop() -> bool:
    return os.environ.get(MARKER) == "1"


def _standard_handle(descriptor: int):
    try:
        handle = msvcrt.get_osfhandle(descriptor)
        os.set_handle_inheritable(handle, True)
        return handle
    except OSError:
        return None


def run(command: list[str]) -> int:
    """Exécute `command` sur un nouveau bureau caché et renvoie son code de sortie."""
    kernel = ctypes.WinDLL("kernel32", use_last_error=True)
    user = ctypes.WinDLL("user32", use_last_error=True)
    kernel.CreateJobObjectW.restype = wintypes.HANDLE
    kernel.CreateJobObjectW.argtypes = [ctypes.c_void_p, wintypes.LPCWSTR]
    kernel.SetInformationJobObject.argtypes = [wintypes.HANDLE, ctypes.c_int, ctypes.c_void_p, wintypes.DWORD]
    kernel.AssignProcessToJobObject.argtypes = [wintypes.HANDLE, wintypes.HANDLE]
    kernel.ResumeThread.argtypes = [wintypes.HANDLE]
    kernel.WaitForSingleObject.argtypes = [wintypes.HANDLE, wintypes.DWORD]
    kernel.GetExitCodeProcess.argtypes = [wintypes.HANDLE, ctypes.POINTER(wintypes.DWORD)]
    kernel.CloseHandle.argtypes = [wintypes.HANDLE]
    kernel.TerminateProcess.argtypes = [wintypes.HANDLE, wintypes.UINT]
    kernel.CreateProcessW.argtypes = [wintypes.LPCWSTR, wintypes.LPWSTR, ctypes.c_void_p, ctypes.c_void_p, wintypes.BOOL, wintypes.DWORD,
                                      ctypes.c_void_p, wintypes.LPCWSTR, ctypes.POINTER(STARTUPINFOW), ctypes.POINTER(PROCESS_INFORMATION)]
    user.CreateDesktopW.restype = wintypes.HANDLE
    user.CreateDesktopW.argtypes = [wintypes.LPCWSTR, wintypes.LPCWSTR, ctypes.c_void_p, wintypes.DWORD, wintypes.DWORD, ctypes.c_void_p]
    user.CloseDesktop.argtypes = [wintypes.HANDLE]

    name = "FortressVerify_" + uuid.uuid4().hex[:12]
    desktop = user.CreateDesktopW(name, None, None, 0, GENERIC_ALL, None)
    if not desktop:
        raise ctypes.WinError(ctypes.get_last_error())
    job = kernel.CreateJobObjectW(None, None)
    if not job:
        user.CloseDesktop(desktop)
        raise ctypes.WinError(ctypes.get_last_error())
    process = PROCESS_INFORMATION()
    try:
        limits = EXTENDED_LIMITS()
        limits.BasicLimitInformation.LimitFlags = JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE
        if not kernel.SetInformationJobObject(job, JOB_OBJECT_EXTENDED_LIMIT_INFORMATION, ctypes.byref(limits), ctypes.sizeof(limits)):
            raise ctypes.WinError(ctypes.get_last_error())
        startup = STARTUPINFOW()
        startup.cb = ctypes.sizeof(STARTUPINFOW)
        startup.lpDesktop = "WinSta0\\" + name
        handles = [_standard_handle(descriptor) for descriptor in (0, 1, 2)]
        if handles[1] is not None and handles[2] is not None:
            startup.dwFlags |= STARTF_USESTDHANDLES
            startup.hStdInput, startup.hStdOutput, startup.hStdError = handles
        environment = dict(os.environ)
        environment[MARKER] = "1"
        block = ctypes.create_unicode_buffer("\0".join(f"{key}={value}" for key, value in sorted(environment.items(), key=lambda item: item[0].upper())) + "\0\0")
        line = ctypes.create_unicode_buffer(subprocess.list2cmdline(command))
        if not kernel.CreateProcessW(None, line, None, None, True, CREATE_SUSPENDED | CREATE_UNICODE_ENVIRONMENT | CREATE_NO_WINDOW,
                                     block, os.getcwd(), ctypes.byref(startup), ctypes.byref(process)):
            raise ctypes.WinError(ctypes.get_last_error())
        if not kernel.AssignProcessToJobObject(job, process.hProcess):
            error = ctypes.get_last_error()
            kernel.TerminateProcess(process.hProcess, 1)
            raise ctypes.WinError(error)
        kernel.ResumeThread(process.hThread)
        kernel.WaitForSingleObject(process.hProcess, INFINITE)
        code = wintypes.DWORD()
        kernel.GetExitCodeProcess(process.hProcess, ctypes.byref(code))
        return int(code.value)
    finally:
        if process.hThread:
            kernel.CloseHandle(process.hThread)
        if process.hProcess:
            kernel.CloseHandle(process.hProcess)
        kernel.CloseHandle(job)  # Arrête les enfants encore présents.
        user.CloseDesktop(desktop)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    raise SystemExit(run(sys.argv[1:]))
