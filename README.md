<p align="center"><img src="https://raw.githubusercontent.com/lupodevelop/gleam-xeerpe/83b8c6ded15fd46b01dbe44f149f64636dcc7caf/logo.png" alt="xeerpe for Gleam" width="140"></p>

# xeerpe

Gradients, effects, patterns and animations as CSS backgrounds, written in Gleam
with [xeerpe](https://xeerpe.io).

xeerpe is a JavaScript library that builds CSS backgrounds from a chain of calls
(`.linearGradient(...).grain(...).breathe(...)`). This package lets you write that
chain in Gleam and put the result on an element. It uses xeerpe's own
names and options, and carries a copy of xeerpe inside, so you don't need npm.

It was designed and tested with [Lustre](https://lustre.build), and the examples use it. It doesn't
depend on Lustre, though: it only produces CSS, so in principle it fits any framework or plain DOM code
on the JavaScript target. Only Lustre has been tried.

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

`sky()` only describes the background. `css.properties` turns it into the CSS to put on an element.

## What is in it

- `xeerpe` has everything xeerpe has: `linear_gradient`, `mesh_gradient`, `grain`, `dots`, `pulse`,
  `preset`, and so on.
- `xeerpe/quick` has shorter versions of the common calls, like the ones above.
- `xeerpe/css` turns a builder into CSS: `properties` (a list of `#(name, value)`, which is what Lustre's
  `attribute.styles` takes), `text_properties` for gradient text, and `inline` for the text of a `style`
  attribute. If the background animates, the CSS it needs is added to the page for you.
- `xeerpe/colors` is xeerpe's color palette.

`quick` covers the common cases. For all the options, use `xeerpe` directly. Names are
xeerpe's, in snake_case (`linearGradient` is `linear_gradient`). Options are records, and optional
fields are `Option`s. Each options type has a default to start from:

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

A `Builder` is just a description. Nothing is computed until `css.properties` (or `to_style`), so you
can keep one in your model, compare two with `==`, and add to one without changing it.

## Which xeerpe version do I get?

The copy of xeerpe inside this package is one fixed version. `xeerpe.bundled_version` tells you
which. It is only a label: nothing reads it, and it doesn't change by itself.

If xeerpe publishes a newer version and you want it before this package is updated, you can give
the package your own copy. In your project:

1. Install that version from npm: `npm install xeerpe@<version>`.
2. Create `src/my_xeerpe.mjs`, a small file that hands xeerpe over to Gleam:
   ```js
   import * as xeerpe from "xeerpe";
   export const module = () => xeerpe;
   ```
3. Tell the package to use it, once, when your app starts and before anything is drawn:
   ```gleam
   @external(javascript, "./my_xeerpe.mjs", "module")
   fn my_xeerpe() -> Dynamic

   pub fn main() {
     let assert Ok(Nil) = xeerpe.use_module(my_xeerpe())
     // then start your app
   }
   ```

From then on the package runs your xeerpe instead of its own. `xeerpe.use_bundled()` switches back.

What this changes: the behaviour of xeerpe, such as bug fixes and new presets. What it doesn't change:
the Gleam functions and options, which match `bundled_version`. If a newer xeerpe adds a method or an
option, you can't call it from Gleam until this package is updated.

## Things xeerpe does

Seen in the bundled version, <!--v-->0.0.19<!--/v-->:

- `breathe`, `aurora` and `liquid` resize every background layer, so they stretch `dots` and `grid`.
- The `direction` option of an animation is only used by `pulse` and `aurora`.
- `DotsOptions.style` and `GrainOptions.animated` do nothing.
- Gradients repeat by default. While one animates you may see a thin line along an edge; add
  `background-repeat: no-repeat` to the element to remove it.

## Demo

`dev/` is a Lustre app showing every effect, option and color. It is also this project's site. To run it:
`gleam run -m lustre/dev start xeerpe_dev`. Add `#reference` to the address for the full list.
(Lustre is only a development dependency of this package.)

## Working on this package

```sh
npm install --prefix test/npm-xeerpe   # xeerpe from npm: the tests compare this package against it
gleam test
```

To bundle a new xeerpe release, run `scripts/update-xeerpe.sh [version]`. It installs the release,
copies its file into `src/xeerpe_vendor/`, updates `bundled_version` and runs the tests. The tests
fail if the bundled copy ever differs from the npm package. `scripts/build-site.sh` builds the demo site into `dist/`.

## Credits

Everything that builds the backgrounds (the builder, effects, presets, palette and docs) is
[xeerpe](https://github.com/nicolacentonze/xeerpe) by Nicola Centonze. This package is a Gleam
wrapper around it and includes its `index.mjs` under its MIT license (see `LICENSE`). The pink logo
is a parody of xeerpe's green one (Gleam is pink, so it got the transformation) and is not the
official logo.
