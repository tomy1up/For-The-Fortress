# Socle des difficultés Héroïque et Mythique (v0.257)

**Statut.** Lot 1 du cadrage du 25 novembre 2026 (`Cadrage_Heroique_Mythique_2026-11-25.md`), lancé par le porteur le 25 novembre 2026 (« Lance le lot 1 »). La hausse de PV et les PO de l'Héroïque sont des réglages de prototype à confirmer. Les champions mutants, le cumul des nouveautés, les bonus héroïques et le calibrage viennent dans les lots suivants.

## Ce qui est en place

- **Trois onglets** dans l'écran de campagne : Normal, Héroïque, Mythique. Chaque onglet montre sa propre progression (chapitres, missions réussies, mission conseillée).
- **Ouverture** (CAMP-020, décidé le 31 octobre 2026), faction par faction :
  - l'Héroïque s'ouvre quand les 100 premières missions du Normal sont réussies ;
  - le Mythique s'ouvre quand les 100 premières de l'Héroïque le sont.
  - Un onglet verrouillé affiche sa condition, par exemple « Héroïque verrouillé · 99 / 100 premières missions réussies en Normal ».
- **Héroïque jouable** : les mêmes 200 missions (cartes, vagues, renforts, affixes), débloquées une à une, avec :
  - PV ennemis du Normal × 1,3 (`HEROIC_HP_PERCENT`), réglage provisoire que le lot 5 remplacera par un calibrage mission par mission ;
  - à la première victoire, les PO du Normal majorées de moitié (`HEROIC_PO_PERCENT`), sans XP. C'est une proposition de Claude Code à confirmer par le porteur.
- **Mythique** : son onglet existe, mais il n'est pas encore jouable. Il affiche « Course par chapitre : règles en préparation » (lot 6).
- **En partie** : le titre de la carte et le bilan portent la mention « Héroïque ». La préparation de mission (« Voir les ennemis ») montre les PV de la difficulté.

## Technique

- **Progression** : chaque difficulté a ses propres identifiants de mission (`campaign.011` en Normal, `heroic.011` en Héroïque, `mythic.011` en Mythique). Les réussites et les reçus de PO restent donc séparés dans le profil, **sans migration** : tout ce qui existait reste du Normal. `MetaProfile.campaign_status(faction, difficulty)`, `campaign_statuses(faction)`.
- **Catalogue** :
  - `CampaignCatalogue.difficulty_for`, `difficulty_open`, `difficulty_playable` ;
  - `reward_po_for` et `reward_xp_for` ;
  - `faction_hp_percent(number, faction, difficulty)`.
- **Partie** : `ValleyModel.difficulty` et `configure_difficulty`. Le rapport porte `difficulty` hors du Normal, refusé au rejeu avant la v0.257.
- **Limite des PV ennemis** relevée de 400 à 800 %, puisque les PV héroïques dépassent les 370 % du Normal.
- Tests : `prototype/tests/test_difficulties.gd`. Captures : option `--capture-difficulty=N` du menu de campagne.

## Limites

- Au lot 1, l'Héroïque n'est qu'un Normal aux PV relevés : la nouveauté (champions mutants, bonus héroïques) et le cumul arrivent aux lots 2 à 4.
- La hausse de 30 % n'est pas calibrée : certaines missions seront trop dures ou trop faciles d'ici le lot 5.
- Le rapport d'une partie ne porte pas l'identifiant de mission. Au lot 1, la difficulté ne change rien d'autre au combat que les PV, déjà enregistrés à part. Le rejeu ne peut donc pas encore détecter son retrait ; il le pourra quand les champions en dépendront.
