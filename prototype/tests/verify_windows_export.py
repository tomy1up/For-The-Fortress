"""Vérifie le contenu, l'architecture et le lancement du ZIP Windows exporté."""
from pathlib import Path
import argparse
import hashlib
import json
import os
import struct
import subprocess
import zipfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('archive',type=Path)
parser.add_argument('--destination',required=True,type=Path)
args=parser.parse_args()
assert os.name=='nt','Ce contrôle lance le binaire Windows sur Windows.'
archive=args.archive.resolve()
destination=args.destination.resolve()
destination.mkdir(parents=True,exist_ok=True)
with zipfile.ZipFile(archive) as z:
    members=[]
    for entry in z.infolist():
        candidate=(destination/entry.filename).resolve()
        assert candidate.is_relative_to(destination),'Chemin ZIP hors dossier de contrôle'
        if not entry.is_dir(): members.append(entry.filename.replace('\\','/'))
    assert len(members)==5,members
    assert len({name.split('/')[0] for name in members})==1
    assert {Path(name).name for name in members}=={'For_the_Fortress.exe','LIRE_MOI.txt','Fiche_essai_joueur.md','LICENCES_GODOT.txt','VERSION.json'}
    z.extractall(destination)
folder=destination/members[0].split('/')[0]
exe=folder/'For_the_Fortress.exe'
manifest=json.loads((folder/'VERSION.json').read_text(encoding='utf-8-sig'))
exe_hash=hashlib.file_digest(exe.open('rb'),'sha256').hexdigest()
assert manifest['executable_sha256']==exe_hash
binary=exe.read_bytes()
assert binary[:2]==b'MZ'
offset=struct.unpack_from('<I',binary,0x3c)[0]
assert binary[offset:offset+4]==b'PE\0\0' and struct.unpack_from('<H',binary,offset+4)[0]==0x8664
assert not list(folder.glob('*.pck')) and not (folder/'project.godot').exists()
assert 'Permission is hereby granted' in (folder/'LICENCES_GODOT.txt').read_text(encoding='utf-8')

startup=subprocess.STARTUPINFO()
startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW
startup.wShowWindow=0
results=[]
cases=[('startup',None,None),('selection','selection',None),('countdown','finished',None),('bonus','bonus',None),
       ('upgrade_comparison','upgrade',None),('specialisation_preview','specialisation',None),
       ('alliance_purchase','purchase','alliance'),('horde_purchase','purchase','horde'),
       ('alliance_synergies','campaign','alliance'),('horde_synergies','campaign','horde'),
       ('alliance_victory','victory','alliance'),('horde_victory','victory','horde')]
for name,state,faction in cases:
    log=destination/(name+'.log')
    command=[str(exe),'--log-file',str(log)]
    if state is None: command+=['--headless','--quit-after','3']
    else:
        image=destination/(name+'.png')
        command+=['--','--capture='+str(image),'--capture-state='+state]
        if faction: command+=['--capture-faction='+faction]
    completed=subprocess.run(command,cwd=folder,capture_output=True,text=True,encoding='utf-8',errors='replace',startupinfo=startup,timeout=30)
    text=completed.stdout+completed.stderr+(log.read_text(encoding='utf-8') if log.exists() else '')
    (destination/(name+'_process.txt')).write_text(text,encoding='utf-8')
    assert completed.returncode==0,(name,completed.returncode,text[-3000:])
    assert 'ERROR:' not in text and 'SCRIPT ERROR' not in text,(name,text[-3000:])
    if state:
        assert 'CAPTURE_RESULT=0' in text,(name,text)
        header=image.read_bytes()[:24]
        assert header[:8]==b'\x89PNG\r\n\x1a\n' and struct.unpack('>II',header[16:24])==(1280,800)
    results.append({'case':name,'exit_code':completed.returncode,'capture':state is not None})
report={'archive_sha256':hashlib.file_digest(archive.open('rb'),'sha256').hexdigest(),
        'executable_sha256':exe_hash,'files':members,'tests':results,
        'visual_review':'Captures produites ; inspection visuelle à consigner séparément.'}
(destination/'verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report,ensure_ascii=True,indent=2))
