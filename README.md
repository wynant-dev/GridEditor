# Grid Editor

Flutter web grid editor: place items from a catalog onto a resizable grid.

## Structure

```
lib/
  main.dart
  grid_editor.dart
  src/
    domain/
      catalog/              # Item definitions (CatalogItem, ItemCatalog)
      layout/               # Grid state (GridDocument, PlacedItem)
    services/
      editor_engine.dart    # Bridge: catalog + layout
      placement_rules.dart  # Pure rules (can I place it?)
    ui/
      canvas/               # Grid rendering + input
      toolbar/
      panels/               # Catalog panel, …
    screens/
      grid_editor_screen.dart
assets/catalogs/
  ddv.json
  sandbox.json
```

## Run

```bash
flutter pub get
flutter run -d chrome
```

Default catalog: `assets/catalogs/ddv.json`.

```bash
flutter run -d chrome --dart-define=CATALOG_ASSET=assets/catalogs/sandbox.json
```

**Run and Debug** launch configs:

| Config | Catalog |
|--------|---------|
| Grid Editor (Chrome) | `ddv.json` |
| Grid Editor: sandbox catalog (Chrome) | `sandbox.json` |

## Test

```bash
flutter analyze
flutter test
```

## Web hosting (GitHub Pages)

The app is deployed automatically on every push to `main`.

**Live site:** [https://wynant-dev.github.io/GridEditor/](https://wynant-dev.github.io/GridEditor/)

### One-time GitHub setup

1. Open **Settings → Pages** on the repository.
2. Under **Build and deployment → Source**, choose **GitHub Actions**.

After that, the [Deploy to GitHub Pages](.github/workflows/deploy.yml) workflow builds the Flutter web app and publishes it. The first deploy may take a minute; later pushes update the site on each merge to `main`.

### Local web build

```bash
flutter build web --base-href=/GridEditor/ --release
```

Output is in `build/web/`.

## Architecture

```
catalog JSON → domain/catalog
grid state   → domain/layout
                    ↓
              services/
                EditorEngine   ← holds catalog + layout
                PlacementRules ← overlap, bounds
                    ↓
         ui/ + screens/ + main.dart
```

| Layer | Role |
|-------|------|
| `domain/catalog` | What can be placed (items, catalogs, JSON) |
| `domain/layout` | What is placed (grid size, placements) |
| `services` | `EditorEngine` bridges catalog + layout; `PlacementRules` validates placements |
| `ui` | Reusable widgets (canvas, toolbar, panels) |
| `screens` | Compose widgets into a full screen |
| `main.dart` | App state, load catalog, wire callbacks |

Catalog and layout stay in separate domains. `EditorEngine` connects them; `PlacementRules` holds the pure "can I place it?" logic.
