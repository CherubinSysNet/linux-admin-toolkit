# Linux Admin Toolkit

**Linux Admin Toolkit** est une boîte à outils modulaire en **Bash** pour simplifier l’administration et l’automatisation des systèmes Linux.

## Fonctionnalités

* Monitoring système
* Diagnostics réseau
* Audit de sécurité
* Gestion des sauvegardes
* Vérification de l’état du système
* Génération de rapports JSON
* Tests automatisés avec ShellCheck et GitHub Actions

## Installation

```bash
git clone https://github.com/CherubinSysNet/linux-admin-toolkit.git
cd linux-admin-toolkit
chmod +x bin/lat
```

Pour installer `lat` globalement :

```bash
sudo ln -sfn "$PWD/bin/lat" /usr/local/bin/lat
```

## Utilisation

```bash
lat system monitor
lat network diagnose
lat security audit
lat maintenance health
lat backup create /etc /tmp/backups
lat report generate
```

Afficher l'aide :

```bash
lat --help
```

## Tests

```bash
bash tests/test_core.sh
```

## Licence

MIT — © 2026 **Cherubin TSHIENDA**
