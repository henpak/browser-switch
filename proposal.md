Proposal: BrowserSwitch – Brave-Profil-Router für macOS
Nov 24, 2026 · @henpak
Zusammenfassung
BrowserSwitch ist eine kleine macOS-Menüleisten-App, die sich als Standardbrowser einträgt und jeden geklickten Link ins richtige Brave-Profil leitet (privat, Arbeit, Kunde). Bei unbekannten Links fragt sie per Tastendruck nach dem Profil und merkt sich die Wahl wahlweise für den konkreten Link, den Host oder die ganze Domain.
Problem heute: Links aus Outlook, Teams, Slack oder dem Terminal öffnen immer im zuletzt aktiven Brave-Profil. SharePoint von Arbeit landet im Kunden-Profil, der Login-Portal-Login von Kunde im privaten Profil. Jedes Mal folgt Kopieren, Profil wechseln, Einfügen, und SSO-Sitzungen geraten durcheinander.
Warum selbst bauen: Velja deckt das ab, ist aber Closed Source. Finicky ist Open Source, fragt aber nicht nach und merkt sich nichts. Die App ist überschaubar und bleibt vollständig lokal und nachvollziehbar.
Ziele und Scope
Das MVP löst genau einen Fall: Links von außerhalb des Browsers landen ohne Nachdenken im richtigen Brave-Profil.
Ziele
• Links aus jeder App (Outlook, Teams, Slack, Mail, Terminal, IDE) ins richtige Brave-Profil leiten
• Unbekannte Links: Auswahl-Panel, Wahl per Taste in unter einer Sekunde
• Wahl merken auf drei Ebenen: konkreter Link, Host, Domain inkl. Subdomains
• Komplett lokal: kein Netzwerk, keine Telemetrie, Regeln jederzeit einsehbar und änderbar
Nicht-Ziele (MVP)
• Links, die innerhalb von Brave geklickt werden – die verlässt Brave nie (siehe Randfälle)
• Andere Browser als Brave (Architektur hält das offen)
• Windows oder Linux
• Sync zwischen mehreren Macs
Funktion
MVP
v1.0
Später
Als Standardbrowser einsetzbar
x


Brave-Profile automatisch erkennen
x


Auswahl-Panel mit Tastenkürzeln
x


Regeln: Link / Host / Domain
x


Override per Modifier-Taste
x


Einstellungsfenster: Regeln ansehen, bearbeiten, löschen, URL testen

x

Umgeleitete Links aus Outlook und Teams richtig zuordnen

x

Regeln nach Quell-App (z. B. Teams → Kunde)

x

Start bei Anmeldung, Standardprofil-Fallback

x

Brave-Erweiterung „In anderem Profil öffnen“


x
Weitere Chromium-Browser, Safari


x
Import aus Finicky/Velja, iCloud-Sync der Regeln


x
Bedienkonzept
Passt eine Regel, öffnet der Link sofort im Zielprofil, ohne dass etwas aufpoppt. Nur unbekannte Links oder ein bewusster Override zeigen das Auswahl-Panel.
Auswahl-Panel
• Schwebendes Panel an der Mausposition; es übernimmt nicht den Fokus der Quell-App
• Oben die URL, der Host fett hervorgehoben, damit Phishing-Domains auffallen
• Darunter die Profile mit Brave-Avatarfarbe und Nummer: 1 Privat, 2 Arbeit, 3 Kunde
• Darunter die Merk-Ebene als Umschalter: Nur einmal · Dieser Link · Host · Ganze Domain. Tab wechselt, Standard ist „Host“ (einstellbar)
• 1–9 öffnet im Profil und speichert mit der gewählten Ebene · Esc bricht ab, nichts öffnet · ⌘C kopiert die URL
Was „merken“ genau bedeutet
Ebene
Passt auf
Beispiel: gemerkt für https://contoso.sharepoint.com/sites/HR/Doc.aspx?x=1
Dieser Link
Gleicher Host und Pfad, Query und Fragment ignoriert
contoso.sharepoint.com/sites/HR/Doc.aspx
Host
Exakt dieser Host
alles auf contoso.sharepoint.com
Ganze Domain
Die Domain und alle ihre Subdomains
alles auf *.sharepoint.com – hier falsch, deshalb ist Host der Standard
Bei mehreren Treffern gewinnt die spezifischste Regel: Link vor Host vor Domain.
Override und Rückgängig
• ⌥ beim Klicken gedrückt halten zeigt das Panel auch dann, wenn eine Regel existiert; die neue Wahl ersetzt die Regel
• Das Menüleisten-Symbol zeigt die letzten 10 Weiterleitungen mit „Regel löschen“ und „In anderem Profil erneut öffnen“
• Nach dem Merken erscheint kurz ein Hinweis: „Gemerkt: contoso.sharepoint.com → Arbeit“
Funktionale Anforderungen
Zwölf Anforderungen, davon acht fürs MVP. Jede lässt sich im Alltag direkt prüfen (siehe Akzeptanzkriterien).
ID
Anforderung
Phase
F1
Die App lässt sich in den macOS-Einstellungen als Standardbrowser auswählen
MVP
F2
Die App kennt alle Brave-Profile mit Namen und Farbe und bemerkt neue oder umbenannte Profile selbst
MVP
F3
Ein Link öffnet im gewählten Profil – egal ob Brave läuft, geschlossen ist oder gerade ein anderes Profil vorne hat
MVP
F4
Gemerkte Links öffnen ohne Rückfrage; bei mehreren passenden Regeln gewinnt die genaueste
MVP
F5
Unbekannte Links zeigen das Auswahl-Panel, vollständig per Tastatur bedienbar
MVP
F6
Die Wahl im Panel wird mit der gewählten Ebene (Link, Host, Domain) gespeichert
MVP
F7
⌥ beim Klick erzwingt das Panel; die neue Wahl ersetzt die alte Regel
MVP
F8
Regeln bleiben nach Neustart erhalten und lassen sich ohne die App einsehen und sichern
MVP
F9
Einstellungsfenster: Regeln auflisten, ändern, löschen; Testfeld zeigt, welches Profil ein Link bekommen würde
v1.0
F10
Links, die Outlook oder Teams über einen Sicherheitsdienst umleiten, werden nach ihrem eigentlichen Ziel zugeordnet
v1.0
F11
Regeln können zusätzlich davon abhängen, aus welcher App der Link kommt (z. B. Teams → Kunde)
v1.0
F12
Start bei Anmeldung; wahlweise ein Standardprofil statt Panel für unbekannte Links
v1.0
Lösungsansatz
BrowserSwitch sitzt als unsichtbare Zwischenstation zwischen allen Apps und Brave: macOS gibt jeden Link an sie, sie entscheidet das Profil und reicht ihn weiter.
Jede Wahl im Panel wird zur Regel, deshalb taucht das Panel mit der Zeit immer seltener auf.
Grundsätze
• Unsichtbar im Normalfall: Bekannte Links öffnen ohne Verzögerung; die App lebt nur als Symbol in der Menüleiste
• Fragen statt raten: Lieber einmal nachfragen als einen Kundenlink im privaten Profil öffnen
• Alles lokal: Keine Cloud, kein Konto, keine Daten an Dritte; Regeln bleiben auf dem Mac
• Erweiterbar: Brave ist das erste Ziel; weitere Browser sollen später ohne Umbau dazukommen
Randfälle und Einschränkungen
Die größte Einschränkung: Links, die du in Brave selbst klickst, sieht BrowserSwitch nie. macOS fragt den Standardbrowser nur bei Links von außerhalb.
Fall
Verhalten
Lösung
Link wird innerhalb von Brave geklickt
Bleibt im aktuellen Profil
Später: Brave-Erweiterung mit Kontextmenü „Mit BrowserSwitch öffnen“
Profil einer Regel wurde in Brave gelöscht
Brave würde stillschweigend ein neues, leeres Profil anlegen
Vorher prüfen; sonst Panel mit Hinweis „Profil nicht mehr vorhanden“
Allgemeine Login-Seiten (Microsoft, Google)
Eine Regel würde jede Anmeldung in ein einziges Profil zwingen
Für solche Seiten bietet das Panel nur „Nur einmal“ an
Outlook oder Teams öffnen Links bewusst in Edge
Kommt nie bei BrowserSwitch an
In der App „Links in Edge öffnen“ abschalten, falls vorhanden
Apps, die Links in einem eigenen Fenster anzeigen
Link bleibt in der App
Außerhalb des Scopes
Brave ist geschlossen
Beim Start öffnen ggf. zusätzlich die gewohnten Start-Tabs
Akzeptiert
Mail-Adressen, lokale Dateien
Werden nicht angefasst
–
Datenschutz: Die Liste der letzten 10 Weiterleitungen gibt es nur, solange die App läuft. Es wird nichts protokolliert und nichts gesendet.
Meilensteine und Aufwand
Bis zum nutzbaren MVP sind es geschätzt 3–4 Arbeitstage, bis v1.0 etwa eine Woche. Der erste Tag entscheidet, ob sich der Rest lohnt.
Klappt der Profilwechsel im Machbarkeitstest nicht zuverlässig, wird gestoppt, und Velja bleibt die Lösung.
Risiken und offene Fragen
Das Risiko, an dem das Projekt scheitern könnte: dass Brave sich nicht zuverlässig ins gewünschte Profil schicken lässt, wenn es schon läuft. Deshalb wird genau das als Erstes ausprobiert.
Risiko
Wahrscheinlichkeit
Auswirkung
Gegenmaßnahme
Brave öffnet den Link im falschen Profil, wenn es schon läuft
Mittel
Hoch – Kernfunktion
Machbarkeitstest an Tag 1, bevor irgendetwas anderes gebaut wird
Firmen-Mails leiten alle Links über einen Sicherheitsdienst um
Hoch
Hoch – alle Links sehen gleich aus
F10 ins MVP vorziehen
„Ganze Domain“ greift bei gemeinsam genutzten Diensten zu weit (SharePoint, Atlassian)
Mittel
Mittel
„Host“ als Standard; Warnhinweis bei solchen Diensten
Ein Brave-Update ändert, wie Profile verwaltet werden
Niedrig
Mittel
Profile auch ohne Namen auswählbar halten
Die Firmen-IT setzt den Standardbrowser zurück
Unklar
Hoch
Vorab klären, ob der Mac zentral verwaltet wird
Offene Fragen
[ ] Kommen Kunden- oder Arbeits-Mails mit umgeleiteten Links an? Dann F10 ins MVP
[ ] Unbekannte Links: immer fragen oder still im privaten Profil öffnen (⌥ für das Panel)?
[ ] Wird der Mac zentral verwaltet, und darf der Standardbrowser geändert werden?
[ ] Als Open Source veröffentlichen?
Akzeptanzkriterien
Das MVP ist fertig, wenn alle Punkte unten im echten Alltag funktionieren und eine Arbeitswoche lang kein Link mehr kopiert und umgesetzt werden muss.
[ ] SharePoint-Link von Arbeit aus Outlook öffnet im Arbeits-Profil, auch wenn gerade das Kunden-Profil vorne ist
[ ] Login-Portal-Login von Kunde aus Teams öffnet im Kunden-Profil
[ ] Ein privater Link aus Messages öffnet im privaten Profil
[ ] Ein unbekannter Link zeigt das Panel; Wahl per Zifferntaste ohne Maus
[ ] Nach „Host merken“ fragt derselbe Host nie wieder; ein anderer Host derselben Firma schon
[ ] ⌥-Klick auf einen gemerkten Link zeigt das Panel; die neue Wahl gilt ab sofort
[ ] Esc im Panel öffnet nichts
[ ] Ist Brave geschlossen, startet es und zeigt den Link im richtigen Profil
[ ] Nach einem Neustart des Macs sind alle Regeln noch da
[ ] Eine Regel auf ein gelöschtes Profil führt zum Panel, nicht zu einem neuen leeren Profil
[ ] Ein gemerkter Link öffnet ohne spürbare Verzögerung
