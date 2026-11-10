"""Vérifie le contenu, l'architecture et le lancement du ZIP Windows exporté."""
from pathlib import Path
import argparse
import hashlib
import json
import os
import re
import struct
import subprocess
import zipfile
from export_sources import verify_sources

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('archive',type=Path)
parser.add_argument('--destination',required=True,type=Path)
parser.add_argument('--screen',type=int,help='Écran réservé aux essais graphiques (index Godot).')
parser.add_argument('--background',action='store_true',help='Ouvrir les captures avec une fenêtre minimisée pour laisser la main au joueur.')
parser.add_argument('--source-project',type=Path,help='Comparer les sources déclarées aux fichiers de ce projet local.')
parser.add_argument('--case',action='append',dest='selected_cases',help='Limiter la vérification aux cas nommés ; répétable. Sans option, tous les cas sont exécutés.')
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
    assert len(members)==6,members
    assert len({name.split('/')[0] for name in members})==1
    assert {Path(name).name for name in members}=={'For_the_Fortress.exe','LIRE_MOI.txt','Fiche_essai_joueur.md','LICENCES_GODOT.txt','VERSION.json','Lancer_atelier_routes.cmd'}
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
       ('alliance_routes','combat','alliance'),('horde_routes','combat','horde'),
       ('alliance_routes_forecast','preparation','alliance'),('horde_routes_forecast','preparation','horde'),
       ('alliance_routes_mountain_forecast','preparation','alliance'),('horde_routes_mountain_forecast','preparation','horde'),
       ('alliance_routes_mountain_combat','combat','alliance'),('horde_routes_mountain_combat','combat','horde'),
       ('alliance_routes_mountain_purchase','purchase','alliance'),('horde_routes_mountain_purchase','purchase','horde'),
       ('alliance_routes_mountain_specialisation','specialisation','alliance'),
       ('alliance_bank_guardian','bank_guardian','alliance'),('horde_bank_guardian','bank_guardian','horde'),
       ('alliance_bank_guardian_protected','bank_guardian','alliance'),('horde_bank_guardian_protected','bank_guardian','horde'),
       ('alliance_bank_guardian_cursed','bank_guardian','alliance'),('horde_bank_guardian_cursed','bank_guardian','horde'),
       ('alliance_enemy_hit_motion','effects','alliance'),('horde_enemy_hit_motion','effects','horde'),
       ('home_prepared','selection',None),('home_maximum','selection',None),('home_blocked','selection',None),
       ('alliance_fortress','preparation','alliance'),('horde_fortress','preparation','horde'),
       ('alliance_fortress_damaged','preparation','alliance'),('horde_fortress_damaged','preparation','horde'),
       ('alliance_fortress_critical','preparation','alliance'),('horde_fortress_critical','preparation','horde'),
       ('alliance_fortress_destroyed','preparation','alliance'),('horde_fortress_destroyed','preparation','horde'),
       ('alliance_talents','talents','alliance'),('horde_talents','talents','horde'),
       ('alliance_talents_no_points','talents','alliance'),('horde_talents_no_points','talents','horde'),
       ('alliance_talents_reset','talents','alliance'),('horde_talents_reset','talents','horde'),
       ('alliance_reset_cap','talents','alliance'),('horde_reset_cap','talents','horde'),
       ('alliance_zero_reset','talents','alliance'),('horde_zero_reset','talents','horde'),
       ('alliance_rank_preview','talents','alliance'),('horde_rank_preview','talents','horde'),
       ('alliance_progression_victory','summary','alliance'),('horde_progression_victory','summary','horde'),
       ('alliance_progression_defeat','defeat_summary','alliance'),('horde_progression_defeat','defeat_summary','horde'),
       ('progression_pending','summary','horde'),
       ('horde_progression_intermediate','summary','horde'),
       ('profile_protection','talents','horde'),
       ('alliance_loadout_preparation','preparation','alliance'),('horde_loadout_preparation','preparation','horde'),
       ('alliance_loadout_summary','summary','alliance'),('horde_loadout_summary','summary','horde'),
       ('fortress_breach','breach','horde'),
       ('bonus_alliance_comparison','bonus_preview','alliance'),('bonus_horde_comparison','bonus_preview','horde'),
       ('bonus_economy_comparison','bonus_preview','horde'),
       ('alliance_faction_bonuses','bonus_preview','alliance'),('horde_faction_bonuses','bonus_preview','horde'),
       ('alliance_defender_catalogue','defender_catalogue','alliance'),('horde_defender_catalogue','defender_catalogue','horde'),
       ('enemy_silhouettes','catalogue','alliance'),('enemy_silhouettes_horde','catalogue','horde'),
       ('debug_combat_speed','debug_speed','horde'),
       ('alliance_synergy_purchase','purchase','alliance'),('horde_synergy_purchase','purchase','horde'),
       ('alliance_synergy_branch','specialisation','alliance'),('horde_synergy_branch','specialisation','horde'),
       ('effects_mage','effects','alliance'),('effects_troll','effects','horde'),
       ('effects_sapper','effects','horde'),('effects_shaman','effects','horde'),
       ('alliance_elimination','elimination','alliance'),('horde_elimination','elimination','horde'),
       ('alliance_wave_start','wave_start','alliance'),('horde_wave_start','wave_start','horde'),
       ('alliance_final_start','wave_start','alliance'),('horde_final_start','wave_start','horde'),
       ('alliance_countdown_warning','countdown_warning','alliance'),('horde_countdown_warning','countdown_warning','horde'),
       ('alliance_countdown_final','countdown_warning','alliance'),('horde_countdown_final','countdown_warning','horde'),
       ('wave_forecast','forecast','alliance'),('boss_forecast','forecast_boss','horde'),
       ('horde_wave_forecast','forecast','horde'),('alliance_boss_forecast','forecast_boss','alliance'),
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
       ('horde_upgrade_compact','upgrade','horde'),
       ('alliance_waves_summary','summary','alliance'),('horde_waves_summary','summary','horde'),
       ('defeat_waves_summary','defeat_summary','alliance')]
for index,unit in enumerate(['archer','crossbow','mage','troll','sapper','shaman']):
    for prefix in ['left_attack_','left_projectile_']:
        cases.append((prefix+unit,'effects','alliance' if index<3 else 'horde'))
cases.extend((name,'effects','alliance') for name in ('crossbow_reload','left_crossbow_reload'))
cases.extend((name,'effects','horde') for name in ('axe_bounce','left_axe_bounce'))
cases.append(('periodic_damage','damage_tick','horde'))
for faction in ['alliance','horde']:
    for detail in ['compact','details']:
        cases.append((faction+'_hud_'+detail,'combat',faction))
cases.append(('alliance_profile_protection','talents','alliance'))
for camp in ['alliance','horde']:
    cases.append((camp+'_progression_repeat','summary',camp))
    for tree in range(3): cases.append((camp+'_expanded_tree_'+str(tree),'talents',camp))
    cases.append((camp+'_expanded_summary','summary',camp))
for camp in ["alliance","horde"]:
    for variant in ['idle','rally','hurt','defeat']: cases.append((camp+'_royal_'+variant,'preparation',camp))
for camp in ["alliance","horde"]:
    for variant in ["fresh","completed","future","blocked","talents","returned","terrain2","terrain3","locked2"]: cases.append((camp+"_campaign_menu_"+variant,"campaign_menu",camp))
    for variant in ['fresh','first','invested','blocked']: cases.append((camp+'_talent_start_'+variant,'talents',camp))
for camp in ["alliance","horde"]:
    for mission in range(2,11):
        for stage in (["preparation","inspection","summary"] if mission <= 3 else ["preparation","summary"]): cases.append((camp+"_sample_"+str(mission)+"_"+stage,"campaign_sample",camp))
    cases.append((camp+"_sample_3_journey","campaign_sample",camp))
    cases.append((camp+"_sample_10_journey","campaign_sample",camp))
    for mission in range(4,11): cases.append((camp+"_campaign_menu_terrain"+str(mission),"campaign_menu",camp))
for camp in ["alliance","horde"]:
    for context in ["1","4","final","losses","defeat"]: cases.append((camp+"_wave_context_"+context,"defeat_summary" if context=="defeat" else "summary",camp))
for camp in ['alliance','horde']:
    for pose in ['0','1']: cases.append((camp+'_wolf_walk_'+pose,'wolf_walk',camp))
for camp in ['alliance','horde']:
    for variant in ['catalogue','owned','comparison_0','comparison_1']:
        cases.append((camp+'_shop_'+variant,'shop_menu',camp))
for camp in ['alliance','horde']:
    for number in [1,11,20]: cases.append((camp+'_scout_'+str(number),'mission_scout',camp))
for camp in ['alliance','horde']:
    for variant in ['slate','slateplay','ridges','ridgesplay']+[f'mountain{number}{stage}' for number in range(23,41) for stage in ['', 'play']]+['mountain40completed']+[f'marsh{number}{stage}' for number in range(41,61) for stage in ['', 'play']]+['marsh50completed','marsh60completed']+[f'volcano{number}{stage}' for number in range(61,71) for stage in ['', 'play']]+['volcano70completed']+[f'ash{number}{stage}' for number in range(71,81) for stage in ['', 'play']]+['ash80completed']:
        cases.append((camp+'_campaign_menu_'+variant,'campaign_menu',camp))
    for state in ['preparation','purchase','specialisation','defeat_summary']:
        cases.append((camp+'_three_'+state,state,camp))
    for wave in [2,3]:
        cases.append((f'{camp}_routes_mountain_wave{wave}_forecast','preparation',camp))
    cases.append((f'{camp}_routes_mountain_breaches','defeat_summary',camp))
    cases.append((f'{camp}_routes_mountain_entry2_forecast','preparation',camp))
    cases.append((f'{camp}_routes_mountain_inspection','inspection',camp))
available_case_count=len(cases)
if args.selected_cases:
    unknown=set(args.selected_cases)-{name for name,_,_ in cases}
    assert not unknown,'Cas de vérification inconnus : '+', '.join(sorted(unknown))
    cases=[case for case in cases if case[0] in args.selected_cases]
for name,state,faction in cases:
    log=destination/(name+'.log')
    command=[str(exe),'--log-file',str(log)]
    if state is None: command+=['--headless','--quit-after','3']
    else:
        if args.screen is not None: command+=['--screen',str(args.screen)]
        if args.background: command+=['--minimized']
        image=destination/(name+'.png')
        command+=['--','--capture='+str(image),'--capture-state='+state]
        if faction: command+=['--capture-faction='+faction]
        if '_three_' in name:
            command+=['--atelier-trois','--capture-type='+('0' if faction=='alliance' else '3')]
            if state=='defeat_summary': command+=['--capture-summary-wave=1','--capture-export-report']
        if state=='mission_scout': command+=['--capture-scout-mission='+name.rsplit('_',1)[1]]
        if state=='wolf_walk': command+=['--capture-wolf-offset='+('0.0' if name.endswith('_0') else '0.35')]
        if state=='shop_menu':
            if '_comparison_' in name: command+=['--capture-shop-comparison='+name.rsplit('_',1)[1]]
            if name.endswith('_owned'): command+=['--capture-shop-owned']
        if '_routes' in name: command+=['--atelier-col' if '_mountain_' in name else '--atelier-routes']
        if '_mountain_wave' in name: command+=['--capture-route-wave='+name.split('_')[-2][-1]]
        if '_mountain_entry2_' in name: command+=['--capture-route-entry=2']
        if name.endswith('_routes_mountain_inspection'): command+=['--capture-route-inspection']
        if name.endswith('_mountain_breaches'): command+=['--capture-summary-wave=1','--capture-export-report']
        if '_royal_' in name: command+=['--capture-royal-state='+name.rsplit('_',1)[1]]
        if name.endswith('_enemy_hit_motion'): command+=['--capture-hit-motion','--capture-type='+('2' if faction=='alliance' else '4')]
        if state=="campaign_menu": command += ["--capture-campaign="+name.rsplit("_",1)[1]]
        if '_talent_start_' in name: command += ['--capture-talent-start='+name.rsplit('_',1)[1]]
        if state=="campaign_sample": command += ["--capture-mission="+name.split("_")[2],"--capture-sample-state="+name.rsplit("_",1)[1]]
        if state in ['forecast','forecast_boss']: command+=['--capture-forecast-portraits']
        if '_hud_' in name:
            command+=['--capture-hud']
            if name.endswith('_details'): command+=['--capture-combat-details']
        if '_fortress' in name:
            command+=['--capture-fortress']
            if not name.endswith('_fortress'): command+=['--capture-fortress-health='+name.rsplit('_',1)[1]]
        if state=='elimination': command+=['--capture-type='+('2' if faction=='alliance' else '4')]
        if name.endswith('_final_start'): command+=['--capture-start-final']
        if name.endswith('_countdown_final'): command+=['--capture-countdown-final']
        if '_expanded_tree_' in name: command+=['--capture-expanded-tree='+name[-1]]
        if '_bank_guardian_' in name: command+=['--capture-guardian-inspection='+name.rsplit('_',1)[1]]
        if name.endswith('_bank_guardian_protected'): command+=['--capture-guardian-moved']
        if name.endswith('_expanded_summary'): command+=['--capture-expanded-summary']
        if name.startswith('home_'): command+=['--capture-home='+{'home_prepared':'prepared','home_maximum':'maximum','home_blocked':'blocked'}[name]]
        if name.endswith('_talents_reset'): command+=['--capture-meta-reset']
        if name.endswith('_reset_cap'): command+=['--capture-meta-reset','--capture-reset-cap']
        if name.endswith('_zero_reset'): command+=['--capture-meta-no-points','--capture-meta-reset']
        if name.endswith('_talents_no_points'): command+=['--capture-meta-no-points']
        if name.endswith('_rank_preview'): command+=['--capture-meta-preview']
        if '_progression_' in name or name=='progression_pending': command+=['--capture-meta-rewards']
        if name=='progression_pending': command+=['--capture-meta-pending']
        if name.endswith('_progression_repeat'): command+=['--capture-repeat-mission']
        if name.endswith('_progression_intermediate'): command+=['--capture-meta-intermediate']
        if name.endswith('profile_protection'): command+=['--capture-profile-protection']
        if '_loadout_' in name: command+=['--capture-meta-loadout']
        if name.endswith('_waves_summary'): command+=['--capture-waves']
        if '_wave_context_' in name: command+=['--capture-summary-wave='+('losses' if name.endswith('_defeat') else name.rsplit('_',1)[1])]
        if name.endswith('_inspection_numbers'):
            command+=['--capture-inspection-numbers','--capture-type='+('2' if faction=='alliance' else '5')]
        if name=='horde_upgrade_compact': command+=['--capture-type=5']
        if name=='boss_without_hover': command+=['--capture-boss-only']
        if name.endswith('_defender_summary'): command+=['--capture-performance']
        if name in ['alliance_synergy_purchase','horde_synergy_purchase','alliance_synergy_branch','horde_synergy_branch']: command+=['--capture-synergy-preview']
        if name in ['alliance_run_report','horde_run_report','horde_defender_summary'] or name.endswith('_loadout_summary'): command+=['--capture-export-report']
        if state=='effects':
            effect_types={'effects_mage':2,'effects_troll':3,'effects_sapper':4,'effects_shaman':5,
                          'alliance_enemy_hit_motion':2,'horde_enemy_hit_motion':4,
                          'attack_archer':0,'attack_crossbow':1,'attack_mage':2,'attack_troll':3,'attack_sapper':4,'attack_shaman':5}
            effect_types.update({'projectile_'+unit:index for index,unit in enumerate(['archer','crossbow','mage','troll','sapper','shaman'])})
            for prefix in ['left_attack_','left_projectile_']:
                effect_types.update({prefix+unit:index for index,unit in enumerate(['archer','crossbow','mage','troll','sapper','shaman'])})
            effect_types.update({'crossbow_reload':1,'left_crossbow_reload':1})
            effect_types.update({'axe_bounce':3,'left_axe_bounce':3})
            command+=['--capture-type='+str(effect_types[name])]
            if name.startswith('left_'): command+=['--capture-slot=0']
            if name.startswith(('attack_','left_attack_')): command+=['--capture-attack-pose']
            if name.startswith(('projectile_','left_projectile_')): command+=['--capture-projectile']
            if name.endswith('crossbow_reload'): command+=['--capture-crossbow-reload']
            if name.endswith('axe_bounce'): command+=['--capture-axe-bounce']
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
    if '_routes' in name:
        snapshot=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('ROUTE_WORKSHOP=')))
        map_id = 'workshop_mountain' if '_mountain_' in name else 'workshop_confluence'
        assert snapshot=={'isolated':True,'routes':2,'mission_empty':True,'map_id':map_id}
        if name.endswith('_routes_mountain_inspection'):
            entry=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('ENEMY_ENTRY_SNAPSHOT=')))
            assert entry=={'visible':True,'entry':'Vient de l’entrée 2','route':'lower'}
        if '_mountain_entry2_' in name:
            assert json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('ROUTE_ENTRY_HOVER=')))==[1]
        if name.endswith('_mountain_breaches'):
            arrivals=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('WAVE_ARRIVALS_SNAPSHOT=')))
            assert arrivals=='Ennemis ayant atteint la forteresse — Entrée 1 · 5   /   Entrée 2 · 5', arrivals
            report_folder=Path(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('RUN_REPORT_FOLDER=')))
            report=json.loads((report_folder/'rapport.json').read_text(encoding='utf-8'))
            markdown=(report_folder/'rapport.md').read_text(encoding='utf-8')
            assert report['game_version']==manifest['version'] and report['faction']==(0 if faction=='alliance' else 1)
            assert 'À partir de la vague 2, environ deux ennemis sur trois' in markdown
            assert '### Détail par vague\n\n| Vague | Entrée 1 | Entrée 2 |' in markdown
            for wave in report['waves']:
                counts = [wave['arrivals_by_route'].get(entry['route_id'],0) for entry in report['arrivals_by_entry']]
                assert sum(counts)==wave['escaped']
                assert f"| {wave['wave']} | {counts[0]} | {counts[1]} |" in markdown
        if name.endswith('_purchase'):
            assert re.search(r'ROUTE_PURCHASE_HINT=Trajet à portée · Entrée 1 : \d+ % · Entrée 2 : \d+ %',text), name
        if name.endswith('_specialisation'):
            descriptions = json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('ROUTE_SPECIALISATION=')))
            assert len(descriptions)==2 and all('Entrée 1' in value and 'Entrée 2' in value for value in descriptions), descriptions
        if name.endswith('_forecast'):
            forecast=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('ROUTE_FORECAST_SNAPSHOT=')))
            assert forecast['faction']==(0 if faction=='alliance' else 1) and forecast['visible']
            counts = [entry['count'] for entry in forecast['entries']]
            assert len(counts)==2 and min(counts)>0
            expected = [12,6] if '_wave2_' in name else [5,11] if '_wave3_' in name else [5,5]
            assert counts==expected, counts
            main_entry = counts.index(max(counts))+1 if counts[0]!=counts[1] else 0
            assert forecast['labels']==[
                [f'ENTRÉE {index}'+(' · PRINCIPALE' if index==main_entry else ''),f'{count} ennemis']
                for index,count in enumerate(counts,1)
            ]
            assert forecast['note']==f'Entrée 1 : {counts[0]} · Entrée 2 : {counts[1]}'
            displayed_counts = [0,0]
            for group in forecast['group_routes']:
                for segment in group.split(' / '):
                    entry,count = re.fullmatch(r'Entrée ([12]) · (\d+)',segment).groups()
                    displayed_counts[int(entry)-1] += int(count)
            assert displayed_counts==counts, forecast['group_routes']
    if '_three_' in name:
        workshop=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('ROUTE_WORKSHOP=')))
        assert workshop=={'isolated':True,'routes':3,'mission_empty':True,'map_id':'slate_crossing'}
        if state=='preparation':
            forecast=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('ROUTE_FORECAST_SNAPSHOT=')))
            assert [entry['count'] for entry in forecast['entries']]==[4,3,3]
            assert 'Entrée 3' in forecast['group_routes'][0]
        if state=='purchase':
            assert re.search(r'ROUTE_PURCHASE_HINT=Trajet à portée · Entrée 1 : \d+ % · Entrée 2 : \d+ % · Entrée 3 : \d+ %',text)
        if state=='specialisation' and faction=='alliance':
            descriptions=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('ROUTE_SPECIALISATION=')))
            assert all('Entrée 3' in value for value in descriptions)
        if state=='defeat_summary':
            arrivals=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('WAVE_ARRIVALS_SNAPSHOT=')))
            assert arrivals=='Ennemis ayant atteint la forteresse — Entrée 1 · 4   /   Entrée 2 · 3   /   Entrée 3 · 3'
            folder=Path(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('RUN_REPORT_FOLDER=')))
            report=json.loads((folder/'rapport.json').read_text(encoding='utf-8'))
            assert [entry['arrivals'] for entry in report['arrivals_by_entry']] and len(report['arrivals_by_entry'])==3
            assert sum(entry['arrivals'] for entry in report['arrivals_by_entry'])==report['total_escaped']
    if '_wave_context_' in name:
        snap=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('WAVE_CONTEXT_SNAPSHOT=')))
        context=name.rsplit('_',1)[1]
        assert snap['readonly'] and snap['isolated'] and snap['faction']==(0 if faction=='alliance' else 1)
        assert snap['enabled']==snap['record_count'] and snap['record_count']>0
        if context in ['1','4','final']:
            assert snap['tab']==0 and snap['selected']==(0 if context=='final' else int(context))
        if snap['selected']:
            assert snap['marked']==1 and not snap['final_disabled'] and snap['heading']=='Défense au départ · Vague '+str(snap['selected'])
        else: assert snap['marked']==0 and snap['final_disabled']
        if context=='1': assert snap['bonuses']==['Aucun bonus'] and all('Niveau 1' in line for line in snap['army'])
        if context=='4': assert len(snap['bonuses'])==1 and snap['bonuses']!=['Aucun bonus']
        if context=='final': assert len(snap['bonuses'])==3 and snap['heading']=='Défense finale'
        if context=='defeat': assert snap['tab']==0 and snap['selected']==1 and snap['army']==['Aucun défenseur']
    if state=="campaign_sample":
        snap=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('SAMPLE_SNAPSHOT=')))
        mission=int(name.split('_')[2]);stage=name.rsplit('_',1)[1]
        completed_missions=mission if stage in ['summary','journey'] else mission-1
        assert snap['faction']==(0 if faction=='alliance' else 1) and snap['isolated'] and snap['mission']==mission and snap['stage']==stage
        assert snap['map']==['valley_ford','ford_woods','ford_heights','ford_turns','ford_glade','ford_pass','ford_switchbacks','ford_trail','ford_approach','ford_ramparts'][mission-1] and snap['hp_percent']==99+mission
        assert snap['completed']==completed_missions and snap['other']==0 and snap['xp']==100*completed_missions and snap['po']==60*completed_missions
        assert snap['points']==51*completed_missions//100 and snap['rank']==(1 if mission>=3 else 0)
        assert (6<=snap['scenery_count']<=22) if mission>=4 else snap['scenery_count']==0
        assert snap['summary']==(stage=='summary') and snap['menu']==(stage=='journey')
        if stage=='inspection': assert ('40,4' if mission==2 else '40,8') in snap['enemy_health'],snap
        if stage=='journey': assert snap['selection']==min(mission+1,20)
        if stage=='summary':
            assert ('Mission '+str(mission)) in snap['summary_mission'] and snap['title'].lower() in snap['summary_mission'].lower()
            assert 'XP : +100' in snap['reward_note']
            free=snap['points']-snap['rank']
            assert snap['talent_action']==('Placer mon point de talent' if free==1 else 'Placer mes '+str(free)+' points' if free>1 else 'Consulter mes talents')
            if mission<=3: assert ('1 point de talent à placer' if mission==2 else 'encore 93 XP') in snap['reward_note']
            report_folder=Path(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('RUN_REPORT_FOLDER=')))
            report=json.loads((report_folder/'rapport.json').read_text(encoding='utf-8'))
            assert report['result']=='victory' and len(report['waves'])==10 and report['enemy_hp_percent']==99+mission and report['map_definition']['id']==snap['map']
            assert abs(report['boss_encounter']['max_hp']-600*(99+mission)/100)<0.000001
    if '_campaign_menu_volcano' in name:
        snap=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('CAMPAIGN_SNAPSHOT=')))
        camp=0 if faction=='alliance' else 1
        number=int(name.rsplit('_',1)[1].removeprefix('volcano').removesuffix('play').removesuffix('completed'))
        map_id=['volcano_threshold','volcano_flows','volcano_caldera','volcano_vents','volcano_forges','volcano_bridge','volcano_organs','volcano_twin','volcano_road','volcano_core'][number-61]
        routes={63:2,65:3,66:2,68:2,69:3,70:3}.get(number,0)
        assert snap['isolated'] and snap['faction']==camp and snap['menu'] and not snap['disabled']
        assert (snap['chapter'],snap['selected'],snap['preview_map'],snap['preview_routes'])==(7,number,map_id,routes or 1)
        won_missions=number if name.endswith('completed') else number-1
        assert (snap['completed'],snap['other_completed'],snap['po'],snap['xp'])==(won_missions,0,60*won_missions,100*won_missions)
        assert snap['mission_states']==(['completed']*10 if name.endswith('completed') else ['completed']*(number-61)+['available']+['locked']*(70-number))
        if name.endswith('completed'): assert snap['start_label']=='Rejouer sans nouveau gain' and snap['fresh']
        if name.endswith('play'):
            launch=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('SLATE_MISSION=')))
            assert launch=={'map':map_id,'routes':routes,'hp_percent':99+number,'mission':f'campaign.{number:03d}','faction':camp,'menu':False,'hp':20,'gold':150,'forecast':routes,'active_profile_run':True}
    elif '_campaign_menu_ash' in name:
        snap=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('CAMPAIGN_SNAPSHOT=')))
        camp=0 if faction=='alliance' else 1
        number=int(name.rsplit('_',1)[1].removeprefix('ash').removesuffix('play').removesuffix('completed'))
        map_id=['ash_crater','ash_chimneys','ash_cone','ash_rift','ash_geysers','ash_flow','ash_embers','ash_dome','ash_gorge','ash_heart'][number-71]
        routes={73:2,74:3,76:2,77:3,78:2,80:3}.get(number,0)
        assert snap['isolated'] and snap['faction']==camp and snap['menu'] and not snap['disabled']
        assert (snap['chapter'],snap['selected'],snap['preview_map'],snap['preview_routes'])==(8,number,map_id,routes or 1)
        won_missions=number if name.endswith('completed') else number-1
        assert (snap['completed'],snap['other_completed'],snap['po'],snap['xp'])==(won_missions,0,60*won_missions,100*won_missions)
        assert snap['mission_states']==(['completed']*10 if name.endswith('completed') else ['completed']*(number-71)+['available']+['locked']*(80-number))
        if name.endswith('completed'): assert snap['start_label']=='Rejouer sans nouveau gain' and snap['fresh']
        if name.endswith('play'):
            launch=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('SLATE_MISSION=')))
            assert launch=={'map':map_id,'routes':routes,'hp_percent':99+number,'mission':f'campaign.{number:03d}','faction':camp,'menu':False,'hp':20,'gold':150,'forecast':routes,'active_profile_run':True}
            eruptions=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('ERUPTIONS_SNAPSHOT=')))
            assert eruptions['affix']=={'id':'eruptions','interval':14,'warning':3,'duration':5} and eruptions['visible'] and eruptions['text'].startswith('Éruptions')
    elif '_campaign_menu_marsh' in name:
        snap=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('CAMPAIGN_SNAPSHOT=')))
        camp=0 if faction=='alliance' else 1
        number=int(name.rsplit('_',1)[1].removeprefix('marsh').removesuffix('play').removesuffix('completed'))
        map_id=['marsh_threshold','marsh_basins','marsh_court','marsh_channels','marsh_cloister','marsh_causeway','marsh_fords','marsh_islets','marsh_nave','marsh_sanctuary','marsh_stagnant','marsh_banks','marsh_currents','marsh_abyss','marsh_delta','marsh_overflow','marsh_pillars','marsh_crossroads','marsh_cathedral','marsh_heart'][number-41]
        routes={43:2,44:2,47:3,48:2,50:3,53:2,55:3,56:2,58:3,59:2,60:3}.get(number,0)
        assert snap['isolated'] and snap['faction']==camp and snap['menu'] and not snap['disabled']
        assert (snap['chapter'],snap['selected'],snap['preview_map'],snap['preview_routes'])==((number-1)//10+1,number,map_id,routes or 1)
        won_missions=number if name.endswith('completed') else number-1
        assert (snap['completed'],snap['other_completed'],snap['po'],snap['xp'])==(won_missions,0,60*won_missions,100*won_missions)
        assert snap['mission_states']==(['completed']*10 if name.endswith('completed') else ['completed']*(number-(number-1)//10*10-1)+['available']+['locked']*(min(60,(number-1)//10*10+10)-number)+['future']*((number-1)//10*10+10-min(60,(number-1)//10*10+10)))
        if name.endswith('completed'): assert snap['start_label']=='Rejouer sans nouveau gain' and snap['fresh']
        if name.endswith('play'):
            marsh=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('MARSH_SNAPSHOT=')))
            assert marsh['isolated'] and marsh['map']==map_id and marsh['decoration']=='marsh'
            assert marsh['scenery_count']>0 and marsh['affix_empty'] and not marsh['affix_visible']
            launch=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('SLATE_MISSION=')))
            assert launch=={'map':map_id,'routes':routes,'hp_percent':99+number,'mission':f'campaign.{number:03d}','faction':camp,'menu':False,'hp':20,'gold':150,'forecast':routes,'active_profile_run':True}
    elif name.endswith(('_campaign_menu_slate','_campaign_menu_slateplay','_campaign_menu_ridges','_campaign_menu_ridgesplay')) or '_campaign_menu_mountain' in name:
        snap=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('CAMPAIGN_SNAPSHOT=')))
        camp=0 if faction=='alliance' else 1
        assert snap['isolated'] and snap['faction']==camp and snap['menu'] and not snap['disabled']
        ridges = '_ridges' in name
        number = 22 if ridges else 21
        if '_mountain' in name: number=int(name.rsplit('_',1)[1].removeprefix('mountain').removesuffix('play').removesuffix('completed'))
        map_id = ['slate_pass','slate_ridges','slate_scree','slate_ravine','slate_gates','slate_crossing','slate_laces','slate_cirque','slate_high_passages','slate_bastion'][(number-21)%10]
        routes = {24:0,26:3,27:0,29:3}.get(21+(number-21)%10,2)
        assert (snap['chapter'],snap['selected'],snap['preview_map'],snap['preview_routes'])==((number-1)//10+1,number,map_id,routes or 1)
        won_missions=number if name.endswith('completed') else number-1
        assert (snap['completed'],snap['other_completed'],snap['po'],snap['xp'])==(won_missions,0,60*won_missions,100*won_missions)
        assert snap['mission_states']==(['completed']*10 if name.endswith('completed') else ['completed']*(number-31)+['available']+['locked']*(40-number) if number>=31 else ['completed']*(number-21)+['available']+['locked']*(30-number))
        if name.endswith('completed'): assert snap['start_label']=='Rejouer sans nouveau gain' and snap['fresh']
        if name.endswith('play'):
            launch=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('SLATE_MISSION=')))
            assert launch=={'map':map_id,'routes':routes,'hp_percent':99+number,'mission':f'campaign.{number:03d}','faction':camp,'menu':False,'hp':20,'gold':150,'forecast':routes,'active_profile_run':True}
            if number>=31:
                affix=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('HEADWINDS_SNAPSHOT=')))
                assert affix=={'affix':{'id':'headwinds','cadence_percent':90},'visible':True,'text':'Vents contraires · −10 % de cadence'}
    elif state=="campaign_menu":
        snap=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('CAMPAIGN_SNAPSHOT=')))
        variant=name.rsplit('_',1)[1]
        assert snap['isolated'] and snap['faction']==(0 if faction=='alliance' else 1) and snap['menu'] and snap['choosing']
        assert snap['nodes']==10 and snap['chapters']==20 and snap['fresh']
        assert snap['talents']==(variant=='talents') and snap['disabled']==(variant in ['future','blocked','locked2'])
        successes = int(variant[7:])-1 if variant.startswith('terrain') else 1 if variant in ['completed','returned','terrain2'] else 0
        assert snap['completed']==(-1 if variant=='blocked' else successes)
        assert snap['other_completed']==(-1 if variant=='blocked' else 0)
        selection = int(variant[7:]) if variant.startswith('terrain') else 2 if variant in ['returned','terrain2','locked2'] else 1
        assert (snap['chapter'],snap['selected'])==((20,200) if variant=='future' else (1,selection))
        assert snap['po']==60*successes and snap['xp']==(10100 if variant=='returned' else 100*successes)
        assert snap['preview_map']==('' if variant=='future' else ['valley_ford','ford_woods','ford_heights','ford_turns','ford_glade','ford_pass','ford_switchbacks','ford_trail','ford_approach','ford_ramparts'][selection-1])
        assert snap['preview_slots']==(0 if variant=='future' else 6)
        assert snap['preview_segments']==(0 if variant=='future' else [7,7,7,7,8,8,7,8,8,8][selection-1])
        assert snap['chapter_visible'], (name, 'Le chapitre sélectionné doit rester dans la liste visible')
        expected_states=['completed']*successes+['available']+['locked']*(9-successes)
        assert snap['mission_states']==(['future']*10 if variant=='future' else ['unavailable']*10 if variant=='blocked' else expected_states)
        if variant=='blocked': assert snap['start_label']=='Progression indisponible'
    if name in ['alliance_purchase','horde_purchase','alliance_crossbow_purchase','alliance_mage_purchase','horde_sapper_purchase','horde_shaman_purchase']:
        ghost=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('PURCHASE_GHOST_SNAPSHOT=')))
        expected_type={'alliance_purchase':0,'horde_purchase':3,'alliance_crossbow_purchase':1,'alliance_mage_purchase':2,'horde_sapper_purchase':4,'horde_shaman_purchase':5}[name]
        assert ghost['visible'] and ghost['type']==expected_type and ghost['slot']==3 and ghost['empty'] and ghost['gold']==150 and ghost['instances']==0
    if '_fortress' in name:
        fortress=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('FORTRESS_SNAPSHOT=')))
        expected={'damaged':(10,1),'critical':(4,2),'destroyed':(0,3)}.get(name.rsplit('_',1)[1],(20,0))
        assert fortress['faction']==(0 if faction=='alliance' else 1) and fortress['e6_clear'] and (fortress['hp'],fortress['condition'])==expected
        color=int(fortress['banner'],16);red=(color>>16)&255;blue=color&255
        assert (blue>red) if faction=='alliance' else (red>blue)
    if state in ['forecast','forecast_boss']:
        forecast=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('FORECAST_PORTRAITS_SNAPSHOT=')))
        assert forecast['visible'] and forecast['wave']==(9 if state=='forecast' else 10)
        assert len(forecast['portraits']) in [3,4]
        for portrait in forecast['portraits']:
            assert portrait['same_source']
            expected='enemy.neutral.' if portrait['profile'] in [0,2,3] else 'enemy.horde.' if faction=='alliance' else 'enemy.alliance.'
            assert portrait['id'].startswith(expected)

    if '_hud_' in name:
        hud=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('HUD_SNAPSHOT=')))
        detailed=name.endswith('_details')
        assert hud['details']==detailed and hud['time_visible']==detailed
        assert hud['max_hp']==20 and 0<=hud['hp']<=hud['max_hp']
        assert hud['tally'].startswith('Apparus :' if detailed else 'Ennemis restants :')
        assert len(hud['tally'].splitlines())==(3 if detailed else 2)
    if state=='selection':
        home=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('HOME_SNAPSHOT=')))
        assert home['isolated'] and home['readonly']
        if name=='selection': assert home['resources']==['0 PO Alliance','0 PO Horde'] and all('XP : 0 / 197' in hint for hint in home['hints'])
        if name=='home_prepared':
            assert home['resources']==['4 PO Alliance','25 PO Horde'] and home['points']==['5 points actifs · 3 à placer','3 points actifs · 0 à placer']
            assert home['hp']==['Forteresse au départ : 25 PV','Forteresse au départ : 20 PV'] and 'XP :' in home['hints'][1]
        if name=='home_maximum': assert all('51 points actifs' in line for line in home['points']) and all('51 points de talent débloqués' in hint for hint in home['hints'])
        if name=='home_blocked': assert home['resources']==['PO : à vérifier']*2 and 'Sauvegarde à vérifier' in home['notice']
    if state=='talents':
        assert 'META_CAPTURE_ISOLATED=true' in text,(name,'La capture doit rester isolée du vrai profil')
        xp_snapshot=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('TALENT_STATES_SNAPSHOT=')))
        assert xp_snapshot['buy_hidden'] and ('XP' in xp_snapshot['xp_label'] or '51 points' in xp_snapshot['xp_label'])
        graph=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('LINKED_SNAPSHOT=')))
        assert graph['all_visible'] and graph['valid'] and graph['links_per_tree']==4
        assert graph['prerequisites']==0 if name.endswith('_talent_start_blocked') else graph['prerequisites']>0
        assert xp_snapshot['highlighted']==1 and len(xp_snapshot['roles'])==3 and 'PO' not in xp_snapshot['heading']
        if '_talent_start_' in name:
            variant=name.rsplit('_',1)[1]
            assert xp_snapshot['xp']==(200 if variant in ['first','invested'] else 0)
            assert xp_snapshot['heading'].startswith('1 point à placer' if variant=='first' else 'Progression à vérifier' if variant=='blocked' else 'Aucun point à placer')
            assert xp_snapshot['roles'][0].startswith('Points indisponibles' if variant=='blocked' else '1 point' if variant=='invested' else '0 point')
            if variant=='blocked': assert '/51' not in xp_snapshot['heading'] and xp_snapshot['xp_label']=='XP indisponible'
            assert ('première victoire' in xp_snapshot['hint']) if variant in ['fresh','invested'] else ('Sauvegarde indisponible' in xp_snapshot['hint']) if variant=='blocked' else ('marqué +' in xp_snapshot['hint'])
    if '_expanded_tree_' in name:
        snapshot=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('EXPANDED_SNAPSHOT=')))
        assert snapshot['isolated'] and snapshot['points']==51 and snapshot['nodes']==63 and snapshot['scroll']==0 and snapshot['tree']==int(name[-1]) and '★' in snapshot['title']
    if name.endswith('_expanded_summary'):
        snapshot=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('EXPANDED_SUMMARY=')))
        assert snapshot['isolated'] and snapshot['points']==51 and snapshot['visible'] and snapshot['text']
    if name.endswith('_zero_reset'):
        quote=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('RESPEC_SNAPSHOT=')))
        assert quote['isolated'] and quote['visible'] and quote['price']==0 and quote['balance_after']==0
        assert quote['free_before']==0 and quote['free_after']==12 and 'Réinitialisation gratuite' in quote['dialog']
    if name.endswith('_talents_reset') or name.endswith('_reset_cap'):
        quote=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('RESPEC_SNAPSHOT=')))
        assert quote['isolated'] and quote['visible'] and quote['free_before']==2 and quote['free_after']==14
        assert quote['price']==0 and quote['next_price']==0 and 'Réinitialisation gratuite' in quote['dialog']
        assert quote['balance_after']==36-quote['price'] and 'les points débloqués sont conservés' in quote['dialog']
    if '_royal_' in name:
        royal=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('ROYAL_SNAPSHOT=')))
        variant=name.rsplit('_',1)[1]
        assert royal['isolated'] and royal['faction']==(0 if faction=='alliance' else 1)
        assert royal['hp']=={'idle':20,'rally':20,'hurt':10,'defeat':0}[variant] and royal['pose']=={'idle':0,'rally':1,'hurt':2,'defeat':3}[variant]
        assert royal['castle'].endswith('forteresse_'+faction+'_v001.png') and royal['king'].endswith('roi_'+faction+'_v001.png')
    if '_bank_guardian' in name:
        if name.endswith('_protected'): assert 'GUARDIAN_MOVED=true' in text, name
        guardian=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('GUARDIAN_SNAPSHOT=')))
        assert guardian['isolated'] and guardian['faction']==(0 if faction=='alliance' else 1)
        assert abs(guardian['hp']-193)<0.000001 and abs(guardian['max_hp']-198)<0.000001
        assert guardian['transfers']==2 and guardian['wave_set_id']=='ford_banks'
        assert all(abs(a-b)<0.000001 for a,b in zip(guardian['victims'],[35,20.4]))
        inspection=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('GUARDIAN_INSPECTION_SNAPSHOT=')))
        if name.endswith('_protected'):
            assert inspection=={'inspected':2,'status':'25 % des dégâts transférés','links':1,'visible':True},inspection
        else:
            assert inspection['inspected']==0 and inspection['links']==2 and inspection['visible'],inspection
            assert inspection['status']==('Absorbe 25 % · 2 voisins · Maudite' if name.endswith('_cursed') else 'Absorbe 25 % · 2 voisins'),inspection
    if name.endswith('_enemy_hit_motion'):
        motion=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('HIT_MOTION_SNAPSHOT=')))
        assert motion['faction']==(0 if faction=='alliance' else 1) and motion['moving'] and motion['observations']>0
        assert motion['reacting'] and all(0<enemy['strength']<=1 and -0.105<=enemy['rotation']<0 for enemy in motion['reacting'])
    if name in ['alliance_talents','horde_talents','alliance_talents_no_points','horde_talents_no_points']:
        talent=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('TALENT_STATES_SNAPSHOT=')))
        assert talent['isolated'] and talent['progress']==[0,5,10,11,11,11,11] and len(talent['states'])==63
        assert talent['states'][0]=='maximum' and talent['states'][4]=='exclusive' and talent['states'][6]=='locked'
        assert talent['states'][2]==('unfunded' if name.endswith('_no_points') else 'available')
    if name.endswith('_rank_preview'): assert 'META_RANK_PREVIEW=true' in text,(name,'Le gain du prochain rang doit être affiché')
    if name.endswith('profile_protection'): assert 'PROFILE_PROTECTION=true' in text and 'MISSION_LEDGER_PROTECTION=true' in text and 'PARENT_PROTECTION=true' in text,(name,'Le paquet doit chiffrer et relire un profil de contrôle')
    if '_loadout_' in name:
        snapshot=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('LOADOUT_SNAPSHOT=')))
        assert snapshot['faction']==(0 if faction=='alliance' else 1) and snapshot['points']==33 and snapshot['readonly'] and snapshot['isolated'] and '33 points' in snapshot['caption']
        if name.endswith('_summary'): assert snapshot['summary'] and snapshot['tab']==3
    if '_progression_' in name or name=='progression_pending':
        snapshot=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('META_REWARD_SNAPSHOT=')))
        camp=0 if faction=='alliance' else 1
        assert snapshot['isolated'] and snapshot['faction']==camp and snapshot['banks'][1-camp]==0
        info=snapshot['info']
        if name=='progression_pending': assert not info['ready'] and info['saved']==0 and info['pending']==60 and info['balance']==6
        elif name.endswith('_progression_intermediate'): assert not info['finished'] and not info['ready'] and info['saved']==0 and info['pending']==55 and info['balance']==6 and info['bonus']==0 and not snapshot['home'] and not snapshot['talents']
        elif name.endswith('_repeat'): assert info['ready'] and not info['first'] and info['saved']==0 and info['xp_earned']==0 and info['xp']==100 and info['balance']==66
        elif name.endswith('_victory'): assert info['ready'] and info['saved']==60 and info['waves']==0 and info['bonus']==0 and info['xp_earned']==100 and info['balance']==66 and info['affordable']==0
        else: assert info['ready'] and info['saved']==0 and info['bonus']==0 and info['balance']==6 and info['xp_earned']==0
    if name.startswith('left_'): assert 'ATTACK_FACING=-1' in text,(name,'La fixture doit couvrir un vrai tir à gauche')
    if name.endswith('axe_bounce'):
        snapshot = json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('AXE_BOUNCE=')))
        assert snapshot['segments']>0 and 0.12<snapshot['age']<0.32 and snapshot['isolated'], (name,snapshot)
    if name.endswith('crossbow_reload'):
        snapshot = json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('CROSSBOW_RELOAD=')))
        assert snapshot['active'] and snapshot['pulse']==0.0 and snapshot['isolated'], (name,snapshot)
        if name=='crossbow_reload': assert 'ATTACK_FACING=1' in text, name
    if name=='periodic_damage': assert 'DAMAGE_TICK_VISIBLE=true' in text,(name,'Le contrôle doit montrer un dégât périodique réel')
    if state=='elimination': assert 'ELIMINATION_VISIBLE=true' in text,(name,'La dissipation doit suivre une vraie élimination')
    if state=='wave_start':
        notice=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('WAVE_NOTICE_SNAPSHOT=')))
        assert notice['visible'] and notice['active'] and abs(notice['elapsed']-0.2)<0.000001 and abs(notice['remaining']-1.8)<0.000001
        assert notice['wave']==(10 if name.endswith('_final_start') else 1)
        if name.endswith('_final_start'):
            assert notice['title']=='VAGUE FINALE' and notice['boss'] and ('Chef de guerre orc' if faction=='alliance' else 'Maréchal de l’Alliance') in notice['detail']
    if state=='countdown_warning':
        notice=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('COUNTDOWN_NOTICE_SNAPSHOT=')))
        assert notice['visible'] and not notice['active'] and abs(notice['remaining']-3.2)<0.000001
        assert notice['title']==('FINALE DANS 4 S' if name.endswith('_countdown_final') else 'VAGUE 2 DANS 4 S')
        if name.endswith('_countdown_final'): assert ('Chef de guerre orc' if faction=='alliance' else 'Maréchal de l’Alliance') in notice['detail']
    if name=='boss_without_hover': assert 'BOSS_STATUS_WITHOUT_HOVER=true' in text,(name,text)
    if name in ['alliance_run_report','horde_run_report','horde_defender_summary'] or name.endswith('_loadout_summary'):
        report_folder=Path(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('RUN_REPORT_FOLDER=')))
        run_report=json.loads((report_folder/'rapport.json').read_text(encoding='utf-8'))
        assert run_report['game_version']==manifest['version'],(name,'Version du rapport différente du paquet')
        assert run_report['result']=='victory' and len(run_report['waves'])==10
        assert run_report['faction']==(0 if faction=='alliance' else 1)
        catalog=run_report['enemy_catalog']
        assert len(catalog)==8 and len({enemy['id'] for enemy in catalog})==8
        for enemy in catalog:
            assert enemy['origin']==('neutral' if enemy['profile'] in [0,2,3] else 'horde' if faction=='alliance' else 'alliance')
        assert run_report['boss_encounter']['name']==('Chef de guerre orc' if faction=='alliance' else 'Maréchal de l’Alliance')
        assert run_report['schema_version']==2 and len(run_report['performance'])==3
        if name.endswith('_loadout_summary'):
            assert len(run_report['meta_ranks'])==15 and sum(run_report['meta_ranks'])==33
            markdown=(report_folder/'rapport.md').read_text(encoding='utf-8')
            assert '## Talents permanents de la partie' in markdown and ('Bastion' if faction=='alliance' else 'Fureur de guerre') in markdown
        assert run_report['boss_encounter']['status']=='killed' and abs(run_report['boss_encounter']['removed_hp']-600)<0.000001
        assert 0<run_report['boss_encounter']['resolved_seconds']<=run_report['waves'][-1]['seconds']
        assert abs(sum(unit['boss_hp'] for unit in run_report['performance'])-600)<0.000001
        assert len([action for action in run_report['actions'] if action['kind']=='bonus_choice'])==3
        assert 'Bonus proposés' in (report_folder/'rapport.md').read_text(encoding='utf-8')
    if state:
        assert 'UI_VERSION='+manifest['version'] in text,(name,'Version embarquée différente du paquet')
        if state=='mission_scout':
            snapshot=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('SCOUT_SNAPSHOT=')))
            camp=0 if faction=='alliance' else 1;number=int(name.rsplit('_',1)[1])
            assert snapshot['isolated'] and snapshot['visible'] and snapshot['blocked'] and snapshot['unchanged']
            assert snapshot['faction']==camp and snapshot['mission']==number
            types=[1,0,2,3,4,5,6,7] if number==1 else [1,8,0,2,4,5,6,7]
            assert [e['type'] for e in snapshot['entries']]==types
            assert snapshot['names']==[e['name'] for e in snapshot['entries']]
            assert all(e['origin'] in ['neutral','horde' if camp==0 else 'alliance'] for e in snapshot['entries'])
            base_hp=[12,40,24,120,80,240,360,600,180]
            first={1:1,0:2,2:3,3:4,4:5,5:6,6:7,7:10,8:2}
            if number>1: first[0]=2
            for e,text_row in zip(snapshot['entries'],snapshot['details']):
                assert abs(e['max_hp']-base_hp[e['type']]*(99+number)/100)<0.000001
                assert e['first_wave']==first[e['type']] and 'Forteresse :' in text_row
            assert ('25 %' in snapshot['note'])==(number>10)
        if state=='shop_menu':
            snapshot=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('SHOP_COMPARISON_SNAPSHOT=')))
            camp=0 if faction=='alliance' else 1
            assert snapshot['isolated'] and snapshot['faction']==camp and snapshot['profile_unchanged']
            assert snapshot['balance']==(0 if name.endswith('_owned') else 420)
            assert snapshot['selected']==(7 if camp==0 else 9) if name.endswith('_owned') else snapshot['selected']==-1
            if '_comparison_' in name:
                index=int(name[-1]);assert snapshot['comparison'] and snapshot['index']==index
                base,alternative=[('Archer elfe','Rôdeur elfe'),('Arbalétrier nain','Mousquetaire nain'),('Lanceur de haches troll','Traqueur troll'),('Sapeur gobelin','Grenadier gobelin')][camp*2+index]
                assert snapshot['headers']==['Au niveau 1',base,alternative]
                expected=[
                    [['50 or','60 or'],['8','6'],['1 s','0,7 s'],['4','3,5']],
                    [['75 or','90 or'],['24','38'],['2,5 s','4 s'],['5','6']],
                    [['50 or','65 or'],['16','10'],['2 s','1,25 s'],['3,5','4'],['8','4'],['1 maximum','1 maximum'],['1','1']],
                    [['75 or','75 or'],['24','18'],['2,5 s','2 s'],['3','2,7'],['9,6','6'],['3 maximum','4 maximum'],['1','1,15']]][camp*2+index]
                assert [row[1:] for row in snapshot['rows']]==expected,snapshot['rows']
            else: assert not snapshot['comparison'] and snapshot['index']==-1
        assert 'CAPTURE_RESULT=0' in text,(name,text)
        if state=='wolf_walk':
            snapshot=json.loads(next(line.split('=',1)[1] for line in text.splitlines() if line.startswith('WOLF_SNAPSHOT=')))
            assert snapshot=={'isolated':True,'count':4,'faction':0 if faction=='alliance' else 1,'motion_schema':3}
        header=image.read_bytes()[:24]
        assert header[:8]==b'\x89PNG\r\n\x1a\n' and struct.unpack('>II',header[16:24])==(1280,800)
    results.append({'case':name,'exit_code':completed.returncode,'capture':state is not None})
report={'archive_sha256':hashlib.file_digest(archive.open('rb'),'sha256').hexdigest(),
        'scope':'selected' if args.selected_cases else 'all','available_cases':available_case_count,
        'executable_sha256':exe_hash,'files':members,'tests':results,
        'source_checks':source_count,'local_sources_compared':args.source_project is not None,
        'visual_review':'Captures produites ; inspection visuelle à consigner séparément.'}
(destination/'verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report,ensure_ascii=True,indent=2))
