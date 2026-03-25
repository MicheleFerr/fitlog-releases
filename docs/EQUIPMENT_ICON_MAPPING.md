# Equipment Icon Mapping

Questa tabella mappa i valori reali del filtro `attrezzatura` (estratti dal DB esercizi)
ai nomi file icona consigliati.

## Path immagini

- Cartella finale: `assets/images/equipment/`
- Formato: `PNG` con sfondo trasparente
- Nome file: `snake_case` minuscolo

## Mapping filtro -> file

| Filtro attrezzatura | File PNG |
|---|---|
| Ab Wheel | `ab_wheel.png` |
| Altro | `altro.png` |
| Assistito | `assistito.png` |
| Barra EZ | `barra_ez.png` |
| Bilanciere | `bilanciere.png` |
| Cavi | `cavi.png` |
| Corde | `corde.png` |
| Corpo Libero | `corpo_libero.png` |
| Cyclette | `cyclette.png` |
| Elastici | `elastici.png` |
| Elastico | `elastici.png` (alias) |
| Ergometro | `ergometro.png` |
| Fitball | `fitball.png` |
| Foam Roller | `foam_roller.png` |
| Kettlebell | `kettlebell.png` |
| Macchina | `macchina.png` |
| Manubri | `manubri.png` |
| Palla Medica | `palla_medica.png` |
| Pneumatico | `pneumatico.png` |
| SkiErg | `skierg.png` |
| Slitta | `slitta.png` |
| Trap Bar | `trap_bar.png` |
| Vario | `vario.png` |
| Zavorre | `zavorre.png` |

## Specifiche consigliate export

- Master design: `1024x1024`
- Output app: `256x256`
- Padding interno: 12-16% (evita icona troppo "schiacciata")
- Peso target: `<= 120 KB` per file (accettabile fino a ~200 KB)

## Riduzione PNG (da ~2MB)

Usa lo script:

```bash
./scripts/optimize_equipment_icons.sh assets/images/equipment_raw assets/images/equipment 256
```

Note:
- `assets/images/equipment_raw` = immagini originali
- `assets/images/equipment` = immagini ottimizzate finali
- Se `pngquant` non è installato, lo script fa comunque resize con `sips`
