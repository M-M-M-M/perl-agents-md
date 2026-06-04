# Documentation

Ce document donne les details pratiques pour utiliser les conventions du depot.
Le README principal explique le but du projet ; ce fichier explique comment
appliquer les outils.

La version anglaise est disponible dans [DOCUMENTATION.md](DOCUMENTATION.md).

## Formatage Perl avec perltidy

Ce depot fournit un fichier `.perltidyrc` a la racine. C'est la configuration de
formatage de reference pour le code Perl et elle doit etre utilisee telle quelle.

`perltidy` cherche automatiquement `.perltidyrc` dans le repertoire courant. Il
suffit donc de lancer les commandes depuis la racine du depot.

## Previsualiser le formatage

Pour afficher le code formate dans le terminal sans modifier le fichier source :

```bash
perltidy -st -se chemin/vers/script.pl
```

`-st` envoie le code formate vers la sortie standard. `-se` envoie les erreurs
et avertissements vers la sortie d'erreur standard.

## Formater un fichier

Pour reformater un fichier en place et conserver une sauvegarde `.bak` :

```bash
perltidy -b chemin/vers/script.pl
```

Pour reformater un fichier en place sans creer de sauvegarde :

```bash
perltidy -b -bext='/' chemin/vers/script.pl
```

## Formater plusieurs fichiers

Pour formater tous les scripts Perl du repertoire courant :

```bash
perltidy -b *.pl
```

Pour les projets plus grands, preferer des chemins explicites ou la commande de
test ou de formatage deja fournie par le projet, si elle existe.

## Valider sans modifier les sources

Pour verifier que `perltidy` peut traiter des fichiers sans ecrire a cote des
sources :

```bash
mkdir -p /tmp/perltidy-check
perltidy -se -opath=/tmp/perltidy-check chemin/vers/script.pl
```

`-opath=/tmp/perltidy-check` ecrit le resultat formate dans un autre repertoire
au lieu de modifier les fichiers du depot.

## Resume des options

`-b` formate les fichiers en place et cree des sauvegardes `.bak`.

`-bext='/'` desactive la creation de sauvegarde quand `-b` est utilise.

`-st` ecrit le code formate vers la sortie standard.

`-se` ecrit les erreurs et avertissements vers la sortie d'erreur standard.

`-opath=DIR` ecrit les fichiers formates dans un autre repertoire.

`-pro=FILE` selectionne un fichier de configuration perltidy precis. Ce n'est
generalement pas necessaire depuis la racine de ce depot, car `.perltidyrc` s'y
trouve deja.
