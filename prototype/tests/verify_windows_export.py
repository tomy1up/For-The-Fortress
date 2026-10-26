"""Vérifie le contenu, l'architecture et le lancement du ZIP Windows exporté."""
from pathlib import Path
import argparse
import hashlib
import json
import os
import struct
import subprocess
import zipfile
from export_sources import verify_sources

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('archive',type=Path)
parser.add_argument('--destination',required=True,type=Path)
parser.add_argument('--screen',type=int,help='Écran réservé aux essais graphiques (index Godot).')
parser.add_argument('--source-project',type=Path,help='Comparer les sources déclarées aux fichiers de ce projet local.')
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
source_count=verify_sources(manifest,args.source_project)
assert folder.name=='For_the_Fortress_v'+manifest['version']+'_Windows_x64'
assert 'Version : '+manifest['version']+' ' in (folder/'LIRE_MOI.txt').read_text(encoding='utf-8-sig')
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
       ('fortress_breach','breach','horde'),
       ('bonus_alliance_comparison','bonus_preview','alliance'),('bonus_horde_comparison','bonus_preview','horde'),
       ('bonus_economy_comparison','bonus_preview','horde'),
       ('alliance_faction_bonuses','bonus_preview','alliance'),('horde_faction_bonuses','bonus_preview','horde'),
       ('alliance_defender_catalogue','defender_catalogue','alliance'),('horde_defender_catalogue','defender_catalogue','horde'),
       ('enemy_silhouettes','catalogue',None),
       ('debug_combat_speed','debug_speed','horde'),
       ('alliance_synergy_purchase','purchase','alliance'),('horde_synergy_purchase','purchase','horde'),
       ('alliance_synergy_branch','specialisation','alliance'),('horde_synergy_branch','specialisation','horde'),
       ('effects_mage','effects','alliance'),('effects_troll','effects','horde'),
       ('effects_sapper','effects','horde'),('effects_shaman','effects','horde'),
       ('wave_forecast','forecast','alliance'),('boss_forecast','forecast_boss','horde'),
       ('victory_summary','summary','horde'),('defeat_summary','defeat_summary','alliance'),
       ('alliance_run_report','summary','alliance'),('horde_run_report','summary','horde'),
       ('alliance_defender_summary','summary','alliance'),('horde_defender_summary','summary','horde'),
       ('defeat_defender_summary','defeat_summary','horde'),
       ('enemy_inspection','inspection','horde'),('boss_inspection','boss_inspection','alliance'),
       ('boss_without_hover','boss_inspection','horde'),
       ('upgrade_comparison','upgrade',None),('specialisation_preview','specialisation',None),
       ('alliance_purchase','purchase','alliance'),('horde_purchase','purchase','horde'),
       ('alliance_crossbow_purchase','purchase','alliance'),('alliance_mage_purchase','purchase','alliance'),
       ('horde_sapper_purchase','purchase','horde'),('horde_shaman_purchase','purchase','horde'),
       ('alliance_synergies','campaign','alliance'),('horde_synergies','campaign','horde'),
       ('alliance_victory','victory','alliance'),('horde_victory','victory','horde'),
       ('alliance_bonus_other','bonus_preview','alliance'),('horde_bonus_other','bonus_preview','horde'),
       ('alliance_bonus_details','bonus_preview','alliance'),('horde_bonus_details','bonus_preview','horde'),
       ('acquired_bonus_cards','overview','horde'),('acquired_bonus_details','overview','horde'),
       ('mage_specialisation_numbers','specialisation','alliance'),('shaman_specialisation_numbers','specialisation','horde'),
       ('attack_archer','effects','alliance'),('attack_crossbow','effects','alliance'),
       ('attack_mage','effects','alliance'),('attack_troll','effects','horde'),
       ('attack_sapper','effects','horde'),('attack_shaman','effects','horde'),
       ('projectile_archer','effects','alliance'),('projectile_crossbow','effects','alliance'),
       ('projectile_mage','effects','alliance'),('projectile_troll','effects','horde'),
       ('projectile_sapper','effects','horde'),('projectile_shaman','effects','horde'),
       ('alliance_purchase_inspection_numbers','purchase','alliance'),('horde_purchase_inspection_numbers','purchase','horde'),
       ('alliance_upgrade_inspection_numbers','upgrade','alliance'),('horde_upgrade_inspection_numbers','upgrade','horde'),
       ('horde_upgrade_compact','upgrade','horde')]
for name,state,faction in cases:
    log=destination/(name+'.log')
    command=[str(exe),'--log-file',str(log)]
    if state is None: command+=['--headless','--quit-after','3']
    else:
        if args.screen is not None: command+=['--screen',str(args.screen)]
        image=destination/(name+'.png')
        command+=['--','--capture='+str(image),'--capture-state='+state]
        if faction: command+=['--capture-faction='+faction]
        if name.endswith('_inspection_numbers'):
            command+=['--capture-inspection-numbers','--capture-type='+('2' if faction=='alliance' else '5')]
        if name=='horde_upgrade_compact': command+=['--capture-type=5']
        if name=='boss_without_hover': command+=['--capture-boss-only']
        if name.endswith('_defender_summary'): command+=['--capture-performance']
        if name in ['alliance_synergy_purchase','horde_synergy_purchase','alliance_synergy_branch','horde_synergy_branch']: command+=['--capture-synergy-preview']
        if name in ['alliance_run_report','horde_run_report','horde_defender_summary']: command+=['--capture-export-report']
        if state=='effects':
            effect_types={'effects_mage':2,'effects_troll':3,'effects_sapper':4,'effects_shaman':5,
                          'attack_archer':0,'attack_crossbow':1,'attack_mage':2,'attack_troll':3,'attack_sapper':4,'attack_shaman':5}
            effect_types.update({'projectile_'+unit:index for index,unit in enumerate(['archer','crossbow','mage','troll','sapper','shaman'])})
            command+=['--capture-type='+str(effect_types[name])]
            if name.startswith('attack_'): command+=['--capture-attack-pose']
            if name.startswith('projectile_'): command+=['--capture-projectile']
        if name=='bonus_economy_comparison': command+=['--capture-type=1']
        if name.endswith('_bonus_other'): command+=['--capture-type=3']
        if name.endswith('_bonus_details'): command+=['--capture-details=0']
        if name.endswith('_specialisation_numbers'):
            command+=['--capture-specialisation-numbers','--capture-type='+('2' if faction=='alliance' else '5')]
        if name in ['alliance_faction_bonuses','horde_faction_bonuses']: command+=['--capture-type=2']
        if name in ['alliance_crossbow_purchase','alliance_mage_purchase','horde_sapper_purchase','horde_shaman_purchase']:
            command+=['--capture-type='+str({'alliance_crossbow_purchase':1,'alliance_mage_purchase':2,'horde_sapper_purchase':4,'horde_shaman_purchase':5}[name])]
    completed=subprocess.run(command,cwd=folder,capture_output=True,text=True,encoding='utf-8',errors='replace',startupinfo=startup,timeout=30)
    text=completed.stdout+completed.stderr+(log.read_text(encoding='utf-8') if log.exists() else '')
    (destination/(name+'_process.txt')).write_text(text,encoding='utf-8')
    assert completed.returncode==0,(name,completed.returncode,text[-3000:])
    assert 'ERROR:' not in text and 'SCRIPT ERROR' not in text,(name,text[-3000:])
    if name=='boss_without_hover': assert 'BOSS_STATUS_WITHOUT_HOVER=true' in text,(name,text)
    if name in ['alliance_run_report','horde_run_report','horde_defender_summary']:
        report_folder=Path(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('RUN_REPORT_FOLDER=')))
        run_report=json.loads((report_folder/'rapport.json').read_text(encoding='utf-8'))
        assert run_report['game_version']==manifest['version'],(name,'Version du rapport différente du paquet')
        assert run_report['result']=='victory' and len(run_report['waves'])==10
        assert run_report['faction']==(0 if faction=='alliance' else 1)
        assert run_report['schema_version']==2 and len(run_report['performance'])==3
        assert run_report['boss_encounter']['status']=='killed' and abs(run_report['boss_encounter']['removed_hp']-600)<0.000001
        assert 0<run_report['boss_encounter']['resolved_seconds']<=run_report['waves'][-1]['seconds']
        assert abs(sum(unit['boss_hp'] for unit in run_report['performance'])-600)<0.000001
        assert len([action for action in run_report['actions'] if action['kind']=='bonus_choice'])==3
        assert 'Bonus proposés' in (report_folder/'rapport.md').read_text(encoding='utf-8')
    if state:
        assert 'UI_VERSION='+manifest['version'] in text,(name,'Version embarquée différente du paquet')
        assert 'CAPTURE_RESULT=0' in text,(name,text)
        header=image.read_bytes()[:24]
        assert header[:8]==b'\x89PNG\r\n\x1a\n' and struct.unpack('>II',header[16:24])==(1280,800)
    results.append({'case':name,'exit_code':completed.returncode,'capture':state is not None})
report={'archive_sha256':hashlib.file_digest(archive.open('rb'),'sha256').hexdigest(),
        'executable_sha256':exe_hash,'files':members,'tests':results,
        'source_checks':source_count,'local_sources_compared':args.source_project is not None,
        'visual_review':'Captures produites ; inspection visuelle à consigner séparément.'}
(destination/'verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report,ensure_ascii=True,indent=2))
