"""Contrôle et synthèse des politiques fixes du premier échantillon de campagne."""
from pathlib import Path
from collections import Counter, defaultdict
from itertools import product
import argparse
import json
import re


def key(row):
    return tuple(row[field] for field in (
        'faction', 'mission', 'seed', 'layout', 'composition', 'early_upgrade_wave', 'talent'))


def validate(data):
    if data.get('schema') != 1 or data.get('human_balance_test') is not False or data.get('profile_loaded') is not False:
        raise ValueError('Rapport de comparaison automatique attendu, sans profil joueur.')
    rows = data['results']
    smoke = data.get('smoke_replays') is True
    seeds = [42] if smoke else [7, 42, 2026]
    expected = set()
    for faction, mission, seed, layout, composition, early in product(
            range(2), range(1, 4), seeds, [1] if smoke else range(6),
            [0] if smoke else range(4), [2] if smoke else [1, 2, 3]):
        for talent in [-1, 0, 5, 10] if mission == 3 else [-1]:
            expected.add((faction, mission, seed, layout, composition, early, talent))
    if len(rows) != data['case_count'] or len(rows) != len(expected) or {key(row) for row in rows} != expected:
        raise ValueError('Scénarios absents, répétés ou hors du périmètre annoncé.')
    for row in rows:
        if row['enemy_hp_percent'] != 99+row['mission']:
            raise ValueError('PV ennemis différents de la mission annoncée.')
        if row['map_id'] != ['valley_ford', 'ford_woods', 'ford_heights'][row['mission']-1]:
            raise ValueError('Carte différente de la mission annoncée.')
        if row['points'] != (0 if row['talent'] == -1 else 1):
            raise ValueError('Nombre de points inattendu.')
        if row['gold'] < 0 or row['gold'] != 150+row['income']-row['spent']:
            raise ValueError('Conservation du budget de combat incorrecte.')
        if row['result'] not in ('victory', 'defeat') or not 1 <= row['reached_wave'] <= 10:
            raise ValueError('Partie non terminée.')
        if row['hp'] < 0 or row['hp'] > row['max_hp'] or (row['hp'] > 0) != (row['result'] == 'victory'):
            raise ValueError('PV de fin incohérents avec le résultat.')
        if row['result'] == 'victory' and row['reached_wave'] != 10:
            raise ValueError('Victoire avant la dixième vague.')
    if not data.get('sources_sha256') or any(not isinstance(value, str) or re.fullmatch('[0-9a-f]{64}', value) is None for value in data['sources_sha256'].values()):
        raise ValueError('Empreintes des sources absentes.')
    return rows


def summary(data):
    rows = validate(data)
    by_key = {key(row): row for row in rows}
    base = [row for row in rows if row['points'] == 0]
    lines = [
        '# Comparaison des trois missions du prototype', '',
        f"Jeu {data['game_version']} ; {format(len(rows), ',').replace(',', ' ')} simulations de politiques fixes, sans profil joueur ni changement d’équilibrage.", '',
        '**Ce tableau ne mesure pas le taux de victoire des joueurs.** Les mêmes décisions mécaniques sont répétées sur six triplets d’emplacements, quatre compositions, trois moments de tentative d’amélioration et trois graines de tirage. Les compositions, branches et choix de bonus couverts ne représentent pas toutes les stratégies possibles.', '',
        '## Sans talent persistant', '',
        '| Faction | Mission | Victoires / cas | Politiques gagnantes sur les 3 graines | Politiques au résultat variable | Défaites par vague atteinte |',
        '| --- | --- | --- | --- | --- | --- |',
    ]
    totals = []
    for faction, mission in product(range(2), range(1, 4)):
        selected = [row for row in base if row['faction'] == faction and row['mission'] == mission]
        policies = defaultdict(list)
        for row in selected:
            policies[(row['layout'], row['composition'], row['early_upgrade_wave'])].append(row['result'] == 'victory')
        wins = sum(row['result'] == 'victory' for row in selected)
        stable = sum(all(values) for values in policies.values())
        variable = sum(any(values) and not all(values) for values in policies.values())
        failures = Counter(row['reached_wave'] for row in selected if row['result'] == 'defeat')
        record = {'faction': faction, 'mission': mission, 'wins': wins, 'cases': len(selected),
                  'policies_all_seeds_won': stable, 'policies_variable': variable, 'defeat_waves': dict(sorted(failures.items()))}
        totals.append(record)
        detail = ', '.join(f'vague {wave} : {count}' for wave, count in sorted(failures.items())) or 'Aucune'
        lines.append(f"| {['Alliance', 'Horde'][faction]} | {mission} | {wins} / {len(selected)} | {stable} / {len(policies)} | {variable} / {len(policies)} | {detail} |")
    lines += ['', 'Les différences entre missions combinent changement de tracé, positions et PV. Elles ne permettent pas d’attribuer à la seule hausse de 1 % les victoires ou défaites. Un résultat variable montre la sensibilité de cette politique aux trois tirages testés, sans mesurer la probabilité de victoire humaine.', '',
              '## Premier point en mission 3', '',
              'Les trois choix de premier talent sont évalués séparément : un seul point investi à la fois, tel qu’obtenable après les deux premières victoires. Chaque essai est comparé à la même faction, au même placement, à la même composition, à la même tentative d’amélioration et à la même graine sans talent.', '',
              '| Faction | Premier talent | Victoires / cas | Défaite devenue victoire | Victoire devenue défaite |',
              '| --- | --- | --- | --- | --- |']
    paired = []
    for faction, talent in product(range(2), [0, 5, 10]):
        selected = [row for row in rows if row['faction'] == faction and row['talent'] == talent]
        gained = lost = wins = 0
        for row in selected:
            baseline = by_key[key(row)[:-1]+(-1,)]
            won = row['result'] == 'victory'; before = baseline['result'] == 'victory'
            wins += won; gained += won and not before; lost += before and not won
        name = selected[0]['talent_name']
        paired.append({'faction': faction, 'talent': talent, 'name': name, 'cases': len(selected),
                       'wins': wins, 'defeat_to_victory': gained, 'victory_to_defeat': lost})
        lines.append(f"| {['Alliance', 'Horde'][faction]} | {name} | {wins} / {len(selected)} | {gained} | {lost} |")
    coverage = ('Des politiques sans talent gagnent les trois missions dans les deux factions.'
                if all(item['wins'] > 0 for item in totals)
                else 'Certaines paires faction/mission n’ont aucune victoire parmi ces politiques fixes ; ce résultat ne prouve pas que leur mission est impossible.')
    alliance = {item['mission']: item['wins'] for item in totals if item['faction'] == 0}
    comparison = (' Pour l’Alliance, la troisième carte est plus favorable que la deuxième aux politiques testées, malgré ses PV ennemis supérieurs.'
                  if alliance[3] > alliance[2] else '')
    defeats = [row for row in base if row['result'] == 'defeat']
    boss_note = ('La plupart des défaites couvertes surviennent avant la vague finale. '
                 if sum(row['reached_wave'] < 10 for row in defeats) > len(defeats)/2 else '')
    lines += ['', '## Lecture des résultats', '',
              coverage+comparison+' Il faut comparer la couverture et les compositions, et pas seulement ajuster les PV.', '',
              'Le premier point peut changer certains résultats sans annuler l’intérêt du placement et des unités. Ces relevés n’autorisent pas à conclure qu’un arbre est globalement supérieur : seuls trois talents d’entrée à un rang sont évalués, avec quatre compositions et une politique de bonus imposée. Les talents majeurs et les builds avancés ne sont pas couverts.', '',
              boss_note+'Le niveau de pression du boss reste à confronter à des parties humaines ; sa survie ou sa mort dans ces stratégies n’est pas une validation de ses sensations de combat.', '',
              '## Compositions et emplacements', '',
              '| Composition | Alliance dans l’ordre de recrutement | Horde dans l’ordre de recrutement |',
              '| --- | --- | --- |',
              '| A | Archer, arbalétrier, mage | Lanceur de haches, sapeur, chaman |',
              '| B | Archer, mage, arbalétrier | Lanceur de haches, chaman, sapeur |',
              '| C | Deux arbalétriers, puis archer | Deux sapeurs, puis lanceur de haches |',
              '| D | Deux archers, puis mage | Deux lanceurs de haches, puis chaman |', '',
              'Triplets testés, dans l’ordre des recrutements : E1/E2/E3, E2/E3/E5, E2/E4/E5, E1/E3/E5, E3/E5/E6 et E3/E4/E6. Les identifiants d’emplacements restent les mêmes, mais leurs positions dépendent de la carte. Les autres emplacements ne sont pas utilisés par ces politiques.', '',
              '## Politique et limites', '', data['policy'], '',
              'Une demande d’amélioration refusée faute d’or n’est pas forcée ; aucune ressource ne s’ajoute au budget du jeu. Les branches A et le premier bonus proposé sont choisis par cette politique : elle n’adapte pas ses achats à la vague, ne vend pas, n’utilise que trois emplacements et peut gaspiller de l’or ou du potentiel. Une défaite ne prouve donc pas qu’une carte est impossible.', '',
              'Le contrôle rapide de douze scénarios compare aussi de petits et grands pas de simulation et rejoue les rapports complets. Le grand relevé contrôle le budget et le résultat terminal de chaque cas, mais ne rejoue pas 2 592 rapports. Les sources de réalisation sont identifiées par leurs empreintes ; aucun profil joueur, sauvegarde, achat en boutique ou économie de campagne n’est simulé.', '',
              '## Suite du travail', '',
              'Comparer ces situations aux essais humains, en relevant les placements, bonus et choix de talents. Prioriser les difficultés de compréhension avant toute modification de statistiques. Le barème de PV, les talents et les cartes restent des réglages de prototype ; aucune hausse générale de puissance ni nouvelle règle n’est déduite de cet audit.', '',
              '## Reproduire', '',
              'Lancer Godot 4.7.2 en mode headless avec le projet `prototype`, le script `res://tools/survey_campaign_sample.gd`, puis `-- --output=<nouveau fichier JSON hors du profil joueur>`. Ajouter `--smoke` pour les douze cas avec rejeu, et `--small-steps` pour les vérifier à pas de 0,05 seconde. Le relevé complet conserve trois graines : 7, 42 et 2026.', '',
              'Exécuter ensuite `prototype/tools/analyse_campaign_sample.py <rapport.json> --markdown <nouvelle synthèse.md> --summary <nouvelle synthèse.json>`. Les sorties doivent être nouvelles. Ces outils de conception ne sont pas nécessaires pour lancer le jeu Windows.', '']
    return '\n'.join(lines), {'schema': 1, 'game_version': data['game_version'], 'case_count': len(rows),
                                'human_balance_test': False, 'zero_points': totals, 'first_point_pairs': paired}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('report', type=Path)
    parser.add_argument('--markdown', required=True, type=Path)
    parser.add_argument('--summary', required=True, type=Path)
    args = parser.parse_args()
    targets = [args.markdown.resolve(), args.summary.resolve()]
    if targets[0] == targets[1] or any(path.exists() for path in targets):
        parser.error('Les deux destinations doivent être nouvelles et distinctes.')
    data = json.loads(args.report.read_text(encoding='utf-8'))
    if data.get('smoke_replays'):
        parser.error('Utiliser le relevé complet pour la synthèse, pas les seuls témoins.')
    markdown, result = summary(data)
    args.markdown.write_text(markdown, encoding='utf-8', newline='\n')
    args.summary.write_text(json.dumps(result, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    print(f"CAMPAIGN_ANALYSIS_OK={result['case_count']}")


if __name__ == '__main__':
    main()
