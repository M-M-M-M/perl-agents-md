# Documentation

Ce document donne les détails pratiques pour utiliser les conventions du dépôt.
Le README principal explique le but du projet ; ce fichier explique comment
appliquer les outils.

La version anglaise est disponible dans [DOCUMENTATION.md](DOCUMENTATION.md).

## Version

Cette documentation s'applique à la version 1.1.0. Le détail de la version est
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
