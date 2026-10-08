# Documentation

Ce document donne les détails pratiques pour utiliser les conventions du dépôt.
Le README principal explique le but du projet ; ce fichier explique comment
appliquer les outils.

La version anglaise est disponible dans [DOCUMENTATION.md](DOCUMENTATION.md).

## Version

Cette documentation s'applique à la version 1.6.1. Le détail de la version est
consigné dans [CHANGELOG.md](CHANGELOG.md).

## Formatage Perl avec perltidy

Ce dépôt fournit un fichier `.perltidyrc` à la racine. C'est la configuration de
formatage de référence pour le code Perl et elle doit être utilisée telle quelle.

`perltidy` cherche automatiquement `.perltidyrc` dans le répertoire courant. Il
suffit donc de lancer les commandes depuis la racine du dépôt.

## Signatures Perl

Quand une nouvelle fonction ou un refactoring ciblé possède des paramètres dont
le sens devient plus clair avec des signatures, les activer explicitement dans
le fichier :

```perl
use feature 'signatures';
```

Utiliser les signatures pour améliorer la lisibilité, pas comme une règle de
réécriture mécanique. Garder le code simple lorsqu'il l'est déjà, et respecter
le style existant des fichiers qui n'utilisent pas encore les signatures sauf
si le refactoring en bénéficie clairement.

## Prévisualiser le formatage

Pour afficher le code formaté dans le terminal sans modifier le fichier source :

```bash
perltidy -st -se chemin/vers/script.pl
```

`-st` envoie le code formaté vers la sortie standard. `-se` envoie les erreurs
et avertissements vers la sortie d'erreur standard.

## Formater un fichier

Pour reformater un fichier en place et conserver une sauvegarde `.bak` :

```bash
perltidy -b chemin/vers/script.pl
```

Pour reformater un fichier en place sans créer de sauvegarde :

```bash
perltidy -b -bext='/' chemin/vers/script.pl
```

## Formater plusieurs fichiers

Pour formater tous les scripts Perl du répertoire courant :

```bash
perltidy -b *.pl
```

Pour les projets plus grands, préférer des chemins explicites ou la commande de
test ou de formatage déjà fournie par le projet, si elle existe.

## Valider sans modifier les sources

Pour vérifier que `perltidy` peut traiter des fichiers sans écrire à côté des
sources :

```bash
mkdir -p /tmp/perltidy-check
perltidy -se -opath=/tmp/perltidy-check chemin/vers/script.pl
```

`-opath=/tmp/perltidy-check` écrit le résultat formaté dans un autre répertoire
au lieu de modifier les fichiers du dépôt.

## Résumé des options

`-b` formate les fichiers en place et crée des sauvegardes `.bak`.

`-bext='/'` désactive la création de sauvegarde quand `-b` est utilisé.

`-st` écrit le code formaté vers la sortie standard.

`-se` écrit les erreurs et avertissements vers la sortie d'erreur standard.

`-opath=DIR` écrit les fichiers formatés dans un autre répertoire.

`-pro=FILE` sélectionne un fichier de configuration perltidy précis. Ce n'est
généralement pas nécessaire depuis la racine de ce dépôt, car `.perltidyrc` s'y
trouve déjà.

## Mise à jour des fichiers AGENTS.md existants

Le helper met à jour uniquement `AGENTS.md`. Il ne copie ni ne modifie
`.perltidyrc`, y compris avec `--apply` ou `--commit-push`. Chaque projet
conserve sa configuration de formatage. `.perltidyrc` est déjà suivi dans
Git et inclus dans les releases ; aucun numéro de version distinct n'est
nécessaire.

Le helper nécessite Perl 5.36 ou ultérieur et Git, avec uniquement des
modules Perl standard. Les fichiers texte, arguments et sorties Git sont
interprétés en UTF-8. Conserver `update-agents.pl` avec son répertoire `lib`
et le dépôt Git source contenant ses tags de version. Le mode rapport et
`--apply` seul ne font aucun accès réseau ; `--commit-push` récupère et
pousse vers l'upstream configuré.

```bash
./update-agents.pl ../*/AGENTS.md
./update-agents.pl --to 1.5.0 ../projet/AGENTS.md
./update-agents.pl --apply ../projet
./update-agents.pl --commit-push ../projet
```

Les arguments acceptent des répertoires de dépôts ou des chemins de
fichiers. Par défaut, le helper affiche les différences proposées sans
écrire. La cible est le plus grand tag stable `vX.Y.Z` disponible
localement, pas le fichier source non commité ; `--to X.Y.Z` sélectionne une
version publiée précise. Les chemins identiques sont traités une seule fois
et le dépôt source est exclu.

Les copies exactes sont remplacées par le modèle cible. Les versions
identifiées et adaptées sont fusionnées avec leur version de référence, en
préservant les ajouts, remplacements et suppressions locaux. Les sections de
premier niveau supprimées localement restent absentes, y compris les
nouvelles règles ajoutées en amont dans ces sections ; le rapport identifie
les évolutions ainsi ignorées. La fusion est textuelle : même un résultat
sans conflit nécessite une relecture pour vérifier sa compatibilité avec les
spécificités du projet.

Les conflits laissent le fichier entier intact. Le rapport affiche le
résultat proposé avec des numéros de ligne et des marqueurs LOCAL, BASE et
TARGET pour comparaison manuelle. Les versions absentes, inconnues ou plus
récentes, fichiers illisibles, cibles invalides et liens symboliques sont
signalés pour vérification. Le marqueur de version avance uniquement après
une fusion complète réussie.

`--apply` écrit uniquement dans les dépôts Git dont l'arbre de travail est
propre, fichiers non suivis compris. Il préserve les permissions, remplace
les fichiers atomiquement et refuse les changements intervenus depuis
l'analyse. Les dépôts sont traités indépendamment : les mises à jour déjà
réussies restent appliquées si un autre dépôt échoue.

En cas de refus, `dirty working tree` affiche les chemins bloquants et
leurs statuts Git : `??` indique un fichier non suivi, la première colonne
décrit les changements staged et la seconde les changements non staged.
Une erreur Git affiche séparément `git status failed`, son code de sortie
et le diagnostic Git. Cette distinction vaut aussi après la préparation
de l’upstream avec `--commit-push`. Les sauvegardes non suivies ne sont ni
ignorées ni supprimées automatiquement.

Les commandes proposées permettent de relire le diff, d'ajouter seulement le
fichier cible, de créer un Conventional Commit limité à ce fichier et de
pousser la branche courante vers son upstream configuré. En mode rapport ou
avec `--apply` seul, aucun commit, push, fetch ou pull n'est exécuté. Un
upstream absent nécessite une configuration manuelle. Relire le diff et
l'état du dépôt avant d'exécuter les commandes proposées.

`--commit-push` implique `--apply` et s'exécute sans confirmation
supplémentaire. Avant toute écriture, il exige un arbre propre, une branche
active et un upstream configuré. Il récupère uniquement cette branche
upstream sans tags ni sous-modules et exige que le HEAD local corresponde au
commit récupéré. Les branches en avance, en retard ou divergentes sont
ignorées pour synchronisation manuelle ; aucun merge ni rebase n'est
effectué.

Le helper crée `docs: update AGENTS.md to vX.Y.Z`, avec uniquement le
fichier cible et les hooks Git habituels. Il vérifie que le commit contient
seulement ce fichier avant de pousser explicitement vers la branche upstream
configurée, sans force. Il affiche le hash du commit et sa destination après
réussite. Un fichier déjà à jour ne déclenche aucun fetch, commit ou push.

Si le commit échoue, le fichier modifié reste disponible pour examen et
aucun push n'est effectué. Si le push échoue, le commit local est conservé
et une commande de reprise est affichée. Aucun reset ni rollback n'est
effectué. Les autres dépôts continuent indépendamment. Relancer le helper
sur un fichier déjà à jour ne retente pas un push précédemment échoué ;
utiliser la commande affichée après vérification de l'état du dépôt.

Le code de sortie est `0` pour les rapports ou applications réussis, `1` si
un élément nécessite une vérification ou ne peut pas être appliqué, et `2`
pour une syntaxe de commande invalide. Un fichier inchangé ou l'exclusion du
dépôt source constitue un succès.

Exécuter les tests hors ligne depuis la racine du dépôt source :

```bash
prove -l t
perlcritic lib/Agents/*.pm update-agents.pl t/*.t
PERL5OPT=-MDevel::Cover prove -l t
cover
```

La couverture nécessite Devel::Cover ; le formatage utilise `.perltidyrc`.
Les tests utilisent des dépôts Git temporaires et des remotes bare locaux,
sans accès Internet ni modification des projets voisins.
