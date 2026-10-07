<p align="center"><img src="https://raw.githubusercontent.com/lupodevelop/gleam-xeerpe/83b8c6ded15fd46b01dbe44f149f64636dcc7caf/logo.png" alt="xeerpe for Gleam" width="140"></p>

# xeerpe

CSS backgrounds in Gleam: gradients, patterns, effects, animations and a lot of presets.
A binding for [xeerpe](https://xeerpe.io), with xeerpe bundled (no npm needed).

[Demo](https://lupodevelop.github.io/gleam-xeerpe/) · [Docs](https://hexdocs.pm/xeerpe/) · [xeerpe.io](https://xeerpe.io)

```sh
gleam add xeerpe
```

```gleam
import lustre/attribute
import lustre/element/html
import xeerpe
import xeerpe/css
import xeerpe/quick

fn sky() {
  xeerpe.new()
  |> quick.linear("#FFB347", "#4A1942", deg: 170.0)
  |> quick.vignette(0.3, "#1a0b1f")
  |> quick.grain(3.0)
  |> quick.breathe("6s")
}

pub fn view() {
  html.div([attribute.styles(css.properties(sky()))], [])
}
```

Made for [Lustre](https://lustre.build). It only produces CSS, so it works with anything on the
JavaScript target.

## Modules

- `xeerpe`: every xeerpe call, same names in snake_case (`linearGradient` → `linear_gradient`).
- `xeerpe/quick`: short versions of the common calls.
- `xeerpe/css`: `properties` for `attribute.styles`, `text_properties` for gradient text, `inline`
  for a `style` string. Keyframes for animations are added to the page automatically.
- `xeerpe/colors`: xeerpe's palette.

## All the options

`quick` takes the usual arguments. For everything else, call `xeerpe` with an options record.
Every record has a default to start from:

```gleam
xeerpe.new()
|> xeerpe.linear_gradient(
  xeerpe.LinearGradientOptions(
    ..xeerpe.linear_gradient_options,
    from: Some("#FFB347"),
    to: Some("#4A1942"),
    angle: Some(xeerpe.Deg(170.0)),
  ),
)
```

## Presets

```gleam
let assert Ok(gold) = xeerpe.preset("gold")
gold |> quick.grain(2.0)
```

`xeerpe.preset_names()` lists all, `xeerpe.preset_categories()` groups them.

## Builders are data

A `Builder` is just a list of calls. Nothing runs until `css.properties`. Keep one in your model,
compare with `==`, extend without changing the original.

## Using another xeerpe

The bundled xeerpe is version `xeerpe.bundled_version`. To run a different one:

```sh
npm install xeerpe@<version>
```

```js
// src/my_xeerpe.mjs
import * as xeerpe from "xeerpe";
export const module = () => xeerpe;
```

```gleam
@external(javascript, "./my_xeerpe.mjs", "module")
fn my_xeerpe() -> Dynamic

pub fn main() {
  let assert Ok(Nil) = xeerpe.use_module(my_xeerpe())
  // start your app
}
```

This changes behaviour only. The Gleam API stays the one of the bundled version.
`xeerpe.use_bundled()` switches back.

## Quirks

In xeerpe <!--v-->1.0.2<!--/v-->:

- `breathe`, `aurora` and `liquid` resize every layer, so patterns stretch.
- Animation `direction` only works with `pulse` and `aurora`.
- `DotsOptions.style` and `GrainOptions.animated` do nothing.
- An animated gradient may show a thin line on one edge. Add `background-repeat: no-repeat`.

## Development

```sh
npm install --prefix test/npm-xeerpe   # xeerpe from npm, the tests compare against it
gleam test
gleam run -m lustre/dev start xeerpe_dev   # demo, add #reference for every option
scripts/update-xeerpe.sh [version]         # bundle a new xeerpe release
scripts/build-site.sh                      # demo site into dist/
```

## Credits

[xeerpe](https://github.com/nicolacentonze/xeerpe) by Nicola Centonze does all the work; this is a
Gleam wrapper around it, bundling its `index.mjs` under MIT. The pink logo is a parody of xeerpe's
green one, not the official one.
