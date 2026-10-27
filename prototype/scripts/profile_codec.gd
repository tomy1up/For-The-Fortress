extends RefCounted
## DPAPI CurrentUser : chiffrement et intégrité gérés par Windows, sans clé dans le jeu.
const MAGIC: String = "FTF-DPAPI-1\n"
const POWERSHELL: String = """$ErrorActionPreference='Stop'
try {
 Add-Type -AssemblyName System.Security
 $line=[Console]::ReadLine()
 $bytes=[Convert]::FromBase64String($line.Substring(2))
 $entropy=[Text.Encoding]::UTF8.GetBytes('ForTheFortress.Save.v1')
 $scope=[Security.Cryptography.DataProtectionScope]::CurrentUser
 if($line.StartsWith('P:')) {$result=[Security.Cryptography.ProtectedData]::Protect($bytes,$entropy,$scope)}
 elseif($line.StartsWith('U:')) {$result=[Security.Cryptography.ProtectedData]::Unprotect($bytes,$entropy,$scope)}
 else {throw 'Invalid operation'}
 [Console]::WriteLine('OK:'+ [Convert]::ToBase64String($result))
 exit 0
} catch { [Console]::WriteLine('FAIL'); exit 1 }
"""
static var cache: Dictionary = {}

static func _signature(bytes: PackedByteArray) -> String:
	var hash := HashingContext.new();hash.start(HashingContext.HASH_SHA256);hash.update(bytes)
	return hash.finish().hex_encode()

static func _invoke(operation: String, bytes: PackedByteArray) -> PackedByteArray:
	if OS.get_name() != "Windows": return PackedByteArray()
	var shell: String = OS.get_environment("SystemRoot").path_join("System32/WindowsPowerShell/v1.0/powershell.exe")
	if not FileAccess.file_exists(shell): return PackedByteArray()
	var pipe: Dictionary = OS.execute_with_pipe(shell,["-NoLogo","-NoProfile","-NonInteractive","-WindowStyle","Hidden","-EncodedCommand",Marshalls.raw_to_base64(POWERSHELL.to_utf16_buffer())],true)
	if pipe.is_empty(): return PackedByteArray()
	var guard: Dictionary = {"done":false,"mutex":Mutex.new()}
	var watchdog := Thread.new()
	watchdog.start(func():
		var start: int = Time.get_ticks_msec()
		while Time.get_ticks_msec()-start < 5000:
			guard.mutex.lock();var done: bool = guard.done;guard.mutex.unlock()
			if done: return
			OS.delay_msec(10)
		if OS.is_process_running(pipe.pid): OS.kill(pipe.pid)
	)
	# Données transmises par tube, jamais en arguments de commande ni dans un fichier clair.
	pipe.stdio.store_line(operation+":"+Marshalls.raw_to_base64(bytes));pipe.stdio.flush()
	var response: String = pipe.stdio.get_line().strip_edges()
	guard.mutex.lock();guard.done = true;guard.mutex.unlock();watchdog.wait_to_finish()
	pipe.stdio.close();pipe.stderr.close()
	return Marshalls.base64_to_raw(response.trim_prefix("OK:")) if response.begins_with("OK:") else PackedByteArray()

static func encode(data: Dictionary) -> PackedByteArray:
	var text: String = JSON.stringify(data)
	var protected: PackedByteArray = _invoke("P",text.to_utf8_buffer())
	if protected.is_empty(): return PackedByteArray()
	var result: PackedByteArray = MAGIC.to_utf8_buffer();result.append_array(protected)
	if cache.size() >= 128: cache.clear()
	cache[_signature(result)] = JSON.parse_string(text)
	return result

static func decode(bytes: PackedByteArray) -> Variant:
	var header: PackedByteArray = MAGIC.to_utf8_buffer()
	if bytes.size() <= header.size() or bytes.size() > 1048576 or bytes.slice(0,header.size()) != header: return null
	var signature: String = _signature(bytes)
	if cache.has(signature): return cache[signature].duplicate(true)
	var plain: PackedByteArray = _invoke("U",bytes.slice(header.size()))
	if plain.is_empty(): return null
	var parser := JSON.new()
	if parser.parse(plain.get_string_from_utf8()) != OK or not parser.data is Dictionary: return null
	if cache.size() >= 128: cache.clear()
	cache[signature] = parser.data
	return parser.data.duplicate(true)
