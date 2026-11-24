# BrowserSwitch

macOS-Menüleisten-App, die sich als Standardbrowser einträgt und Links ins passende Brave-Profil leitet (z. B. Privat, Arbeit, Kunde).

Idee, Scope und Anforderungen: [proposal.md](proposal.md). Die Arbeit läuft über
[OpenSpec](https://github.com/Fission-AI/OpenSpec) unter [`openspec/`](openspec/).

**Stand:** Machbarkeitstest (Change `add-brave-profile-launch`). Alle Links öffnen im Profil,
das im Menü angehakt ist. Regeln und Auswahl-Panel folgen.

## Bauen und installieren

Voraussetzung: macOS 15 oder neuer, Xcode 16 oder neuer (bzw. die passenden Command Line Tools).

```sh
git clone git@github.com:henpak/browser-switch.git
cd browser-switch
scripts/build-app.sh --open   # baut, signiert ad-hoc, installiert nach ~/Applications und startet
```

Danach erscheint oben in der Menüleiste ein Symbol mit Verzweigungspfeilen. Ein Dock-Symbol gibt es nicht.

Weitere Befehle:

```sh
swift test                              # Unit-Tests (Logik, ohne AppKit)
scripts/package-app.sh                  # nur bauen: build/BrowserSwitch.app
scripts/package-app.sh --universal --zip
```

## Als Standardbrowser festlegen

Im Menü von BrowserSwitch **Als Standardbrowser festlegen …** wählen und den Dialog von macOS
bestätigen. Alternativ unter **Systemeinstellungen → Schreibtisch & Dock → Standard-Webbrowser**.

Zurück zu Brave: dort Brave auswählen, danach kann BrowserSwitch beendet und
`~/Applications/BrowserSwitch.app` gelöscht werden.

## Machbarkeitstest

1. BrowserSwitch als Standardbrowser festlegen.
2. Im Menü **Arbeit** anhaken, in Brave ein Fenster des Kunden-Profils nach vorne holen und in
   Outlook auf einen Link klicken. Er muss in einem Arbeits-Fenster öffnen.
3. Im Menü **Privat** anhaken, Brave beenden, im Terminal `open https://example.com` ausführen.
   Brave muss starten und den Link im privaten Profil zeigen.
4. In Brave ein Testprofil anlegen, es im Menü anhaken, in Brave wieder löschen und einen Link
   öffnen. Es muss ein Hinweis erscheinen, und Brave darf kein neues Profil anlegen.

Klappen 2 oder 3 nicht zuverlässig, wird das Projekt laut [proposal.md](proposal.md) gestoppt.

Protokoll der App (ohne URLs):

```sh
log stream --predicate 'subsystem == "io.github.henpak.browserswitch"' --info
```
