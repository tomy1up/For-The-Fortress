# Consignes et provenance des dessins du virage

Outil : **ImageGen intégré**, via le skill imagegen. Fond transparent demandé et conservé. Aucun appel par CLI ou API externe. Les fichiers retenus sont copiés sans édition ultérieure de leurs pixels.

| Dessin | Résultat retenu sous `C:/Users/Tomy/.codex/generated_images/01a155cb-cefa-7193-a478-f2a27c0d25b0/` | Consigne |
| --- | --- | --- |
| Face | `exec-3fa0f191-ff38-45fe-a36d-284ce0887c2d.png` | [Texte complet](PROMPT_face.txt) |
| Trois quarts avant | `exec-7a58f6a3-e950-4bbc-ab30-beadf39e4657.png` | [Texte complet](PROMPT_trois_quarts.txt) |
| Trois quarts arrière corrigé | `exec-e3b9dee9-21fd-4826-af91-280bf7e252a2.png` | [Création](PROMPT_arriere.txt), puis [correction anatomique](PROMPT_correction_arriere.txt) |

La création de face utilise `../sanglier_peau_continue/sanglier_proche_source_v001.png` comme référence d’identité. Le trois quarts avant utilise cette référence et la nouvelle face. L’arrière utilise le profil et le trois quarts avant.

Le premier arrière, `exec-762eca05-7ef6-4e9b-94ce-41cbd2cea68f.png`, est rejeté pour un cinquième membre sous le ventre. Il reste dans l’archive de génération locale et n’est pas copié comme asset du projet. La correction utilise ce résultat comme cible et retire précisément le membre supplémentaire. Le fichier corrigé est ensuite conservé sous `sanglier_arriere_trois_quarts_source_v001.png`.

Les demandes de conserver l’identité, les couleurs et les proportions expriment l’objectif du prompt. Elles ne prouvent pas à elles seules qu’une image générée le satisfait. L’autocontrôle et les limites du résultat figurent dans le README et `QA_construction.json`. Aucun de ces dessins n’est approuvé artistiquement par le porteur.
