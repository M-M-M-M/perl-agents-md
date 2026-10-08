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
- consultation de la documentation pertinente et du contexte existant du projet
  avant toute modification ;
- maintenance de la documentation dans le cadre de la modification, en conservant
  les documents de référence existants comme sources faisant autorité ;
- usage des outils Perl habituels comme `perltidy`, `perlcritic`, `prove` ou
  `cpanm` ;
- style de code lisible, explicite et maintenable ;
- pragmas de fonctionnalités Perl explicites, y compris les signatures quand
  elles améliorent la lisibilité des paramètres ;
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

## Documentation du projet

Pour les projets non triviaux, les agents de codage travaillent plus efficacement
lorsqu'ils peuvent trouver les informations de référence avant de modifier le
code. `AGENTS.md` leur demande donc de consulter la documentation existante
pertinente plutôt que de reconstruire le contexte à partir d'hypothèses ou de
lire tous les documents.

Les noms de documents dans les consignes sont des exemples. Utiliser les
équivalents existants du projet lorsqu'ils sont disponibles ; les consignes
n'imposent pas de créer ces fichiers.

Les dépôts qui contiennent une documentation importante peuvent bénéficier d'un
petit index ou d'une table des matières. Cet index doit identifier les documents
faisant autorité et indiquer dans quels cas les consulter.

Par exemple :

```markdown
# Index de la documentation

- `architecture.md` — architecture du système ; à lire avant les changements
  structurels.
- `authentication.md` — authentification ; à lire pour les changements
  d'authentification ou d'autorisation.
- `database.md` — persistance ; à lire pour les changements de schéma ou de
  base de données.
- `deployment.md` — déploiement en production ; à lire pour les changements
  d'exécution ou de déploiement.
```

Cet index est facultatif. Les petits dépôts qui ne contiennent que quelques
documents n'en ont généralement pas besoin.

L'index doit renvoyer vers la documentation de référence existante plutôt que
d'en dupliquer le contenu. Lorsque le comportement du projet change, les agents
doivent mettre à jour le document de référence plutôt que créer une seconde
description qui pourrait ensuite diverger. Les traductions sont admises et
doivent rester synchronisées avec le document source.

## Déploiement

Pour utiliser ces consignes dans un autre dépôt Perl, copier ces fichiers à la
racine du dépôt cible :

- `AGENTS.md`
- `.perltidyrc`

Relire ensuite `AGENTS.md` et adapter les détails propres au projet, comme les
commandes de test, les outils de dépendances, les modules préférés ou les règles
de workflow. Garder `.perltidyrc` inchangé pour conserver le style de formatage
fourni par ce projet.

## Mise à jour des consignes existantes

Utiliser le helper pour prévisualiser les mises à jour des dépôts qui utilisent
ces consignes :

```bash
./update-agents.pl ../*/AGENTS.md
```

Le rapport compare chaque fichier aux versions publiées et préserve les
ajouts, modifications et suppressions propres au projet. Utiliser `--apply`
pour mettre à jour les dépôts compatibles dont l'arbre de travail est
propre. Avec `--commit-push`, il applique, commite et pousse automatiquement
si la branche correspond à son upstream. Sans cette option, il propose les
commandes Git. Voir
[DOCUMENTATION.fr.md][mise-a-jour] pour les options, les conflits et les
commandes de validation.

Le helper met à jour uniquement `AGENTS.md`. Il ne copie ni ne modifie
`.perltidyrc`, y compris avec `--apply` ou `--commit-push`, afin de préserver
le style de formatage de chaque projet.

## Formatage Perl

Le dépôt contient une configuration perltidy de référence dans
[`.perltidyrc`](.perltidyrc). Les agents doivent utiliser ce fichier tel quel
pour formater le code Perl, car il correspond au style local attendu.

Les notes détaillées d'utilisation de perltidy sont documentées dans
[`DOCUMENTATION.fr.md`](DOCUMENTATION.fr.md). Le README principal conserve
seulement la règle de niveau projet : formater avec perltidy, utiliser la
configuration fournie, et ne pas la modifier sauf demande explicite de changement
de style. Pour formater en place, préférer
`perltidy -b -bext='/' chemin/vers/fichier.pl` afin d'éviter de laisser des
sauvegardes `.bak` dans l'arbre de travail.

## Remerciements

Ce projet s'inspire du dépôt
[`yegor256/prompt`](https://github.com/yegor256/prompt) de Yegor Bugayenko,
adapté ici pour des agents de codage spécialisés Perl. Voir
[`THIRD-PARTY-NOTICES.md`](THIRD-PARTY-NOTICES.md) pour les notices de licence.

## Licence

Ce projet est distribué sous licence MIT. Voir [LICENSE](LICENSE).

## État du projet

La version 1.6.0 est la version courante de ces consignes. `AGENTS.md`
déclare cette version en tête de fichier afin d'identifier rapidement la
version utilisée. La version 1.6.0 a ajouté le helper de mise à jour des
consignes, avec commit et push automatiques en option, en préservant les
adaptations et configurations de formatage des projets. La version 1.5.0 a
ajouté les consignes de tests dans le navigateur : Playwright, Docker,
environnements isolés, autorisations requises et compte rendu fidèle des
tests exécutés. La version 1.4.0 a ajouté les consignes sur le contexte du
projet et la maintenance de la documentation : consulter les documents
pertinents avant les modifications, préserver les documents de référence et
synchroniser le dépôt de manière plus prudente. La version 1.3.0 a ajouté
les consignes Markdown, la version 1.2.0 a ajouté les consignes de formatage
et le marqueur de version, la version 1.1.0 a ajouté les consignes
explicites sur les signatures Perl, et la version 1.0.0 était la première
version stable. Voir [CHANGELOG.md](CHANGELOG.md) pour le détail des
versions.

Le fichier `AGENTS.md` pourra continuer à évoluer pour clarifier les consignes,
supprimer les doublons, séparer les règles générales des règles propres à un
outil, ou ajouter des variantes selon les types de projets Perl.

[mise-a-jour]: DOCUMENTATION.fr.md#mise-à-jour-des-fichiers-agentsmd-existants
