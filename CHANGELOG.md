# Changelog

## 1.1.0

Binding for xeerpe 1.0.2 (bundled), the first stable xeerpe release.

- `stars` and `rays` patterns, with `StarsOptions`, `RaysOptions` and `quick.stars` / `quick.rays`.
- `preset_names` and `preset_categories`: xeerpe now ships 229 presets in 13 categories
  (it had 2). With your own xeerpe older than 1.0 they return `[]`.
- Demo: stars and rays tiles, one preset per category, and an "Examples" group of small UI pieces
  (neon button, avatar ring, loading skeleton, spotlight card, frosted glass, gradient text).
- From xeerpe: `rotate` no longer leaks `; transform-origin: center` into the `animation` value,
  which broke every chain that used it. Colors, validation and the other outputs are unchanged.

## 1.0.0

First release. Binding for xeerpe 0.0.19 (bundled): the whole `Builder` and `Preset` API with typed
options, `xeerpe/quick` shortcuts, `xeerpe/css` (CSS for any framework) and xeerpe's palette.
