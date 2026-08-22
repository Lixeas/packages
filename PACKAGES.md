# Contrat incoming/

Lixeas/hyperotter pousse ici les paquets construits par sa CI de release,
sur la branche `incoming` (orphan, force-push a chaque release — jamais
mergee dans `main`). `main` ne contient jamais de binaire.

## Convention de nommage attendue

- `incoming/apt/hyperotter_<version>_amd64.deb`
- `incoming/yum/hyperotter-<version>-1.x86_64.rpm`
- `incoming/pacman/hyperotter-<version>-1-x86_64.pkg.tar.zst`

`<version>` = version de `package.json`, sans prefixe `v` (ex: `0.2.0`).

## Cle de signature GPG

UID: `HyperOtter Packages`
Fingerprint: `6F31 D31E 2795 FA23 3B8A  E9AD 547C 57AD FBF8 6A3E`
Cle publique servie a `https://packages.<TON_DOMAINE>/gpg/hyperotter-packages.asc`

Copie de reference (source de verite) de la cle privee : secret GitHub
`PACKAGES_GPG_PRIVATE_KEY` sur ce repo. Le trousseau local (WSL2/poste dev)
est jetable — seule la copie en secret GitHub fait foi.

Certificat de revocation : non genere. La passphrase generee a la creation
de la cle n'a jamais ete affichee ni conservee nulle part (par conception),
donc `gpg --gen-revoke` ne peut plus etre execute avec le trousseau local.
Un job CI jetable importable les secrets pour le generer a ete envisage puis
abandonne (le classifieur de securite l'a bloque, a juste titre — importer
la cle privee dans un workflow pour en exporter un artefact ressemble
structurellement a une exfiltration). Si la cle est un jour compromise, il
faudra re-generer une nouvelle paire et republier la cle publique + le
fingerprint partout (repo, clients deja configures) sans revocation propre
de l'ancienne.

Expiration : 2028-08-21. Avant cette date, soit prolonger via
`gpg --quick-set-expire "HyperOtter Packages" <new-date>`, soit generer une
nouvelle cle et mettre a jour ce document + les clients deja configures.

## Retention

5 dernieres versions conservees par format, triees par `sort -V`
(`scripts/prune-versions.sh`).

**Pas encore effectif** : `incoming/` est ecrase a chaque force-push (branche
orphan) et `.aptly/`/`out/` ne persistent jamais entre deux runs CI (repertoires
gitignores, reconstruits a neuf a chaque publish). Tant que la CI (Task 9) ne
telecharge pas l'arbre deja publie avant de reconstruire, `prune-versions.sh`
n'a jamais plus d'une version a elaguer — la retention documentee ici n'est pas
encore vraie en pratique. Voir le plan
`docs/superpowers/plans/2026-08-22-packages-repo-infra.md` (Task 9) pour le
correctif prevu : restaurer l'arbre publie existant avant reconstruction,
fusionner avec la nouvelle version, elaguer, puis republier.
