"""Contrats numériques du GDD v0.14, sans moteur ni dépendance externe."""
import json
import re


def require(condition, detail):
    if not condition:
        raise ValueError(detail)


def number(cell):
    match = re.search(r'\d+(?:,\d+)?', cell)
    require(match is not None, 'Valeur numérique absente : ' + cell)
    return float(match[0].replace(',', '.'))


def cells(block):
    return [[cell.strip() for cell in line.strip('|').split('|')]
            for line in block.splitlines() if line.startswith('| ') and not line.startswith('| ---')]


def check_contracts(repo):
    scripts = repo / 'prototype/scripts'
    source = (scripts / 'valley_model.gd').read_text(encoding='utf-8')
    roster = json.loads('[' + source.split('const ROSTER: Array[Dictionary] = [')[1].split(']')[0].rstrip().rstrip(',') + ']')
    enemies = json.loads('[' + source.split('const ENEMY_TYPES: Array[Dictionary] = [')[1].split(']')[0].rstrip().rstrip(',') + ']')
    md = (repo / 'For_the_Fortress_GDD.md').read_text(encoding='utf-8')
    require(len(roster) == 6, 'Le contrat porte sur les six défenseurs du prototype.')
    for header, units in [('| Paramètre | Archer elfe | Arbalétrier nain | Mage humain |', roster[:3]),
                          ('| Paramètre | Lanceur de haches troll | Sapeur gobelin | Chaman orc |', roster[3:])]:
        rows = cells(md.split(header)[1].split('\n\n')[0])
        for label, field in [('Coût en or', 'price'), ('Dégâts principaux par attaque', 'damage'),
                             ('Intervalle entre attaques', 'interval'), ('Portée en unités de carte', 'range')]:
            row = next(row for row in rows if row[0].startswith(label))
            for index, unit in enumerate(units):
                require(unit[field] == number(row[index + 1]), f"GDD : {unit['name']} / {field}")
    rows = cells(md.split('| Ennemi provisoire | PV | Vitesse par seconde | Dégâts forteresse | Or |')[1].split('\n\n')[0])
    require(len(enemies) == len(rows) == 8, 'Nombre de profils ennemis différent du GDD.')
    for row, enemy in zip(rows, enemies):
        for cell, field in zip(row[1:], ['hp', 'speed', 'fortress_damage', 'reward']):
            require(enemy[field] == number(cell), f"GDD : {enemy['name']} / {field}")
    require(roster[5]['curse_damage'] == 4.8, 'Malédiction de base différente de 4,8.')
    progression = (scripts / 'progression_data.gd').read_text(encoding='utf-8')
    branches = json.loads('[' + progression.split('const BRANCHES: Array[Dictionary] = [')[1].split(']')[0].strip() + ']')
    require(len(branches) == 12, 'Le contrat porte sur les douze branches du prototype.')
    branch_values = 0
    for index, branch in enumerate(branches):
        row = next(line for line in md.splitlines() if line.startswith('| ' + ('A' if index % 2 == 0 else 'B') + ' — ' + branch['name'] + ' |'))
        values = [cell.strip() for cell in row.strip('|').split('|')][1:]
        fields = ['damage', 'interval', 'range'] if index < 4 else ['damage', 'secondary_damage', 'secondary_cap', 'radius'] if index < 10 else ['damage', 'curse_damage', 'curse_damage']
        for cell, field in zip(values, fields):
            require(branch[field] == number(cell), f"GDD : {branch['name']} / {field}")
            branch_values += 1
    campaign = (scripts / 'campaign_data.gd').read_text(encoding='utf-8')
    waves = json.loads(campaign.split('const WAVES: Array = ')[1].split('\n]')[0] + '\n]')
    rows = cells(md.split('| Vague | Groupes dans l’ordre d’apparition | Intervalles internes | Or maximal | Cumul maximal |')[1].split('\n\n')[0])
    require(len(rows) == len(waves) == 10, 'Nombre de vagues différent du GDD.')
    groups_checked = 0
    for row, groups in zip(rows, waves):
        descriptions, intervals = row[1].split(' → '), row[2].split(' / ')
        require(len(groups) == len(descriptions) == len(intervals), 'Groupes différents pour la vague ' + row[0])
        for (type_id, quantity, interval), description, delay in zip(groups, descriptions, intervals):
            require(int(description.split()[0]) == quantity, 'Quantité différente : ' + description)
            require(enemies[type_id]['name'].casefold() in description.casefold(), 'Type différent : ' + description)
            require(interval == (0 if delay == 'unique' else float(delay.removesuffix(' s').replace(',', '.'))), 'Intervalle différent : ' + description)
            groups_checked += 1
    return {'defender_values': 24, 'enemy_values': 32, 'branch_values': branch_values, 'wave_groups': groups_checked}
