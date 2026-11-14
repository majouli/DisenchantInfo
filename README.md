# Disenchant Info

Zeigt im Tooltip, was deine Berufe herausholen – Material, Menge, Chance und
AH-Preis:

| Beruf        | Tooltip über …   | Zusätzlich                                 |
|--------------|------------------|--------------------------------------------|
| Entzaubern   | Gegenständen     |                                            |
| Kürschnerei  | Tieren           | nötige Stufe; neue Forever-Tiere geschätzt |
| Bergbau      | Erzvorkommen     | nötige Stufe, wie oft abbaubar             |
| Kräuterkunde | Pflanzen         | nötige Stufe, Beifunde                     |

## Bedienung
- **/dei** oder Linksklick auf das Minimap-Icon öffnet das Fenster,
  Rechtsklick schaltet alle Tooltip-Zeilen an / aus.
- Standard: nur die Berufe, die der Charakter gelernt hat (automatisch erkannt).
- Jeder Beruf hat eine eigene Karte zum An- und Ausschalten.
- Das Zahnrad wählt die Sprache: Deutsch, English, Français, Español, Русский
  oder automatisch (die Sprache des Spiels).

## AH-Preise
Bei jedem Besuch im Auktionshaus holt das Addon unbemerkt die Preise aller
Materialien. Sucht man selbst, wartet der Scan kurz und macht dann weiter.
Materialien ohne Angebot werden nur einmal pro Stunde erneut gesucht.

## Installation
Den Ordner `DisenchantInfo` nach
`World of Warcraft\_forever_\Interface\AddOns\` kopieren und das Spiel
starten (oder `/reload`).

---

## Entwicklung

### Aufbau
| Ordner         | Inhalt                                                             |
|----------------|--------------------------------------------------------------------|
| `Data/`        | Tabellen. `Disenchant.lua` von Hand gepflegt, alle anderen erzeugt |
| `Locales/`     | `Locales.lua` (Sprachsystem) und eine Datei pro Sprache            |
| `Core/`        | Einstellungen, Berufserkennung, Preise, AH-Scan                    |
| `Professions/` | was Entzaubern, Kürschnern und Sammeln ergibt                      |
| `UI/`          | Tooltip, Fenster, Bausteine, Minimap-Icon                          |

Die Ladereihenfolge steht in `DisenchantInfo.toc`.

### Neue Forever-Version
Die erzeugten Tabellen (`Data/Skinning.lua`, `Mining.lua`, `Herbalism.lua`,
`ItemNames.lua`) nie von Hand ändern, sondern neu erzeugen:

```
python tools/gen_professions.py --build <Client-Build>
```

Die Build-Nummer steht auf wago.tools (z. B. `1.60.1.70790`). Das Skript lädt
alle Quellen selbst in einen Zwischenspeicher und schreibt die Dateien neu.
Danach `tools/check.ps1` laufen lassen und `## Version` in der `.toc` erhöhen.

Neue Sprache: eine Datei `Locales/<code>.lua` anlegen, in `ns.LANGUAGES`
(`Locales/Locales.lua`), in `LANGUAGES` des Generators und in der `.toc`
eintragen.

### Datenquellen
- Beute, Chancen, Mengen, Abbau-Anzahl: [cMaNGOS classic-db](https://github.com/cmangos/classic-db)
  (GPL-3.0); übernommen werden nur Zahlen und Namen.
- Nötige Stufe von Erz- und Kräutervorkommen, Materialnamen in allen Sprachen:
  Tabellen `Lock` und `ItemSparse` des Forever-Clients über [wago.tools](https://wago.tools).
- Entzauber-Tabellen (`Data/Disenchant.lua`): Classic-Regeln nach benötigter
  Stufe, Qualität und Art; Erfahrungswerte, keine Garantie.
