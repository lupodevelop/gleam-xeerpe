# Changelog

## 1.2.0

Binding for xeerpe 1.0.5 (bundled).

- `animation_target` and `AnimationTarget`: xeerpe's new `target` option, which picks the layers an
  animation moves (gradients, patterns or all). It is a call after the animation, not a field of
  `AnimationOptions`, so existing code keeps compiling. `layer_target` reads it back.
- `css.keyframes` follows the new `animations.css`: the keyframes read `--xeerpe-*` variables, which
  xeerpe now sets per layer, so an animation moves only its own layers.
- `scripts/update-xeerpe.sh` also regenerates `css.keyframes`.
- From xeerpe: `breathe`, `aurora` and `liquid` no longer stretch patterns, and
  `GrainOptions.animated` now does something. The README quirks are updated.
- Demo: a Playground tab (`#playground`). Start from any preset (a searchable picker with a
  preview of each), stack layers, tweak them with a preview of each layer, and copy the Gleam that
  draws the result, syntax-colored. A new gradient goes on top and fades to transparent, since the
  first gradient covers the ones after it.
- Demo: the random gallery now also picks `breathe`, `aurora` and `liquid` for chains with
  patterns.

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
