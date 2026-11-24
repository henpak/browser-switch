# Proposal

## Why

BrowserSwitch steht und fällt damit, dass sich Brave zuverlässig in ein bestimmtes Profil
schicken lässt, auch wenn Brave schon läuft und ein anderes Profil vorne hat (siehe
Risiko 1 in `/proposal.md`). Dieser Change baut das kleinste lauffähige Gerüst, mit dem
sich genau das im Alltag prüfen lässt, bevor Regeln und Auswahl-Panel entstehen. Scheitert
der Test, wird das Projekt abgebrochen.

## What Changes

- Neue macOS-Menüleisten-App „BrowserSwitch“ (ohne Dock-Symbol), die sich als
  Standardbrowser für `http`/`https` auswählen lässt.
- Die App liest die Brave-Profile (Name, Farbe) und zeigt sie im Menüleisten-Menü.
- Im Menü wird ein Zielprofil angehakt; jeder eingehende Link öffnet in diesem Profil.
  Die Wahl bleibt über Neustarts erhalten. Das Menü ist ein Testwerkzeug für diese
  Phase und wird später durch Regeln und Panel ergänzt.
- Fehlt das Zielprofil oder Brave selbst, öffnet die App nichts Falsches, sondern meldet es.
- Build- und Installationsskripte (Ad-hoc-Signatur, Installation nach `~/Applications`)
  und eine CI, die auf macOS baut und testet.

Nicht enthalten: Regeln, Auswahl-Panel, ⌥-Override, Release-Workflow, `install.sh`.

## Capabilities

### New Capabilities
- `default-browser`: Die App nimmt Web-Links vom System an und lässt sich als
  Standardbrowser festlegen.
- `brave-profiles`: Erkennen der vorhandenen Brave-Profile mit Namen und Farbe.
- `brave-launch`: Öffnen eines Links in einem bestimmten Brave-Profil, unabhängig vom
  Zustand von Brave, inklusive Verhalten bei fehlendem Profil oder fehlendem Brave.
- `target-profile-menu`: Menüleisten-Menü zur Wahl des Zielprofils für alle Links.

### Modified Capabilities

Keine.

## Impact

- Neues Swift Package (`Package.swift`, `Sources/`, `Tests/`), `Resources/Info.plist`,
  `scripts/package-app.sh`, `scripts/build-app.sh`, `.github/workflows/ci.yml`.
- Liest `~/Library/Application Support/BraveSoftware/Brave-Browser/Local State`
  (nur lesend). Keine Netzwerkzugriffe, keine Systemrechte (Bedienungshilfen o. ä.).
- Läuft ab macOS 15, Apple Silicon und Intel.
