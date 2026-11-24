# Spec Delta

## Purpose

BrowserSwitch kennt die Brave-Profile des Nutzers mit Namen und Farbe, damit Links gezielt
in ein Profil geleitet und Profile verständlich angezeigt werden können.

## ADDED Requirements

### Requirement: Profile aus Brave lesen
Die App SHALL alle Profile der lokalen Brave-Installation mit ihrem Anzeigenamen, ihrer
Profilfarbe und ihrer internen Kennung (Profilverzeichnis) ermitteln. Sie SHALL dabei
Braves Dateien nur lesen, nie verändern.

#### Scenario: Drei Profile vorhanden
- **GIVEN** Brave hat die Profile „Privat“, „Arbeit“ und „Kunde“
- **WHEN** die App die Profile ermittelt
- **THEN** liefert sie genau diese drei Profile mit Namen, Farbe und Kennung

#### Scenario: Profil ohne eigene Farbe
- **GIVEN** ein Profil hat keine Farbe gesetzt
- **WHEN** die App die Profile ermittelt
- **THEN** erhält dieses Profil eine neutrale graue Ersatzfarbe

### Requirement: Stabile Kennung statt Name
Die App SHALL ein Profil über seine interne Kennung identifizieren, nicht über den
Anzeigenamen, damit Umbenennen in Brave keine Zuordnung bricht.

#### Scenario: Profil umbenannt
- **GIVEN** das Zielprofil ist „Arbeit“ mit Kennung `Profile 1`
- **WHEN** der Nutzer es in Brave in „Arbeit GmbH“ umbenennt
- **THEN** bleibt `Profile 1` Zielprofil, und das Menü zeigt beim nächsten Öffnen „Arbeit GmbH“

### Requirement: Änderungen ohne Neustart erkennen
Die App SHALL neue, umbenannte und gelöschte Profile erkennen, ohne dass sie neu gestartet
werden muss, spätestens beim nächsten Öffnen des Menüs oder beim nächsten Link.

#### Scenario: Neues Profil angelegt
- **GIVEN** die App läuft
- **WHEN** der Nutzer in Brave ein neues Profil „Test“ anlegt und danach das Menü öffnet
- **THEN** zeigt das Menü „Test“ als wählbares Profil

### Requirement: Unlesbare Profildaten
Kann die App Braves Profildaten nicht finden oder nicht lesen, SHALL sie eine leere
Profilliste liefern und den Grund im Menü anzeigen, statt abzustürzen.

#### Scenario: Brave nicht installiert
- **GIVEN** auf dem Mac ist Brave nicht installiert
- **WHEN** der Nutzer das Menü öffnet
- **THEN** zeigt das Menü „Brave nicht gefunden“ und keine Profile
