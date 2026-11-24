# Spec Delta

## Purpose

Ein Menü in der Menüleiste legt fest, in welches Brave-Profil alle eingehenden Links gehen.
Es dient in der ersten Phase als Testwerkzeug, solange es noch keine Regeln gibt.

## ADDED Requirements

### Requirement: Menüleisten-Symbol ohne Dock-Symbol
Die App SHALL nur als Symbol in der Menüleiste erscheinen, nicht im Dock und nicht im
App-Umschalter (⌘-Tab).

#### Scenario: App gestartet
- **WHEN** der Nutzer BrowserSwitch startet
- **THEN** erscheint ein Symbol in der Menüleiste, aber kein Dock-Symbol

### Requirement: Profile im Menü wählen
Das Menü SHALL alle Brave-Profile mit Namen und einem Farbpunkt in der Profilfarbe
auflisten. Das aktuelle Zielprofil SHALL angehakt sein. Ein Klick auf ein Profil SHALL es
zum Zielprofil machen.

#### Scenario: Zielprofil wechseln
- **GIVEN** Zielprofil ist „Privat“
- **WHEN** der Nutzer im Menü „Arbeit“ anklickt
- **THEN** ist „Arbeit“ angehakt, und der nächste Link öffnet im Arbeits-Profil

### Requirement: Wahl bleibt erhalten
Das Zielprofil SHALL über Beenden und Neustart der App sowie des Macs erhalten bleiben.

#### Scenario: Neustart
- **GIVEN** Zielprofil ist „Arbeit“
- **WHEN** der Nutzer die App beendet und neu startet
- **THEN** ist weiterhin „Arbeit“ angehakt

### Requirement: Startwert ohne gespeicherte Wahl
Wurde noch kein Zielprofil gewählt, SHALL die App das zuletzt in Brave benutzte Profil
verwenden, ersatzweise das Standardprofil von Brave.

#### Scenario: Erster Start
- **GIVEN** es wurde noch nie ein Zielprofil gewählt, zuletzt benutzt war in Brave „Kunde“
- **WHEN** der Nutzer das Menü öffnet
- **THEN** ist „Kunde“ angehakt

### Requirement: Gelöschtes Zielprofil sichtbar machen
Existiert das gespeicherte Zielprofil nicht mehr, SHALL das Menü das anzeigen und kein
anderes Profil stillschweigend als Ziel anhaken.

#### Scenario: Zielprofil gelöscht
- **GIVEN** Zielprofil ist „Arbeit“, das Profil wurde in Brave gelöscht
- **WHEN** der Nutzer das Menü öffnet
- **THEN** zeigt das Menü „Zielprofil fehlt: Arbeit“ und kein Profil ist angehakt

### Requirement: Beenden
Das Menü SHALL einen Eintrag „BrowserSwitch beenden“ enthalten.

#### Scenario: Beenden
- **WHEN** der Nutzer „BrowserSwitch beenden“ wählt
- **THEN** beendet sich die App, und das Symbol verschwindet aus der Menüleiste
