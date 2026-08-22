#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

OUT=out/pacman
DB=hyperotter.db.tar.zst
GPG_KEY_UID="HyperOtter Packages"
: "${GPG_PASSPHRASE:?GPG_PASSPHRASE must be set}"

mkdir -p "$OUT"
shopt -s nullglob
for pkg in incoming/pacman/*.pkg.tar.zst; do
  cp "$pkg" "$OUT/"
done
shopt -u nullglob

# repo-add ne prend aucune option de passphrase : sa fonction create_signature
# (verifie en lisant /usr/bin/repo-add) appelle en dur
# `gpg --detach-sign --use-agent -u "$GPGKEY" ...`, sans --batch ni
# --passphrase-file. A froid (agent gpg fraichement demarre, comme en CI),
# cet appel echoue -- silencieusement : repo-add capture le code de retour
# dans une variable locale, affiche juste un WARNING et sort quand meme en 0,
# sans lever d'erreur (verifie : `repo-add --sign` cree une base NON signee
# et continue). Meme fix que publish-apt.sh/publish-yum.sh sur le fond
# (passphrase via -passphrase-file en substitution de processus, jamais sur
# disque, jamais visible dans `ps`), mais applique differemment ici : comme
# repo-add ne relaie aucun flag de passphrase a gpg, on prechauffe le cache
# de gpg-agent pour ce keygrip *avant* de l'appeler, en signant un contenu
# jetable avec --pinentry-mode loopback --passphrase-file. repo-add reutilise
# ensuite ce cache via --use-agent, dans la meme session d'agent.
gpg --batch --pinentry-mode loopback \
  --passphrase-file <(printf '%s' "$GPG_PASSPHRASE") \
  --local-user "$GPG_KEY_UID" --detach-sign --no-armor -o /dev/null \
  <(printf 'warm')

cd "$OUT"
repo-add --sign --key "$GPG_KEY_UID" "$DB" ./*.pkg.tar.zst

# Cf. commentaire ci-dessus : repo-add sort en 0 meme quand la signature
# echoue, il ne reste alors qu'un WARNING dans les logs. On verifie donc
# explicitement la presence des .sig plutot que de faire confiance au code
# de retour -- des deux : repo-add signe aussi une base auxiliaire
# "<nom>.files.tar.zst" (liste des fichiers par paquet), a cote de la base
# principale "$DB", avec sa propre signature. Verifie lors des tests : les
# deux se signent ensemble a chaque fois, mais rien ne le garantit -- une
# des deux pourrait echouer seule.
for sig in "$DB.sig" "${DB%.db.tar.zst}.files.tar.zst.sig"; do
  if [[ ! -f "$sig" ]]; then
    echo "error: $sig was not created -- repo-add signing failed" >&2
    exit 1
  fi
done
