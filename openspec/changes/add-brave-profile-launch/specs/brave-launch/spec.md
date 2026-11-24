# Spec Delta

## Purpose

BrowserSwitch öffnet einen Link zuverlässig in genau dem gewünschten Brave-Profil, egal in
welchem Zustand Brave gerade ist. Das ist die Kernfunktion, an der das Projekt hängt.

## ADDED Requirements

### Requirement: Link im Zielprofil öffnen, wenn Brave läuft
Läuft Brave bereits, SHALL die App den Link in einem Fenster des Zielprofils öffnen, auch
wenn gerade ein Fenster eines anderen Profils vorne ist.

#### Scenario: Anderes Profil ist vorne
- **GIVEN** Brave läuft, das Fenster von „Kunde“ ist vorne, Zielprofil ist „Arbeit“
- **WHEN** ein Link aus Outlook ankommt
- **THEN** öffnet er als Tab in einem Arbeits-Fenster, und dieses Fenster kommt nach vorne

#### Scenario: Zielprofil hat noch kein Fenster
- **GIVEN** Brave läuft nur mit einem Fenster von „Privat“, Zielprofil ist „Arbeit“
- **WHEN** ein Link ankommt
- **THEN** öffnet ein neues Arbeits-Fenster mit dem Link

### Requirement: Link im Zielprofil öffnen, wenn Brave geschlossen ist
Läuft Brave nicht, SHALL die App Brave starten und den Link im Zielprofil öffnen.

#### Scenario: Brave ist beendet
- **GIVEN** Brave ist beendet, Zielprofil ist „Arbeit“
- **WHEN** ein Link ankommt
- **THEN** startet Brave und zeigt den Link in einem Arbeits-Fenster

### Requirement: Kein Öffnen in unbekanntem Profil
Die App SHALL vor jedem Öffnen prüfen, ob das Zielprofil in Brave noch existiert. Existiert
es nicht, SHALL sie Brave nicht mit diesem Profil starten (Brave würde sonst still ein neues,
leeres Profil anlegen) und stattdessen einen Hinweis zeigen.

#### Scenario: Zielprofil wurde gelöscht
- **GIVEN** Zielprofil ist „Arbeit“, das Profil wurde in Brave gelöscht
- **WHEN** ein Link ankommt
- **THEN** zeigt die App den Hinweis „Profil ‚Arbeit‘ gibt es nicht mehr“ mit der URL
- **AND** bietet „In Brave öffnen (ohne Profilwahl)“ und „Abbrechen“ an
- **AND** Brave legt kein neues Profil an

### Requirement: Fehlendes Brave melden
Ist Brave nicht installiert, SHALL die App einen Hinweis zeigen und den Link nicht verlieren:
Die URL SHALL im Hinweis stehen und kopierbar sein.

#### Scenario: Brave fehlt
- **GIVEN** Brave ist nicht installiert
- **WHEN** ein Link ankommt
- **THEN** zeigt die App „Brave nicht gefunden“ mit der URL und der Möglichkeit, sie zu kopieren

### Requirement: Ohne spürbare Verzögerung
Die App SHALL einen Link ohne spürbare Verzögerung weiterreichen; Profilprüfung und Start
SHALL zusammen keine bemerkbare Wartezeit erzeugen, die über den Start von Brave selbst
hinausgeht.

#### Scenario: Brave läuft
- **GIVEN** Brave läuft
- **WHEN** ein Link ankommt
- **THEN** erscheint er im Zielprofil so schnell wie bei einem direkten Klick mit Brave als Standardbrowser
