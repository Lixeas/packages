# HyperOtter packages

Depot apt/yum/pacman pour [HyperOtter](https://github.com/Lixeas/hyperotter).
Ce repo ne contient que l'infra de publication (aptly, createrepo_c, repo-add,
signature GPG, CI). Les paquets eux-memes sont pousses par la CI de release
de hyperotter sur la branche `incoming` — voir `PACKAGES.md`.

## Installer

### Debian / Ubuntu

```bash
curl -fsSL https://packages.<TON_DOMAINE>/gpg/hyperotter-packages.asc | sudo tee /etc/apt/keyrings/hyperotter-packages.asc
echo "deb [signed-by=/etc/apt/keyrings/hyperotter-packages.asc] https://packages.<TON_DOMAINE>/apt stable main" | sudo tee /etc/apt/sources.list.d/hyperotter.list
sudo apt update && sudo apt install hyperotter
```

### RHEL / Rocky / Fedora

```bash
sudo rpm --import https://packages.<TON_DOMAINE>/gpg/hyperotter-packages.asc
sudo tee /etc/yum.repos.d/hyperotter.repo <<EOF
[hyperotter]
name=HyperOtter
baseurl=https://packages.<TON_DOMAINE>/yum
enabled=1
gpgcheck=1
gpgkey=https://packages.<TON_DOMAINE>/gpg/hyperotter-packages.asc
EOF
sudo dnf install hyperotter
```

### Arch Linux

```bash
sudo curl -o /etc/pacman.d/hyperotter-packages.asc https://packages.<TON_DOMAINE>/gpg/hyperotter-packages.asc
sudo pacman-key --add /etc/pacman.d/hyperotter-packages.asc
sudo pacman-key --lsign-key "HyperOtter Packages"
echo -e "[hyperotter]\nSigLevel = Required DatabaseOptional\nServer = https://packages.<TON_DOMAINE>/pacman" | sudo tee -a /etc/pacman.conf
sudo pacman -Sy hyperotter
```

## Retention

5 dernieres versions par format. Voir `scripts/prune-versions.sh`.
