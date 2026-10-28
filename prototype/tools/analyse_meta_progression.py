"""Synthèse d'un audit de politiques fixes, sans toucher au jeu ni au profil."""
from pathlib import Path
import argparse, json, statistics, math

def analyse(data):
    rows=data['rows']; assert len(rows)==data['scenarios']==data['budget_checks']==512
    assert not data['human_test'] and not data['profile_loaded']
    assert len({(r['faction'],r['build'],r['layout'],r['seed']) for r in rows})==512
    for row in rows:
        expected=row['completed']*(row['completed']+1)//2+(data['victory_bonus'] if row['victory'] else 0)
        assert row['resource']==expected and row['full_preparation_seconds']==30*(row['reached']-1)
    lines=['# Audit de progression — prototype v'+data['game_version'],'',
        '28 octobre 2026. Mesures automatisées de politiques fixes ; aucun joueur humain, aucune modification de profil et aucun changement de règles.', '',
        '## Protocole', '',
        '512 scénarios : deux factions, quatre configurations de talents, deux placements et 32 graines (1 à 32). Capital normal de 150 or. Deux premières recrues au départ, troisième type à partir de la vague 4 si le budget le permet ; amélioration d’un niveau par défenseur et par préparation à partir de la vague 5, spécialité finale de branche 0. Chaque choix de bonus prend la première offre. Les 512 bilans économiques sont contrôlés.', '',
        'Les configurations sont injectées uniquement dans le modèle de contrôle : zéro point ; cinq points dans la première base ; quinze points dans les trois bases ; trente-six points, spécialités finales orientées impact. Il ne s’agit pas de la simulation d’un joueur achetant progressivement ces points.', '',
        'Placement référence : E1, E2, E3. Placement réparti : E2, E4, E6. Les trois classes gardent le même ordre. Les durées ci-dessous supposent le combat à ×1 et les trente secondes complètes avant chaque vague suivante ; elles excluent les temps humains de choix. Un lancement manuel anticipé ou une vitesse différente change ces durées.', '',
        '## Résultats', '',
        '| Faction | Points | Placement | Victoires / 32 | Ressources moyennes | PV finaux médians | Durée médiane ×1, min |',
        '| --- | --- | --- | --- | --- | --- | --- |']
    summary=[]
    for faction in range(2):
        for build in ['zero','base_5','bases_15','impact_36']:
            for layout in ['reference','reparti']:
                group=[r for r in rows if (r['faction'],r['build'],r['layout'])==(faction,build,layout)]
                assert len(group)==32
                cell={'faction':faction,'build':build,'points':group[0]['points'],'layout':layout,'runs':32,
                    'wins':sum(r['victory'] for r in group),'resource_mean':statistics.mean(r['resource'] for r in group),
                    'hp_median':statistics.median(r['hp'] for r in group),
                    'minutes_median':statistics.median((r['combat_seconds']+r['full_preparation_seconds'])/60 for r in group)}
                summary.append(cell)
                values=['Alliance' if faction==0 else 'Horde',str(cell['points']),'Référence' if layout=='reference' else 'Réparti',str(cell['wins']),f"{cell['resource_mean']:.2f}".replace('.',','),f"{cell['hp_median']:g}".replace('.',','),f"{cell['minutes_median']:.2f}".replace('.',',')]
                lines.append('| '+' | '.join(values)+' |')
    zero_reference=[r for r in rows if r['build']=='zero' and r['layout']=='reference']
    zero_other=[r for r in rows if r['build']=='zero' and r['layout']=='reparti']
    lines+=['', '## Lecture et limites', '',
        f"La stratégie de référence gagne sans talent dans {sum(r['victory'] for r in zero_reference)}/{len(zero_reference)} essais. Le placement réparti n’obtient que {sum(r['victory'] for r in zero_other)}/{len(zero_other)} victoires sans talent. Les talents améliorent fortement ce second placement dans les configurations testées, mais ne remplacent pas une bonne composition spatiale. Ces taux décrivent ces politiques et ces graines ; ils ne sont pas des taux de réussite de nouveaux joueurs.", '',
        'L’intention d’une première victoire très difficile n’est donc pas garantie par un verrou de puissance dans le prototype actuel. La politique connue atteint la victoire sans progression permanente. Cela ne suffit pas à conclure que les premières parties humaines sont faciles, ni à justifier une hausse immédiate des PV ennemis ou du temps de collecte.', '',
        f"Le plafond actuel représente {data['point_price']*data['max_points']} ressources par faction ({data['max_points']} points à {data['point_price']} ressources). Une victoire complète verse 60 ressources : six victoires parfaites suffisent arithmétiquement à financer ce plafond sans frais de respécialisation. Ce n’est ni une prévision de durée humaine, ni une simulation d’acquisition progressive. Deux monnaies séparées ne créent pas deux fois plus de contenu.", '',
        'Une seule carte, deux placements, une politique économique et les finales de branche 0 sont couverts. Les autres placements, décisions, arbres, joueurs, difficultés futures et cartes restent hors échantillon. Les choix d’interface, la fermeture en cours de partie et la persistance ne sont pas simulés ici ; leurs contrôles restent dans les suites du jeu.', '',
        '## Suites à cadrer', '',
        'Confronter ces résultats à des premières parties humaines sans talent, puis à des configurations modestes. Fixer ensuite le rythme visé de ressources et le périmètre des difficultés/cartes avant de modifier les chiffres. Les coûts, talents et récompenses restent provisoires. Aucun nouveau système, difficulté ou contenu n’est approuvé par cet audit.', '',
        '## Reproduire', '',
        'Depuis la racine du dépôt, lancer Godot 4.7.2 en mode headless avec le projet prototype, le script res://tools/survey_meta_progression.gd et un argument utilisateur --output=<nouveau fichier JSON hors des données du joueur>. Le script refuse une destination existante ou située dans le répertoire utilisateur du jeu.', '',
        'Exécuter ensuite prototype/tools/analyse_meta_progression.py <rapport.json> --markdown <synthese.md>. Les scripts ne sont pas inclus dans le jeu distribué. [Données](essais/v078_meta_progression.json).', '']
    return '\n'.join(lines),summary

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('report',type=Path);p.add_argument('--markdown',type=Path,required=True);args=p.parse_args()
    text,summary=analyse(json.loads(args.report.read_text(encoding='utf-8')))
    if args.markdown.suffix.lower()!='.md' or args.markdown.exists():
        raise ValueError('Choisir un nouveau fichier Markdown ; aucune destination existante ne sera écrasée.')
    args.markdown.write_text(text,encoding='utf-8')
    print(json.dumps({'groups':len(summary),'scenarios':512,'markdown':str(args.markdown)},ensure_ascii=True))
