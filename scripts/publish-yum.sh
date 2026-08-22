#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

OUT=out/yum
GPG_KEY_UID="HyperOtter Packages"
: "${GPG_PASSPHRASE:?GPG_PASSPHRASE must be set}"

mkdir -p "$OUT"
./scripts/prune-versions.sh incoming/yum 'hyperotter-.*\.rpm$' 5
shopt -s nullglob
for rpm in incoming/yum/*.rpm; do
  cp "$rpm" "$OUT/"
done
shopt -u nullglob

# --update gere aussi bien le premier passage (aucun repodata/ prealable,
# verifie par test) que les suivants (retention/republication) : pas besoin
# d'une branche separee pour la creation initiale.
createrepo_c --update "$OUT"
# --batch seul ne suffit pas : sans passphrase explicite, gpg-agent tente un
# pinentry et echoue a froid avec "Inappropriate ioctl for device" (verifie
# en tuant gpg-agent avant de lancer ce script) -- non-fonctionnel en CI
# comme en environnement d'agent, sauf a pre-chauffer manuellement le cache.
# Meme fix que publish-apt.sh : passphrase via --passphrase-file en
# substitution de processus (jamais sur disque, jamais visible dans `ps`).
gpg --detach-sign --armor -u "$GPG_KEY_UID" --batch --yes \
  --pinentry-mode loopback --passphrase-file <(printf '%s' "$GPG_PASSPHRASE") \
  -o "$OUT/repodata/repomd.xml.asc" "$OUT/repodata/repomd.xml"
