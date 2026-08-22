#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

DIST=stable
REPO=hyperotter
GPG_KEY_UID="HyperOtter Packages"
# aptly ne lit pas de variable d'environnement pour son fichier de config
# (verifie via `aptly --help` : seuls `-config=` et les chemins par defaut
# ~/.aptly.conf, /usr/local/etc/aptly.conf, /etc/aptly.conf sont supportes) ;
# sans -config explicite, aptly retombe silencieusement sur ~/.aptly.conf et
# ~/.aptly, hors du depot.
ALY=(aptly -config=aptly/aptly.conf)

"${ALY[@]}" repo create -distribution="$DIST" -component=main "$REPO" 2>/dev/null || true

shopt -s nullglob
for deb in incoming/apt/*.deb; do
  "${ALY[@]}" repo add "$REPO" "$deb"
done
shopt -u nullglob

"${ALY[@]}" publish drop "$DIST" 2>/dev/null || true
# Pas d'argument de prefixe ici : "aptly publish repo <name> [prefix]" traite
# tout troisieme argument comme un PREFIXE de publication (sous-repertoire),
# pas comme la distribution (deja fixee par `repo create -distribution=`) --
# le passer doublerait le chemin en .aptly/public/$DIST/dists/$DIST/...
"${ALY[@]}" publish repo -gpg-key="$GPG_KEY_UID" -batch=true "$REPO"
