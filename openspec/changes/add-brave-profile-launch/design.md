# Design

## Context

Das Repo enthält bisher nur die Projekt-Proposal. Es gibt keinen Code. Motivation und Umfang:
siehe `proposal.md` dieses Changes; Anforderungen: siehe die vier Specs.

Rahmenbedingungen:
- Gebaut und getestet wird auf dem Mac des Nutzers (Xcode und Command Line Tools vorhanden).
  Entwickelt wird teilweise in einer Linux-VM, in der kein AppKit verfügbar ist.
- Kein Apple-Entwicklerkonto: Ad-hoc-Signatur, keine Notarisierung.
- Vorlage für Aufbau, Skripte und CI ist das Projekt `henpak/followspot`.

## Goals / Non-Goals

**Goals:**
- Möglichst kleine App, mit der sich der Profilwechsel im Alltag prüfen lässt.
- Logik ohne AppKit in einem eigenen Modul, das sich auch unter Linux testen lässt.
- Aufbau, der Regeln und Panel im nächsten Change ohne Umbau aufnehmen kann.

**Non-Goals:**
- Release-Pipeline, `install.sh`, universelle Downloads (kommt mit dem MVP).
- Andere Browser; die Brave-spezifischen Teile werden nicht vorab abstrahiert.
- Datei-Watcher für Braves Profildaten (Neu-Einlesen bei Bedarf reicht).

## Decisions

### Swift Package statt Xcode-Projekt
Zwei Targets wie bei followspot:
- `BrowserSwitchCore` (Library, nur Foundation): Profildaten parsen, Farben umrechnen,
  Zielprofil auflösen, Startargumente bauen. Unit-Tests mit XCTest, laufen auf macOS und Linux.
- `BrowserSwitch` (Executable, AppKit): App-Delegate, Menü, Start von Brave, Dialoge,
  Standardbrowser-Status.

`scripts/package-app.sh` baut daraus `build/BrowserSwitch.app` (Binary, `Resources/Info.plist`,
`codesign --sign -`), `scripts/build-app.sh` installiert nach `~/Applications` und startet
optional. Bundle-ID `io.github.henpak.browserswitch`, `LSMinimumSystemVersion` 15.0,
`LSUIElement` true.
*Alternative:* Xcode-Projekt – vom Nutzer nicht gewünscht, schwer per Diff zu pflegen.

### Links empfangen über `application(_:open:)`
`Info.plist` deklariert `CFBundleURLTypes` für `http`/`https` und `CFBundleDocumentTypes`
für `public.html`/`public.xhtml` (Rolle Viewer). Ohne die Dokumenttypen listet macOS eine
App nicht zuverlässig als Standardbrowser. AppKit liefert URLs und Dateien gesammelt an
`NSApplicationDelegate.application(_:open:)`; andere Schemata werden ignoriert.
*Alternative:* eigener Apple-Event-Handler für `kAEGetURL` – mehr Code, kein Vorteil.

### Profile aus `Local State`
Quelle: `~/Library/Application Support/BraveSoftware/Brave-Browser/Local State` (JSON).
- `profile.info_cache`: Schlüssel = Profilverzeichnis (`Default`, `Profile 1`, …), daraus
  `name` und Farbe.
- Farbe: `profile_highlight_color`, sonst `default_avatar_fill_color` (Chromium speichert
  beide als vorzeichenbehaftetes 32-Bit-ARGB), sonst Grau.
- Reihenfolge: `profile.profiles_order`, falls vorhanden, sonst `Default` zuerst, dann
  `Profile N` numerisch.
- `profile.last_used` liefert den Startwert, wenn noch kein Zielprofil gewählt ist.

Die Datei wird bei jedem Öffnen des Menüs und vor jedem Link neu gelesen. Sie ist klein
(einige KB), das kostet keine spürbare Zeit und erkennt Änderungen ohne Watcher.
*Alternative:* `FSEvents`-Watcher – mehr Zustand, kein Nutzen bei dieser Dateigröße.

### Brave im Profil starten
`NSWorkspace.openApplication(at:configuration:)` mit
`createsNewApplicationInstance = true` und
`arguments = ["--profile-directory=<Verzeichnis>", "<URL>"]`.
Läuft Brave schon, erkennt der neue Prozess die laufende Instanz (Chromium-Singleton),
übergibt ihr die Kommandozeile und beendet sich; die laufende Instanz öffnet den Link im
angegebenen Profil. Läuft Brave nicht, startet es direkt im Profil. Das entspricht
`open -na "Brave Browser" --args --profile-directory=… <URL>`.
Den Pfad zu Brave liefert `NSWorkspace.urlForApplication(withBundleIdentifier: "com.brave.Browser")`.

Die URL ist immer ein geparstes `http`/`https`/`file`-URL und beginnt deshalb mit einem
Schema, nie mit `--`; sie kann also nicht als Brave-Schalter missverstanden werden.

*Alternativen:* AppleScript (kennt keine Profile); `Process` mit `/usr/bin/open -na`
(gleiches Verhalten, aber ein zusätzlicher Prozess). Letzteres bleibt Ausweichweg, falls der
Machbarkeitstest mit `NSWorkspace` scheitert.

### Zielprofil auflösen und speichern
`UserDefaults` speichert Verzeichnis **und** zuletzt bekannten Namen des Zielprofils. Der
Name wird nur für Hinweise gebraucht, wenn das Profil gelöscht wurde.
Die Auflösung ist eine reine Funktion im Core:

```
 gespeichert?  --nein-->  last_used vorhanden? --ja--> dieses Profil
      |                           |nein
      |                           v
      |                       "Default" (falls vorhanden), sonst erstes Profil, sonst keins
      |ja
      v
 Verzeichnis in Profilen?  --ja-->  Profil
      |nein
      v
 "fehlt: <Name>"   (kein stiller Ersatz)
```

### Standardbrowser-Status
Status: `NSWorkspace.urlForApplication(toOpen: https-URL)` mit dem eigenen Bundle vergleichen.
Festlegen: `NSWorkspace.setDefaultApplication(at:toOpenURLsWithScheme:)` für `http` und
`https`; macOS zeigt dabei seinen eigenen Bestätigungsdialog.

### Hinweise
Fehlendes Profil und fehlendes Brave werden als `NSAlert` gezeigt; die App wird dafür kurz
aktiviert. Die URL steht im Infotext, eine Schaltfläche „URL kopieren“ legt sie in die
Zwischenablage.

### CI
`.github/workflows/ci.yml` nach Vorlage followspot: auf `macos-15` `swift build`,
`swift test`, `scripts/package-app.sh`, Bundle prüfen (`codesign -dv`, `plutil -p`),
Artefakt hochladen; ShellCheck für `scripts/*.sh`. Damit wird der AppKit-Teil auch bei
Änderungen aus der Linux-VM gebaut.

## Risks / Trade-offs

- [Brave leitet die Kommandozeile an die laufende Instanz nicht ins richtige Profil] →
  Das ist der Machbarkeitstest. Zuerst Ausweichweg `open -na` prüfen; scheitert auch der,
  wird das Projekt laut Projekt-Proposal gestoppt.
- [Brave ändert Aufbau oder Ort von `Local State`] → Parser tolerant gegenüber fehlenden
  Feldern; leere Liste plus Hinweis im Menü statt Absturz.
- [Ad-hoc-Signatur ändert sich mit jedem Build] → Die App braucht keine TCC-Freigaben; die
  Standardbrowser-Wahl hängt an der Bundle-ID und bleibt bei Updates erhalten.
- [Brave öffnet beim Kaltstart zusätzlich die gewohnten Start-Tabs] → Akzeptiert.
- [`Local State` wird gelesen, während Brave es schreibt] → Brave schreibt atomar per
  Umbenennen; scheitert das Parsen trotzdem, einmal kurz erneut versuchen, dann Hinweis.
