#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

DIST=stable
REPO=hyperotter
GPG_KEY_UID="HyperOtter Packages"
: "${GPG_PASSPHRASE:?GPG_PASSPHRASE must be set}"
# aptly ne lit pas de variable d'environnement pour son fichier de config
# (verifie via `aptly --help` : seuls `-config=` et les chemins par defaut
# ~/.aptly.conf, /usr/local/etc/aptly.conf, /etc/aptly.conf sont supportes) ;
# sans -config explicite, aptly retombe silencieusement sur ~/.aptly.conf et
# ~/.aptly, hors du depot.
ALY=(aptly -config=aptly/aptly.conf)

./scripts/prune-versions.sh incoming/apt 'hyperotter_.*\.deb$' 5

"${ALY[@]}" repo create -distribution="$DIST" -component=main "$REPO" || true

shopt -s nullglob
for deb in incoming/apt/*.deb; do
  "${ALY[@]}" repo add "$REPO" "$deb"
done
shopt -u nullglob

"${ALY[@]}" publish drop "$DIST" || true
# Pas d'argument de prefixe ici : "aptly publish repo <name> [prefix]" traite
# tout troisieme argument comme un PREFIXE de publication (sous-repertoire),
# pas comme la distribution (deja fixee par `repo create -distribution=`) --
# le passer doublerait le chemin en .aptly/public/$DIST/dists/$DIST/...
# -batch=true seul ne suffit pas : sans passphrase explicite, gpg echoue avec
# "Sorry, we are in batchmode - can't get input" au lieu de demander un
# pinentry -- non-fonctionnel en environnement d'agent a froid (CI compris)
# sauf a pre-chauffer manuellement le cache gpg-agent au prealable. On passe
# la passphrase via -passphrase-file en substitution de processus plutot que
# -passphrase= (visible dans `ps`) ou un fichier temporaire sur disque.
"${ALY[@]}" publish repo -gpg-key="$GPG_KEY_UID" -batch=true \
  -passphrase-file=<(printf '%s' "$GPG_PASSPHRASE") \
  "$REPO"
