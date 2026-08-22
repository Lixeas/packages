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
Fingerprint: (a completer apres Task 3, Step 3)
Cle publique servie a `https://packages.<TON_DOMAINE>/gpg/hyperotter-packages.asc`

## Retention

5 dernieres versions conservees par format, triees par `sort -V`
(`scripts/prune-versions.sh`).
