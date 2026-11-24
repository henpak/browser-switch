# Spec Delta

## Purpose

BrowserSwitch tritt gegenüber macOS als Webbrowser auf, damit das System Links aus allen
anderen Apps an BrowserSwitch übergibt statt direkt an Brave.

## ADDED Requirements

### Requirement: Als Standardbrowser auswählbar
Die App SHALL sich bei macOS als Handler für die URL-Schemata `http` und `https` anmelden,
sodass sie in den Systemeinstellungen unter „Standard-Webbrowser“ erscheint und gewählt
werden kann.

#### Scenario: Auswahl in den Systemeinstellungen
- **WHEN** die App nach `~/Applications` installiert und einmal gestartet wurde
- **THEN** erscheint „BrowserSwitch“ in der Liste „Standard-Webbrowser“ der Systemeinstellungen

#### Scenario: Links gehen an die App
- **GIVEN** BrowserSwitch ist Standardbrowser
- **WHEN** in einer anderen App (z. B. Outlook, Terminal mit `open https://example.com`) ein Link geöffnet wird
- **THEN** erhält BrowserSwitch den Link und leitet ihn gemäß `brave-launch` weiter

### Requirement: Standardbrowser aus dem Menü festlegen
Das Menüleisten-Menü SHALL anzeigen, ob BrowserSwitch Standardbrowser ist. Ist es das nicht,
SHALL das Menü einen Eintrag anbieten, der die Festlegung über den Bestätigungsdialog von
macOS anstößt.

#### Scenario: Noch nicht Standardbrowser
- **GIVEN** ein anderer Browser ist Standardbrowser
- **WHEN** der Nutzer das Menü öffnet und „Als Standardbrowser festlegen“ wählt
- **THEN** zeigt macOS seinen Bestätigungsdialog, und nach Bestätigung ist BrowserSwitch Standardbrowser

#### Scenario: Bereits Standardbrowser
- **GIVEN** BrowserSwitch ist Standardbrowser
- **WHEN** der Nutzer das Menü öffnet
- **THEN** zeigt das Menü „Ist Standardbrowser“ ohne Aktion an

### Requirement: Nur Web-Links und lokale HTML-Dateien
Die App SHALL nur `http`- und `https`-Links sowie lokale HTML-Dateien annehmen. Lokale
Dateien SHALL sie unverändert an Brave im Zielprofil weitergeben.

#### Scenario: Lokale HTML-Datei
- **GIVEN** BrowserSwitch ist Standardbrowser
- **WHEN** der Nutzer eine `.html`-Datei mit „Öffnen mit → BrowserSwitch“ öffnet
- **THEN** öffnet die Datei in Brave im Zielprofil
