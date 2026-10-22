# RustDeskPublic

RustDesk officiel recompilé sous le nom **RustDeskPublic**, en mode « sortant seulement », pour joindre les clients du serveur RustDesk **public** depuis un poste dont le RustDesk officiel est inscrit sur un serveur **privé** (`rustdesk.valtechnologie.com`, g01).

Ce dépôt ne contient pas les sources de RustDesk : la recette GitHub Actions récupère les sources officielles de `rustdesk/rustdesk` au tag choisi, leur applique deux retouches, compile pour Windows x64 et dépose le dossier portable.

## Pourquoi

Un RustDesk ne s'inscrit que sur un seul serveur, et ce réglage décide aussi par où partent ses connexions. Depuis un poste réglé sur le serveur privé, RustDesk n'envoie jamais le jeton de compte au serveur public (même par un lien `id@public`, `client.rs`), alors que le public exige maintenant un compte connecté. La variable `RUSTDESK_APPNAME` ne suffit pas non plus : en 1.5.0, `get_rendezvous_server()` reprend le serveur du service quand le public n'est pas dans sa liste (`common.rs`, essai du 2026-10-22).

Un second RustDesk au nom d'application différent a ses propres réglages (`%APPDATA%\RustDeskPublic`), sa propre fenêtre et sa propre connexion au compte, et tourne à côté de l'officiel. ClaudeRustdesk ouvre les tuiles publiques avec lui et les tuiles du serveur privé avec l'officiel.

## Les deux retouches (`scripts/appliquer-retouches.sh`)

1. `APP_NAME` = `RustDeskPublic` (`libs/hbb_common/src/config.rs`). Fixe le dossier de réglages, le titre de la fenêtre et le verrou d'instance unique : le lanceur Windows lit ce nom dans la DLL (`flutter/windows/runner/main.cpp`).
2. `HARD_SETTINGS["conn-type"]` = `outgoing` : `is_outgoing_only()` est vrai, le programme ne s'inscrit sur aucun serveur et n'accepte aucune connexion entrante.

L'exécutable est renommé `RustDeskPublic.exe` : le programme de mise à jour du RustDesk officiel arrête les `rustdesk.exe` par leur nom.

Le script échoue si un motif attendu a disparu des sources (nouvelle version de RustDesk) : à adapter alors.

## Compiler

```
gh workflow run compiler-windows.yml -R Valtechnologie/RustDeskPublic -f rustdesk_ref=1.5.0
gh run watch -R Valtechnologie/RustDeskPublic
gh run download -R Valtechnologie/RustDeskPublic -n RustDeskPublic-1.5.0-windows-x64 -D <dossier>
```

Le dépôt est public : les minutes GitHub Actions sont gratuites. Il ne contient aucun secret (le client public n'a besoin d'aucune clé de serveur).

## Changer de version de RustDesk

1. Lancer la recette avec le nouveau tag (`rustdesk_ref`).
2. Si elle échoue, comparer les versions d'outils en tête de `.github/workflows/compiler-windows.yml` avec `.github/workflows/flutter-build.yml` et `bridge.yml` du nouveau tag (Rust, Flutter, LLVM, commit vcpkg, flutter_rust_bridge), et les étapes du job `build-for-windows-flutter`.

## Installer sur un poste technicien

Copier le dossier portable (par exemple dans `%LOCALAPPDATA%\Programs\RustDeskPublic`) et lancer `RustDeskPublic.exe`. Le binaire n'est pas signé : SmartScreen avertit au premier lancement. Se connecter au compte RustDesk (Paramètres → Compte) dans cette fenêtre, pas dans le RustDesk officiel : sur un poste réglé sur le serveur privé, un compte connecté dans l'officiel bloque les connexions directes (« Failed to secure tcp »).
