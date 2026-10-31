# Chapitre 2 — essai de la tortue gardienne (v0.102)

## Statut

**V :** introduire un nouvel attaquant de biome aux missions 11–20 ; envisager des rôles autres que PV/vitesse, dont soin, protection et absorption. Une tortue est la piste visuelle discutée. **H :** rôle Gardienne recommandé pour cet essai, nom, chiffres, séquence et présentation. Le porteur hésite encore entre Gardienne et Protectrice ; la recommandation n’est pas une validation définitive.

La Gardienne reçoit une partie des dégâts de ses voisins à leur place, tandis qu’une Protectrice réduirait les dégâts sans les recevoir. Seule la Gardienne est essayée ici.

## Règles du prototype

| Paramètre | Valeur provisoire |
| --- | --- |
| Identité | Tortue gardienne des berges, faune neutre commune aux deux factions |
| PV de référence | 180, contre 120 pour l’ours ; 198 à la mission 11, 214,2 à la mission 20 |
| Vitesse | 0,8 unité logique/s |
| Dégâts à la forteresse | 2 PV si elle l’atteint |
| Récompense d’élimination | 8 or de combat, sans PO/XP supplémentaires |
| Rayon de protection | 2 unités logiques, distance réelle dans le plan avant projection, borne incluse |
| Transfert | 25 % des dégâts infligés aux voisins éligibles, dans la limite de ses PV disponibles |

Exemple : un voisin doit recevoir 40 dégâts. Il en reçoit 30 et la tortue en reçoit 10. Si elle n’a plus que 2 PV disponibles, elle encaisse 2 et le voisin reçoit 38. Rien ne disparaît : les dégâts sont conservés.

Les dégâts directement reçus par la tortue sont réservés d’abord. Si plusieurs voisins sont frappés simultanément et que les PV restants ne couvrent pas tout, l’absorption est répartie proportionnellement. Un impact qui tue directement la tortue empêche sa protection à cet instant. L’absorption peut la tuer ; sa récompense n’est attribuée qu’une fois.

Une seule tortue, la plus proche, protège chaque victime. Égalité de distance : ID d’apparition le plus petit. Ni autoprotection, ni protection des autres tortues, ni protection du boss. Aucun cumul, boucle de renvoi, soin, provocation ou nouvelle priorité de ciblage. Les impacts directs, explosions, rebonds et dégâts périodiques suivent la même règle. Le bonus de dégâts est calculé pour la victime initiale puis partagé ; aucune seconde application sur la tortue. Les statistiques de performance conservent la source et la composante du coup, en comptant les pertes réelles de chaque cible.

Le cercle autour de la tortue montre son rayon. Un trait bref entre victime et tortue signale un transfert réel ; sa barre de vie baisse. L’aperçu de vague explique la capacité au survol, l’inspection rappelle le transfert. Le cercle n’est pas une armure et ne représente pas une zone bloquant les projectiles.

## Contenu de l’essai

Missions 11–20 : dix missions de dix vagues, deuxième chapitre du même biome. Les dix tracés du chapitre 1 sont réutilisés pour comparer l’effet des rencontres ; ce ne sont pas dix nouvelles géométries. Les premières tortues arrivent à la vague 2, après une vague d’échauffement ; elles réapparaissent aux vagues 4, 5, 6, 8, 9 et 10. La séquence est commune au chapitre ; les identités adverses restent propres à la faction jouée.

PV ennemis : 110 % à la mission 11 jusqu’à 119 % à la mission 20, conformément à la courbe linéaire d’essai. Première victoire : 60 PO et 100 XP par mission et faction. Rejouer ou perdre ne donne aucun nouveau gain. Le déblocage reste séquentiel, chaque mission repart à neuf. Les missions 1–10 conservent leurs vagues et statistiques ; missions 21–200 encore à venir. L’infini et les autres difficultés ne deviennent pas jouables avec ce lot.

Le jeu de rencontres est enregistré dans les rapports de diagnostic du chapitre 2 et contrôlé au rejeu ; les rapports historiques sans ce champ utilisent les anciennes vagues. Aucun changement de schéma de progression ni remise à zéro des sauvegardes.

## Illustration

`prototype/assets/enemies/rosters/tortue_gardienne_v001.png` : illustration originale générée avec ImageGen à partir de la direction cartoon du projet, le 31 octobre 2026. PNG transparent original conservé ; cadre de rendu et ancrage définis dans `enemy_art.gd`. Pas de reprise d’un personnage ou asset de World of Warcraft. Apparence encore ajustable ; aucune animation dessinée supplémentaire annoncée dans ce lot.

## À évaluer avec le joueur

- Choix définitif Gardienne ou Protectrice, puis PV, rayon et taux de transfert.
- Lisibilité du cercle et des traits sur un groupe dense ; rythme des vagues et compositions.
- Influence des talents disponibles au chapitre 2 et des alternatives de boutique.
- Nouvelles géométries ou variantes de rencontres nécessaires pour différencier davantage les missions du chapitre.

Les contrôles automatiques démontrent le fonctionnement et la reproductibilité, pas un équilibrage définitif ni un taux de victoire humain. Le chantier d’animation des unités, des forteresses et des souverains figure séparément dans la [feuille de route](Feuille_de_route_long_terme.md).

## Vérifications et limites de la livraison

Régression complète : **86 suites, 33 837 contrôles Godot, 17 tests Python**. Les tests couvrent le plafonnement, les morts simultanées, les dégâts périodiques, la conservation des dégâts et leur attribution, la portée, les exclusions, le rejeu et l’indépendance du pas de simulation. [Rapport exact](essais/v0102_regression.json).

Paquet Windows : **16 cas ciblés sur 245 disponibles, 15 captures et 59 sources comparées**, avec les deux factions, la Gardienne, les profils protégés, les gains, les rapports et le passage mission 10 → 11. L’ensemble des 245 cas natifs n’a pas été exécuté. Le dernier ajustement du vérificateur concerne cette transition ; il est contrôlé par les deux parcours natifs après la régression complète. [Rapport natif](Distribution_Windows_v0102.json), [contrôles complémentaires](essais/v0102_validation_complementaire.json).

Deux vues du chapitre 2 ont été produites avec le moteur complet chargé sur les ressources exportées : 30 contrôles de taille de texte par faction et lancement isolé de la mission 11. Le menu Alliance et les vues de Gardienne des deux factions ont été inspectés visuellement. [Chapitre 2 Alliance](essais/captures/QA-v0102_chapitre_2_Alliance.png), [Gardienne Horde](essais/captures/QA-v0102_gardienne_Horde.png).

Quarante simulations avec le placement fixe du test du chapitre 1 donnent 10 victoires Alliance et 3 Horde sans talent, puis 10 Alliance et 4 Horde avec cinq points dans le premier talent. Une recherche de placements utilisant la politique du test des trois premières missions trouve ensuite une victoire pour chacune des dix missions et des deux factions, avec ces cinq points, en 44 tentatives. Les deux politiques diffèrent aussi par leur ordre de recrutement et leur calendrier d’améliorations : aucune causalité unique ni taux de victoire humain ne peut en être déduit. [Données du placement fixe](essais/v0102_gardienne_politique_fixe.json), [exemples gagnants](essais/v0102_gardienne_victoires.json). Les PV restants des exemples Horde vont de 1 à 15 : l’équilibrage demande un retour humain.

Progression au même schéma, identité de sauvegarde inchangée ; aucune remise à zéro. La texture sombre du mousquetaire conserve son empreinte. Les animations et variantes de chemins demandées sont uniquement planifiées dans ce lot.
