#!/usr/bin/env bash
# Retouches des sources officielles de RustDesk pour produire RustDeskPublic.
# A lancer depuis la racine des sources rustdesk/rustdesk, sous-module
# libs/hbb_common present. Echoue si un motif attendu a disparu (nouvelle
# version de RustDesk) : mieux vaut un echec net qu'un binaire non retouche.
set -euo pipefail

NOM="${APP_NAME:-RustDeskPublic}"
F=libs/hbb_common/src/config.rs

if [ ! -f "$F" ]; then
  echo "Introuvable : $F (sous-module hbb_common absent ?)"
  exit 1
fi

# 1. Nom de l'application. Il fixe le dossier de reglages (%APPDATA%\<nom>),
#    le titre de la fenetre et le verrou d'instance unique (le lanceur Windows
#    le lit dans la DLL, flutter/windows/runner/main.cpp) : RustDeskPublic
#    tourne donc a cote du RustDesk officiel sans partager ses reglages.
if ! grep -q 'pub static ref APP_NAME: RwLock<String> = RwLock::new("RustDesk".to_owned());' "$F"; then
  echo "Motif APP_NAME introuvable dans $F"
  exit 1
fi
sed -i "/pub static ref APP_NAME:/s/\"RustDesk\"/\"$NOM\"/" "$F"

# 2. Mode sortant seulement (is_outgoing_only lit HARD_SETTINGS["conn-type"]) :
#    pas d'inscription sur un serveur, pas de second ID, aucune connexion entrante.
if ! grep -q 'pub static ref HARD_SETTINGS: RwLock<HashMap<String, String>> = Default::default();' "$F"; then
  echo "Motif HARD_SETTINGS introuvable dans $F"
  exit 1
fi
sed -i '/pub static ref HARD_SETTINGS:/s/Default::default()/RwLock::new([("conn-type".to_owned(), "outgoing".to_owned())].into_iter().collect())/' "$F"

# Verification : les deux lignes retouchees doivent etre presentes.
grep -n "pub static ref APP_NAME: RwLock<String> = RwLock::new(\"$NOM\".to_owned());" "$F"
grep -n 'pub static ref HARD_SETTINGS: RwLock<HashMap<String, String>> = RwLock::new(\[("conn-type".to_owned(), "outgoing".to_owned())\].into_iter().collect());' "$F"
echo "Retouches appliquees : APP_NAME=$NOM, conn-type=outgoing"
