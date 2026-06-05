# perl-agents-md

Consignes `AGENTS.md` réutilisables pour guider les agents de codage sur des
projets Perl.

Ce dépôt contient une première version d'un fichier `AGENTS.md` destiné à aider
les agents de codage à travailler correctement sur des projets Perl.

Le but est de formaliser des consignes claires et réutilisables pour guider un
assistant de développement lors de la lecture, de la modification et de la
validation de code Perl. Le fichier doit servir de référence de travail pour des
outils comme Codex, et pouvoir être adapté plus tard à d'autres environnements
d'agents comme Claude ou Antigravity.

## Objectif

`AGENTS.md` décrit les pratiques attendues pour coder en Perl avec rigueur :

- discipline de travail avant modification du code ;
- usage des outils Perl habituels comme `perltidy`, `perlcritic`, `prove` ou
  `cpanm` ;
- style de code lisible, explicite et maintenable ;
- conventions pour les modules, objets, erreurs, tests et dépendances ;
- préférence pour les petites modifications ciblées plutôt que les refontes
  implicites.

L'intention n'est pas de créer un framework, mais un document d'instructions que
l'on peut copier, adapter ou inclure dans des dépôts Perl afin d'améliorer la
qualité des contributions produites avec un agent.

## Usage prévu

Le cas d'usage principal est Codex : placer ce fichier dans un dépôt Perl permet
à l'agent de connaître les attentes du projet avant d'écrire ou de modifier du
code.

À terme, le contenu pourra aussi servir de base pour d'autres assistants de
développement. Les formulations doivent donc rester suffisamment générales pour
être utiles hors de Codex, tout en conservant les détails pratiques nécessaires
au travail quotidien sur du Perl.

## Déploiement

Pour utiliser ces consignes dans un autre dépôt Perl, copier ces fichiers à la
racine du dépôt cible :

- `AGENTS.md`
- `.perltidyrc`

Relire ensuite `AGENTS.md` et adapter les détails propres au projet, comme les
commandes de test, les outils de dépendances, les modules préférés ou les règles
de workflow. Garder `.perltidyrc` inchangé pour conserver le style de formatage
fourni par ce projet.

## Formatage Perl

Le dépôt contient une configuration perltidy de référence dans
[`.perltidyrc`](.perltidyrc). Les agents doivent utiliser ce fichier tel quel
pour formater le code Perl, car il correspond au style local attendu.

Les notes détaillées d'utilisation de perltidy sont documentées dans
[`DOCUMENTATION.fr.md`](DOCUMENTATION.fr.md). Le README principal conserve
seulement la règle de niveau projet : formater avec perltidy, utiliser la
configuration fournie, et ne pas la modifier sauf demande explicite de changement
de style.

## Remerciements

Ce projet s'inspire du dépôt
[`yegor256/prompt`](https://github.com/yegor256/prompt) de Yegor Bugayenko,
adapté ici pour des agents de codage spécialisés Perl. Voir
[`THIRD-PARTY-NOTICES.md`](THIRD-PARTY-NOTICES.md) pour les notices de licence.

## Licence

Ce projet est distribué sous licence MIT. Voir [LICENSE](LICENSE).

## État du projet

Le fichier `AGENTS.md` est une première version. Il peut encore évoluer pour
clarifier les consignes, supprimer les doublons, séparer les règles générales des
règles propres à un outil, ou ajouter des variantes selon les types de projets
Perl.
