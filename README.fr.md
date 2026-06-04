# perl-agents-md

Consignes `AGENTS.md` reutilisables pour guider les agents de codage sur des
projets Perl.

Ce depot contient une premiere version d'un fichier `AGENTS.md` destine a aider
les agents de codage a travailler correctement sur des projets Perl.

Le but est de formaliser des consignes claires et reutilisables pour guider un
assistant de developpement lors de la lecture, de la modification et de la
validation de code Perl. Le fichier doit servir de reference de travail pour des
outils comme Codex, et pouvoir etre adapte plus tard a d'autres environnements
d'agents comme Claude ou Antigravity.

## Objectif

`AGENTS.md` decrit les pratiques attendues pour coder en Perl avec rigueur :

- discipline de travail avant modification du code ;
- usage des outils Perl habituels comme `perltidy`, `perlcritic`, `prove`,
  `yath`, `cpanm` ou `carton` ;
- style de code lisible, explicite et maintenable ;
- conventions pour les modules, objets, erreurs, tests et dependances ;
- preference pour les petites modifications ciblees plutot que les refontes
  implicites.

L'intention n'est pas de creer un framework, mais un document d'instructions que
l'on peut copier, adapter ou inclure dans des depots Perl afin d'ameliorer la
qualite des contributions produites avec un agent.

## Usage prevu

Le cas d'usage principal est Codex : placer ce fichier dans un depot Perl permet
a l'agent de connaitre les attentes du projet avant d'ecrire ou de modifier du
code.

A terme, le contenu pourra aussi servir de base pour d'autres assistants de
developpement. Les formulations doivent donc rester suffisamment generales pour
etre utiles hors de Codex, tout en conservant les details pratiques necessaires
au travail quotidien sur du Perl.

## Formatage Perl

Le depot contient une configuration perltidy de reference dans
[`.perltidyrc`](.perltidyrc). Les agents doivent utiliser ce fichier tel quel
pour formater le code Perl, car il correspond au style local attendu.

Les notes detaillees d'utilisation de perltidy sont documentees dans
[`DOCUMENTATION.fr.md`](DOCUMENTATION.fr.md). Le README principal conserve
seulement la regle de niveau projet : formater avec perltidy, utiliser la
configuration fournie, et ne pas la modifier sauf demande explicite de changement
de style.

## Etat du projet

Le fichier `AGENTS.md` est une premiere version. Il peut encore evoluer pour
clarifier les consignes, supprimer les doublons, separer les regles generales des
regles propres a un outil, ou ajouter des variantes selon les types de projets
Perl.
