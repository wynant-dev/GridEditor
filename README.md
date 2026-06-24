# Grid Editor

Place buildings and objects from a catalog onto a large grid. Pan and zoom to explore your layout, drag pieces into position, and remove what you no longer need.

**Try it in your browser:** [https://wynant-dev.github.io/GridEditor/](https://wynant-dev.github.io/GridEditor/)

## How to use

### Place items

1. Pick an item in the **Catalog** panel on the left.
2. Move the pointer over the grid — a semi-transparent preview shows where the item will land, centered on the cell under your cursor.
3. Click an empty cell to place it.

If a placement is not allowed (out of bounds or overlapping another piece), a message appears at the bottom of the screen.

### Select, move, and delete

- **Select** — click a placed item. A highlight appears around it.
- **Move** — drag a placed item. You can start the drag from anywhere on its footprint; it stays under your finger until you release.
- **Delete** — with an item selected, click the red **×** button on its top-right corner.

To place again after selecting something, choose an item from the catalog first (selection clears the catalog choice).

### Navigate the grid

| Action | Input |
|--------|--------|
| **Zoom** | Scroll wheel / trackpad scroll |
| **Pan** | Middle mouse button + drag |

The grid is large (64×64 cells), so zoom and pan help when working on bigger layouts.

## Default catalog

The live app loads the **DDV catalog**, which includes:

| Item | Size (cells) |
|------|----------------|
| House | 4 × 4 |
| Bank | 2 × 2 |
| Restaurant | 8 × 3 |

Catalogs are defined as JSON under `assets/catalogs/`. The repository also includes a smaller **Sandbox** catalog for testing.

## Run locally

Requires [Flutter](https://docs.flutter.dev/get-started/install) with web support.

```bash
flutter pub get
flutter run -d chrome
```

To use the sandbox catalog instead:

```bash
flutter run -d chrome --dart-define=CATALOG_ASSET=assets/catalogs/sandbox.json
```

## Development

This project is built with Flutter for web. Pushes to `main` deploy automatically to GitHub Pages via [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml).

```bash
flutter analyze
flutter test
```

To build the same bundle used for GitHub Pages:

```bash
flutter build web --base-href=/GridEditor/ --release
```

Output is written to `build/web/`.
