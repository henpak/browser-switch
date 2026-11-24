# Proposal: BrowserSwitch – Brave-Profil-Router für macOS

24.11.2026 · henpak

## Problem

Links aus Outlook, Teams, Slack oder dem Terminal öffnen immer im zuletzt aktiven
Brave-Profil. SharePoint-Links der eigenen Firma landen im Kunden-Profil, das Login-Portal
des Kunden im privaten. Jedes Mal heißt es kopieren, Profil wechseln, einfügen,
und die SSO-Sitzungen geraten durcheinander.

Velja löst das, ist aber Closed Source. Finicky ist Open Source, fragt aber nicht
nach und merkt sich nichts.

## Idee

Eine Menüleisten-App, die sich als Standardbrowser einträgt. macOS gibt ihr jeden
Link, sie bestimmt das Profil und reicht den Link an Brave weiter.

- Gibt es eine passende Regel, öffnet der Link sofort im Zielprofil, ohne Rückfrage.
- Ohne Regel erscheint ein Auswahl-Panel. Die Wahl dort wird zur Regel, das Panel
  taucht also mit der Zeit immer seltener auf.
- Alles bleibt lokal: kein Netzwerk, keine Telemetrie, Regeln in einer lesbaren Datei.

**Nicht im MVP:** Links, die innerhalb von Brave geklickt werden (die sieht der
Standardbrowser nie), andere Browser, Windows/Linux, Sync zwischen Macs.

## Bedienung

### Auswahl-Panel

- Schwebt an der Mausposition und nimmt der Quell-App nicht den Fokus.
- Zeigt oben die URL mit fett hervorgehobenem Host, damit Phishing-Domains auffallen.
- Listet die Profile mit Brave-Farbe und Nummer: `1` Privat, `2` Arbeit, `3` Kunde.
- Merk-Ebene per `Tab` umschalten: Nur einmal · Dieser Link · Host · Ganze Domain
  (Standard: Host).
- `1`–`9` öffnet und speichert · `Esc` bricht ab · `⌘C` kopiert die URL.

### Merk-Ebenen

Beispiel: `https://contoso.sharepoint.com/sites/HR/Doc.aspx?x=1`

| Ebene        | Passt auf                                 | Im Beispiel                              |
|--------------|-------------------------------------------|------------------------------------------|
| Dieser Link  | Host und Pfad, ohne Query und Fragment    | `contoso.sharepoint.com/sites/HR/Doc.aspx`  |
| Host         | genau diesen Host                         | alles auf `contoso.sharepoint.com`          |
| Ganze Domain | Domain mit allen Subdomains               | alles auf `*.sharepoint.com` (hier falsch, deshalb ist Host der Standard) |

Passen mehrere Regeln, gewinnt die genaueste: Link vor Host vor Domain.

### Override

Wer beim Klick `⌥` hält, bekommt das Panel auch bei bestehender Regel; die neue
Wahl ersetzt die alte. Das Menüleisten-Symbol zeigt die letzten 10 Weiterleitungen
(nur im Speicher) mit „Regel löschen“ und „In anderem Profil öffnen“.

## Anforderungen

| ID  | Anforderung                                                                                   | Phase |
|-----|-----------------------------------------------------------------------------------------------|-------|
| F1  | Lässt sich in den macOS-Einstellungen als Standardbrowser auswählen                           | MVP   |
| F2  | Kennt alle Brave-Profile mit Namen und Farbe, bemerkt neue oder umbenannte selbst             | MVP   |
| F3  | Öffnet im gewählten Profil, egal ob Brave läuft, geschlossen ist oder ein anderes Profil vorne hat | MVP |
| F4  | Gemerkte Links öffnen ohne Rückfrage; die genaueste Regel gewinnt                             | MVP   |
| F5  | Unbekannte Links zeigen das Panel, vollständig per Tastatur bedienbar                         | MVP   |
| F6  | Die Wahl wird mit der gewählten Ebene gespeichert                                             | MVP   |
| F7  | `⌥` beim Klick erzwingt das Panel; die neue Wahl ersetzt die alte Regel                       | MVP   |
| F8  | Regeln überleben Neustarts und sind ohne die App lesbar und sicherbar                         | MVP   |
| F9  | Einstellungsfenster: Regeln auflisten, ändern, löschen, URL testen                            | v1.0  |
| F10 | Über Sicherheitsdienste umgeleitete Links (Outlook, Teams) nach dem echten Ziel zuordnen      | v1.0  |
| F11 | Regeln abhängig von der Quell-App (z. B. Teams → Kunde)                              | v1.0  |
| F12 | Start bei Anmeldung; optional Standardprofil statt Panel für unbekannte Links                 | v1.0  |

Später denkbar: Brave-Erweiterung „In anderem Profil öffnen“, weitere Browser,
Import aus Finicky/Velja.

## Randfälle

| Fall                                          | Verhalten                                                        |
|-----------------------------------------------|------------------------------------------------------------------|
| Link wird in Brave selbst geklickt            | Bleibt im aktuellen Profil (später: Brave-Erweiterung)           |
| Profil einer Regel wurde gelöscht             | Vorher prüfen, sonst legt Brave ein leeres Profil an. Stattdessen Panel mit Hinweis |
| Allgemeine Login-Seiten (Microsoft, Google)   | Panel bietet nur „Nur einmal“ an                                 |
| Outlook/Teams öffnen Links bewusst in Edge    | Kommt nie an; in der App abschalten, falls möglich               |
| Mail-Adressen, lokale Dateien                 | Werden nicht angefasst                                           |

## Risiken

| Risiko                                                        | Gegenmaßnahme                                              |
|---------------------------------------------------------------|------------------------------------------------------------|
| Brave öffnet den Link im falschen Profil, wenn es schon läuft | Machbarkeitstest an Tag 1. Klappt er nicht: Abbruch, Velja bleibt |
| Firmen-Mails leiten alle Links über einen Sicherheitsdienst um | F10 ins MVP vorziehen                                     |
| Firmen-IT setzt den Standardbrowser zurück                    | Vorab klären, ob der Mac zentral verwaltet wird            |

Aufwand: etwa 3–4 Arbeitstage bis zum MVP, rund eine Woche bis v1.0.

## Offene Fragen

- [ ] Kommen Mails von der eigenen Firma oder vom Kunden mit umgeleiteten Links an? Dann F10 ins MVP.
- [ ] Unbekannte Links: immer fragen oder still im privaten Profil öffnen (`⌥` für das Panel)?
- [ ] Wird der Mac zentral verwaltet, und darf der Standardbrowser geändert werden?
- [ ] Als Open Source veröffentlichen?

## Akzeptanzkriterien

Das MVP ist fertig, wenn eine Arbeitswoche lang kein Link mehr umkopiert werden muss und:

- [ ] ein SharePoint-Link der eigenen Firma aus Outlook im Arbeits-Profil öffnet, auch wenn das Kunden-Profil vorne ist,
- [ ] das Login-Portal des Kunden aus Teams im Kunden-Profil öffnet,
- [ ] ein unbekannter Link das Panel zeigt und sich per Zifferntaste ohne Maus öffnen lässt,
- [ ] derselbe Host nach „Host merken“ nie wieder nachfragt, ein anderer Host derselben Firma schon,
- [ ] `⌥`-Klick auf einen gemerkten Link das Panel zeigt und die neue Wahl sofort gilt,
- [ ] `Esc` im Panel nichts öffnet,
- [ ] bei geschlossenem Brave der Link im richtigen Profil startet,
- [ ] eine Regel auf ein gelöschtes Profil zum Panel führt statt zu einem leeren Profil,
- [ ] ein gemerkter Link ohne spürbare Verzögerung öffnet.
