# Tasks

## 1. Projektgerüst

- [x] 1.1 `Package.swift` mit `BrowserSwitchCore`, `BrowserSwitch` (Executable) und `BrowserSwitchCoreTests` anlegen, macOS 15; `.gitignore` für `.build/` und `build/`; prüfen: `swift build` baut `BrowserSwitchCore`
- [x] 1.2 `Resources/Info.plist` mit Bundle-ID `io.github.henpak.browserswitch`, `LSUIElement`, `CFBundleURLTypes` (`http`, `https`) und `CFBundleDocumentTypes` (`public.html`, `public.xhtml`); prüfen: `plutil -lint` meldet OK
- [x] 1.3 `scripts/package-app.sh` (Release-Build, Bundle zusammensetzen, `codesign --sign -`, optional `--universal`/`--zip`) und `scripts/build-app.sh` (installieren nach `~/Applications`, `--open`); prüfen: `shellcheck scripts/*.sh` ohne Befunde

## 2. Core: Brave-Profile

- [x] 2.1 `BraveProfile` und Parser für `Local State` (Name, Verzeichnis, Farbe, Reihenfolge, `last_used`), tolerant bei fehlenden Feldern und kaputtem JSON; prüfen: Unit-Tests mit Beispiel-JSON für drei Profile, fehlende Farbe, fehlendes `profiles_order`, ungültiges JSON
- [x] 2.2 Umrechnung vorzeichenbehaftetes ARGB → RGB-Komponenten mit grauer Ersatzfarbe; prüfen: Unit-Tests für negative Werte, `0` und fehlenden Wert
- [x] 2.3 Profilquelle, die `Local State` aus dem Standardpfad liest und „nicht gefunden“ / „nicht lesbar“ unterscheidet; prüfen: Unit-Tests mit temporärem Verzeichnis

## 3. Core: Zielprofil und Start

- [x] 3.1 Zielprofil-Auflösung (gespeichert → vorhanden / fehlt; ohne Speicherung → `last_used` → `Default` → erstes → keins); prüfen: Unit-Tests für jeden Zweig des Diagramms in `design.md`
- [x] 3.2 Startargumente `--profile-directory=<Verzeichnis>` + URL bauen, nur für `http`/`https`/`file`; prüfen: Unit-Tests, inkl. Ablehnung anderer Schemata und Verzeichnisnamen mit Leerzeichen

## 4. App

- [ ] 4.1 App-Einstieg mit `NSApplication`, Aktivierungsmodus Accessory, Menüleisten-Symbol, Menü mit „BrowserSwitch beenden“; prüfen: CI baut, auf dem Mac erscheint nur das Menüleisten-Symbol
- [ ] 4.2 Zielprofil-Menü: Profile mit Farbpunkt, Haken am Ziel, Klick setzt Ziel (Verzeichnis + Name in `UserDefaults`), Neu-Einlesen bei jedem Öffnen, Hinweiszeilen „Brave nicht gefunden“ und „Zielprofil fehlt: <Name>“; prüfen: auf dem Mac Szenarien aus `target-profile-menu`
- [ ] 4.3 Standardbrowser-Status im Menü und „Als Standardbrowser festlegen“; prüfen: auf dem Mac Szenarien aus `default-browser`
- [ ] 4.4 Links empfangen (`application(_:open:)`) und Brave über `NSWorkspace` mit Profilargument starten; Hinweise für fehlendes Profil (mit „In Brave öffnen (ohne Profilwahl)“) und fehlendes Brave (mit „URL kopieren“); prüfen: CI baut, Szenarien aus `brave-launch` auf dem Mac
- [x] 4.5 README um Bauen, Installieren, Als-Standardbrowser-Festlegen und den Machbarkeitstest ergänzen; prüfen: Befehle im README entsprechen den Skripten

## 5. CI

- [x] 5.1 `.github/workflows/ci.yml`: macOS-15 mit `swift build`, `swift test`, `scripts/package-app.sh --universal --zip`, Bundle prüfen, Artefakt hochladen; ShellCheck-Job; prüfen: Lauf auf `main` ist grün

## 6. Machbarkeitstest (auf dem Mac, durch den Nutzer)

- [ ] 6.1 `scripts/build-app.sh --open`, BrowserSwitch als Standardbrowser festlegen; prüfen: erscheint in Systemeinstellungen und ist gewählt
- [ ] 6.2 Ziel „Arbeit“, Kunden-Fenster vorne, Link aus Outlook; prüfen: öffnet im Arbeits-Fenster
- [ ] 6.3 Ziel „Privat“, Brave beendet, Link aus Terminal (`open https://example.com`); prüfen: Brave startet im privaten Profil
- [ ] 6.4 Gelöschtes Testprofil als Ziel, Link öffnen; prüfen: Hinweis erscheint, Brave legt kein neues Profil an

## Workflow follow-up

- Nach bestandenem Machbarkeitstest den Change archivieren.
- Scheitert 6.2 oder 6.3 auch mit dem Ausweichweg `open -na`: Projekt laut Proposal stoppen.
