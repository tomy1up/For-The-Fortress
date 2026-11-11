# Mage humain · lancement du sort

L’animation reprend la silhouette du mage. Le cristal s’illumine au départ du projectile, la main libre prolonge le geste et la lumière se dissipe pendant le retour en position. Le bâton et le point d’appui restent fixes. Le geste de la main reste discret à taille de jeu. [Animation en combat](essais/mage_incantation/Incantation.gif) · [Étapes du lancement](essais/mage_incantation/Incantation_etapes.png)

La planche `defender.alliance.mage/attack.png` contient 12 images de 320 × 288 px sur 0,40 s simulée. Le premier éclat coïncide avec le départ du sort. Le cristal reste aligné sur le point de départ historique du projectile, retourné par le jeu selon le côté du tir. La pose fixe reprend le relais à la fin. Le travail porte sur le lancement du sort. L’explosion garde son effet actuel.

Quatre séquences de tirs réels ont été capturées en vague 1 au Gué, avec un profil isolé sur l’écran de droite. Le mage tire à gauche depuis E1 et à droite depuis E4. La capture échantillonne les 12 images à ×1 et 6 images à ×2. Le validateur passe et la régression ciblée compte 12 038 contrôles Godot et 17 tests Python, dont la suite du décor après synchronisation avec Claude.
