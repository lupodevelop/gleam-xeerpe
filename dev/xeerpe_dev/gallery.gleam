import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import xeerpe
import xeerpe/colors
import xeerpe/quick as q
import xeerpe_dev/swatches

/// How a tile is drawn: filled by the pipeline, or as a box on a base.
pub type Preview {
  Fill(xeerpe.Builder)
  On(base: xeerpe.Builder, box: xeerpe.Builder)
  /// Gradient text (`to_text_style`).
  Text(xeerpe.Builder, String)
  /// A plain color.
  Swatch(String)
}

pub type Card {
  Card(group: String, title: String, code: String, preview: Preview)
}

pub const groups = [
  "Gradients", "Effects", "Filters", "Patterns", "Animations", "Presets",
  "Examples",
]

/// A night sky for the stars and rays tiles.
pub fn night() -> xeerpe.Builder {
  xeerpe.new()
  |> xeerpe.radial_gradient(
    xeerpe.RadialGradientOptions(
      ..xeerpe.radial_gradient_options,
      from: Some("#1b2559"),
      to: Some("#050816"),
      position: Some("30% 20%"),
      color_to_position: Some("90%"),
    ),
  )
}

pub fn sky() -> xeerpe.Builder {
  q.linear(xeerpe.new(), "#FFB347", "#4A1942", deg: 170.0)
}

pub fn dusk() -> xeerpe.Builder {
  q.linear(xeerpe.new(), colors.midnight_oil, colors.aubergine, deg: 160.0)
}

pub fn preset(name: String) -> xeerpe.Builder {
  xeerpe.preset(name) |> result.unwrap(xeerpe.new())
}

pub fn cards() -> List(Card) {
  [
    Card(
      "Gradients",
      "linear",
      "quick.linear(\"#FFB347\", \"#4A1942\", deg: 170.0)",
      Fill(sky()),
    ),
    Card(
      "Gradients",
      "linear · multi-stop",
      "quick.linear_colors([crimson, saffron, malachite, cobalt, iris], deg: 90.0)",
      Fill(q.linear_colors(
        xeerpe.new(),
        [
          colors.crimson,
          colors.saffron,
          colors.malachite,
          colors.cobalt,
          colors.iris,
        ],
        deg: 90.0,
      )),
    ),
    Card(
      "Gradients",
      "radial",
      "quick.radial(coral, midnight_oil)",
      Fill(q.radial(xeerpe.new(), colors.coral, colors.midnight_oil)),
    ),
    Card(
      "Gradients",
      "conic",
      "quick.conic(sakura, cerulean)",
      Fill(q.conic(xeerpe.new(), colors.sakura, colors.cerulean)),
    ),
    Card(
      "Gradients",
      "mesh",
      "quick.mesh(\"#050914\", [#(\"15% 20%\", malachite), #(\"70% 30%\", amethyst), #(\"40% 85%\", cerulean)])",
      Fill(
        q.mesh(xeerpe.new(), "#050914", [
          #("15% 20%", colors.malachite),
          #("70% 30%", colors.amethyst),
          #("40% 85%", colors.cerulean),
        ]),
      ),
    ),
    Card(
      "Effects",
      "noise",
      "sky |> quick.noise(0.3)",
      Fill(q.noise(sky(), 0.3)),
    ),
    Card(
      "Effects",
      "grain",
      "sky |> quick.grain(3.0)",
      Fill(q.grain(sky(), 3.0)),
    ),
    Card(
      "Effects",
      "vignette",
      "sky |> quick.vignette(0.6, \"#1a0b1f\")",
      Fill(q.vignette(sky(), 0.6, "#1a0b1f")),
    ),
    Card(
      "Effects",
      "glow",
      "quick.glow(magenta, \"28px\")",
      On(
        dusk(),
        q.linear(xeerpe.new(), colors.magenta, colors.iris, deg: 135.0)
          |> q.glow(colors.magenta, "28px"),
      ),
    ),
    Card(
      "Filters",
      "blur (backdrop)",
      "quick.backdrop_blur(\"8px\")",
      On(
        q.linear_colors(
          xeerpe.new(),
          [colors.coral, colors.saffron, colors.cerulean, colors.iris],
          deg: 120.0,
        ),
        q.linear(
          xeerpe.new(),
          "rgba(255,255,255,0.35)",
          "rgba(255,255,255,0.08)",
          deg: 135.0,
        )
          |> q.backdrop_blur("8px"),
      ),
    ),
    Card(
      "Patterns",
      "dots",
      "dusk |> quick.dots(\"#ffffff\", \"16px\", \"20px\", 0.5)",
      Fill(q.dots(dusk(), "#ffffff", "16px", "20px", 0.5)),
    ),
    Card(
      "Patterns",
      "grid",
      "dusk |> quick.grid(\"#ffffff\", \"24px\", 0.2)",
      Fill(q.grid(dusk(), "#ffffff", "24px", 0.2)),
    ),
    Card(
      "Patterns",
      "stars",
      "night |> quick.stars(\"#ffffff\", \"160px\", 30, 4)",
      Fill(q.stars(night(), "#ffffff", "160px", 30, 4)),
    ),
    Card(
      "Patterns",
      "rays",
      "sun |> quick.rays(\"#e6c35c\", 18, \"50% 115%\", 0.12)",
      Fill(
        xeerpe.new()
        |> xeerpe.radial_gradient(
          xeerpe.RadialGradientOptions(
            ..rg,
            from: Some("#e6c35c"),
            to: Some("#15130e"),
            position: Some("50% 115%"),
            color_to_position: Some("70%"),
          ),
        )
        |> q.rays("#e6c35c", 18, "50% 115%", 0.12),
      ),
    ),
    Card(
      "Animations",
      "pulse",
      "sky |> quick.pulse(\"1.2s\")",
      Fill(q.pulse(sky(), "1.2s")),
    ),
    Card(
      "Animations",
      "breathe",
      "gradient |> quick.breathe(\"2.5s\")",
      Fill(q.breathe(
        q.linear_colors(
          xeerpe.new(),
          [
            colors.crimson,
            colors.saffron,
            colors.malachite,
            colors.cobalt,
            colors.iris,
          ],
          deg: 45.0,
        ),
        "2.5s",
      )),
    ),
    Card(
      "Animations",
      "aurora",
      "mesh |> quick.aurora(\"2s\")",
      Fill(q.aurora(
        q.mesh(xeerpe.new(), "#050914", [
          #("15% 20%", colors.malachite),
          #("70% 30%", colors.amethyst),
          #("40% 85%", colors.cerulean),
        ]),
        "2s",
      )),
    ),
    Card(
      "Animations",
      "rotate",
      "gradient |> quick.rotate(\"3s\")",
      On(
        dusk(),
        q.rotate(q.conic(xeerpe.new(), colors.coral, colors.iris), "3s"),
      ),
    ),
    Card(
      "Animations",
      "shimmer",
      "gradient |> quick.shimmer(\"2.5s\")",
      Fill(q.shimmer(
        q.linear_colors(
          xeerpe.new(),
          [colors.midnight_oil, colors.sakura, colors.midnight_oil],
          deg: 100.0,
        )
          |> q.noise(0.1),
        "2.5s",
      )),
    ),
    Card(
      "Animations",
      "liquid",
      "gradient |> quick.liquid(\"4s\")",
      Fill(q.liquid(
        q.linear_colors(
          xeerpe.new(),
          [
            colors.crimson,
            colors.saffron,
            colors.malachite,
            colors.cobalt,
            colors.iris,
          ],
          deg: 45.0,
        ),
        "4s",
      )),
    ),
    Card(
      "Animations",
      "plasma",
      "gradient |> quick.plasma(\"6s\")",
      Fill(q.plasma(q.conic(xeerpe.new(), colors.coral, colors.cerulean), "6s")),
    ),
    Card(
      "Animations",
      "float",
      "gradient |> quick.float(\"2s\")",
      On(
        dusk(),
        q.float(
          q.linear(xeerpe.new(), colors.coral, colors.iris, deg: 135.0)
            |> q.glow(colors.coral, "24px"),
          "2s",
        ),
      ),
    ),
    Card(
      "Animations",
      "drift",
      "mesh |> quick.drift(\"5s\")",
      Fill(q.drift(
        q.linear_colors(
          xeerpe.new(),
          [colors.cobalt, colors.magenta, colors.saffron, colors.teal],
          deg: 60.0,
        ),
        "5s",
      )),
    ),
    ..list.append(preset_cards(), example_cards())
  ]
}

/// The first preset of every category; `xeerpe.preset_names` has them all.
fn preset_cards() -> List(Card) {
  xeerpe.preset_categories()
  |> list.filter_map(fn(c) {
    case c.1 {
      [name, ..] ->
        Ok(Card(
          "Presets",
          c.0 <> " · " <> name,
          "xeerpe.preset(\"" <> name <> "\")",
          Fill(preset(name)),
        ))
      [] -> Error(Nil)
    }
  })
}

/// Small UI pieces (the ones xeerpe's docs use), each with the Gleam that makes it.
fn example_cards() -> List(Card) {
  let g = xeerpe.glow_options
  [
    Card(
      "Examples",
      "Neon button",
      "xeerpe.new()
|> quick.linear(\"#06080f\", \"#0b1020\", deg: 180.0)
|> quick.glow(\"#22d3ee\", \"18px\")
|> xeerpe.glow(GlowOptions(..glow_options, type_: Some(Inner), color: Some(\"#22d3ee\"), amount: Some(\"12px\")))",
      On(
        dusk(),
        q.linear(xeerpe.new(), "#06080f", "#0b1020", deg: 180.0)
          |> q.glow("#22d3ee", "18px")
          |> xeerpe.glow(
            xeerpe.GlowOptions(
              ..g,
              type_: Some(xeerpe.Inner),
              color: Some("#22d3ee"),
              amount: Some("12px"),
            ),
          ),
      ),
    ),
    Card(
      "Examples",
      "Avatar ring",
      "xeerpe.new()
|> xeerpe.conic_gradient(ConicGradientOptions(..conic_gradient_options, colors: Some([Color(\"#5EB847\"), Color(\"#CAD328\"), Color(\"#22d3ee\"), Color(\"#7a5cff\"), Color(\"#5EB847\")])))
|> quick.rotate(\"4s\")",
      On(
        dusk(),
        xeerpe.new()
          |> xeerpe.conic_gradient(
            xeerpe.ConicGradientOptions(
              ..xeerpe.conic_gradient_options,
              colors: Some(list.map(
                ["#5EB847", "#CAD328", "#22d3ee", "#7a5cff", "#5EB847"],
                xeerpe.Color,
              )),
            ),
          )
          |> q.rotate("4s"),
      ),
    ),
    Card(
      "Examples",
      "Loading skeleton",
      "xeerpe.new()
|> xeerpe.linear_gradient(LinearGradientOptions(..linear_gradient_options, colors: Some([Color(\"#1c2620\"), Color(\"#2f3d34\"), Color(\"#1c2620\")]), angle: Some(Deg(90.0)), background_size: Some(\"200% 100%\")))
|> quick.shimmer(\"1.6s\")",
      On(
        dusk(),
        xeerpe.new()
          |> xeerpe.linear_gradient(
            xeerpe.LinearGradientOptions(
              ..lg,
              colors: Some(list.map(
                ["#1c2620", "#2f3d34", "#1c2620"],
                xeerpe.Color,
              )),
              angle: Some(xeerpe.Deg(90.0)),
              background_size: Some("200% 100%"),
            ),
          )
          |> q.shimmer("1.6s"),
      ),
    ),
    Card(
      "Examples",
      "Spotlight card",
      "xeerpe.new()
|> xeerpe.radial_gradient(RadialGradientOptions(..radial_gradient_options, from: Some(\"rgba(94,184,71,0.35)\"), to: Some(\"transparent\"), position: Some(\"0% 0%\"), color_to_position: Some(\"70%\")))
|> quick.linear(\"#0c140e\", \"#060906\", deg: 180.0)
|> xeerpe.dots(DotsOptions(..dots_options, color: Some(\"#5EB847\"), size: Some(\"18px\"), opacity: Some(0.18)))
|> xeerpe.glow(GlowOptions(..glow_options, type_: Some(Inner), color: Some(\"rgba(94,184,71,0.35)\"), amount: Some(\"30px\")))",
      On(
        dusk(),
        xeerpe.new()
          |> xeerpe.radial_gradient(
            xeerpe.RadialGradientOptions(
              ..rg,
              from: Some("rgba(94,184,71,0.35)"),
              to: Some("transparent"),
              position: Some("0% 0%"),
              color_to_position: Some("70%"),
            ),
          )
          |> q.linear("#0c140e", "#060906", deg: 180.0)
          |> xeerpe.dots(
            xeerpe.DotsOptions(
              ..xeerpe.dots_options,
              color: Some("#5EB847"),
              size: Some("18px"),
              opacity: Some(0.18),
            ),
          )
          |> xeerpe.glow(
            xeerpe.GlowOptions(
              ..g,
              type_: Some(xeerpe.Inner),
              color: Some("rgba(94,184,71,0.35)"),
              amount: Some("30px"),
            ),
          ),
      ),
    ),
    Card(
      "Examples",
      "Frosted glass",
      "xeerpe.new()
|> quick.linear(\"rgba(255,255,255,0.22)\", \"rgba(255,255,255,0.06)\", deg: 180.0)
|> quick.backdrop_blur(\"14px\")",
      On(
        preset("northern-lights"),
        q.linear(
          xeerpe.new(),
          "rgba(255,255,255,0.22)",
          "rgba(255,255,255,0.06)",
          deg: 180.0,
        )
          |> q.backdrop_blur("14px"),
      ),
    ),
    Card(
      "Examples",
      "Gradient text",
      "xeerpe.new()
|> quick.linear_colors([\"#5EB847\", \"#CAD328\", \"#ffd166\"], deg: 90.0)
|> css.text_properties",
      Text(
        q.linear_colors(
          xeerpe.new(),
          ["#5EB847", "#CAD328", "#ffd166"],
          deg: 90.0,
        ),
        "xeerpe",
      ),
    ),
  ]
}

// -- Reference: a tile per option and variant --

const a = "#FFB347"

const b = "#4A1942"

const lg = xeerpe.linear_gradient_options

const rg = xeerpe.radial_gradient_options

fn fill(
  group: String,
  title: String,
  code: String,
  builder: xeerpe.Builder,
) -> Card {
  Card(group, title, code, Fill(builder))
}

fn on(
  group: String,
  title: String,
  code: String,
  base: xeerpe.Builder,
  box: xeerpe.Builder,
) -> Card {
  Card(group, title, code, On(base, box))
}

fn linear(o: xeerpe.LinearGradientOptions) -> xeerpe.Builder {
  xeerpe.new() |> xeerpe.linear_gradient(o)
}

fn radial(o: xeerpe.RadialGradientOptions) -> xeerpe.Builder {
  xeerpe.new() |> xeerpe.radial_gradient(o)
}

fn conic(o: xeerpe.ConicGradientOptions) -> xeerpe.Builder {
  xeerpe.new() |> xeerpe.conic_gradient(o)
}

fn ab() -> xeerpe.LinearGradientOptions {
  xeerpe.LinearGradientOptions(..lg, from: Some(a), to: Some(b))
}

fn rab() -> xeerpe.RadialGradientOptions {
  xeerpe.RadialGradientOptions(..rg, from: Some(a), to: Some(b))
}

fn box_bg() -> xeerpe.Builder {
  q.linear(xeerpe.new(), colors.coral, colors.iris, deg: 135.0)
}

fn on_dusk(
  group: String,
  title: String,
  code: String,
  box: xeerpe.Builder,
) -> Card {
  on(group, title, code, dusk(), box)
}

/// Sections of tiles, in order.
pub fn reference() -> List(#(String, List(Card))) {
  [
    #("Linear · direction", linear_direction()),
    #("Linear · angle", linear_angle()),
    #("Linear · stop positions", linear_positions()),
    #("Linear · size", linear_size()),
    #("Radial · shape", radial_shape()),
    #("Radial · size", radial_size()),
    #("Radial · position & stops", radial_other()),
    #("Conic", conic_tiles()),
    #("Mesh", mesh_tiles()),
    #("Noise", noise_tiles()),
    #("Vignette", vignette_tiles()),
    #("Grain", grain_tiles()),
    #("Glow", glow_tiles()),
    #("Blur", blur_tiles()),
    #("Dots", dots_tiles()),
    #("Grid", grid_tiles()),
    #("Stars", stars_tiles()),
    #("Rays", rays_tiles()),
    #("Animation options", animation_option_tiles()),
    #("Generic methods", generic_tiles()),
    #("Text fill", text_tiles()),
    ..list.append(preset_tiles(), [#("Colors", color_tiles())])
  ]
}

/// Every preset, one section per category.
fn preset_tiles() -> List(#(String, List(Card))) {
  xeerpe.preset_categories()
  |> list.map(fn(c) {
    #(
      "Presets · " <> c.0,
      list.map(c.1, fn(name) {
        fill("presets", name, "xeerpe.preset(\"" <> name <> "\")", preset(name))
      }),
    )
  })
}

fn linear_direction() -> List(Card) {
  [
    #("ToTop", xeerpe.ToTop),
    #("ToBottom", xeerpe.ToBottom),
    #("ToLeft", xeerpe.ToLeft),
    #("ToRight", xeerpe.ToRight),
    #("ToTopRight", xeerpe.ToTopRight),
    #("ToBottomRight", xeerpe.ToBottomRight),
    #("ToTopLeft", xeerpe.ToTopLeft),
    #("ToBottomLeft", xeerpe.ToBottomLeft),
  ]
  |> list.map(fn(d) {
    fill(
      "linear",
      d.0,
      "direction: Some(" <> d.0 <> ")",
      linear(xeerpe.LinearGradientOptions(..ab(), direction: Some(d.1))),
    )
  })
}

fn linear_angle() -> List(Card) {
  [
    #("Deg(135.0)", xeerpe.Deg(135.0)),
    #("Rad(2.4)", xeerpe.Rad(2.4)),
    #("Grad(150.0)", xeerpe.Grad(150.0)),
    #("Turn(0.4)", xeerpe.Turn(0.4)),
  ]
  |> list.map(fn(x) {
    fill(
      "linear",
      x.0,
      "angle: Some(" <> x.0 <> ")",
      linear(xeerpe.LinearGradientOptions(..ab(), angle: Some(x.1))),
    )
  })
}

fn linear_positions() -> List(Card) {
  [
    #("Percent(50.0)", xeerpe.Unit(xeerpe.Percent(50.0))),
    #("Px(120.0)", xeerpe.Unit(xeerpe.Px(120.0))),
    #("Rem(8.0)", xeerpe.Unit(xeerpe.Rem(8.0))),
    #("Em(8.0)", xeerpe.Unit(xeerpe.Em(8.0))),
    #("Vh(15.0)", xeerpe.Unit(xeerpe.Vh(15.0))),
    #("Vw(10.0)", xeerpe.Unit(xeerpe.Vw(10.0))),
    #("Vmin(12.0)", xeerpe.Unit(xeerpe.Vmin(12.0))),
    #("Vmax(8.0)", xeerpe.Unit(xeerpe.Vmax(8.0))),
    #("Calc(\"50% + 20px\")", xeerpe.Calc("50% + 20px")),
  ]
  |> list.map(fn(p) {
    fill(
      "linear",
      p.0,
      "PositionedColor(coral, Some(" <> p.0 <> "))",
      linear(
        xeerpe.LinearGradientOptions(
          ..lg,
          angle: Some(xeerpe.Deg(90.0)),
          colors: Some([
            xeerpe.Color(colors.midnight_oil),
            xeerpe.PositionedColor(colors.coral, Some(p.1)),
            xeerpe.Color(colors.saffron),
          ]),
        ),
      ),
    )
  })
}

fn linear_size() -> List(Card) {
  [
    fill(
      "linear",
      "size",
      "size: Some(\"60%\")",
      linear(xeerpe.LinearGradientOptions(..ab(), size: Some("60%"))),
    ),
    fill(
      "linear",
      "background_size",
      "background_size: Some(\"200% 100%\")",
      linear(
        xeerpe.LinearGradientOptions(..ab(), background_size: Some("200% 100%")),
      ),
    ),
  ]
}

fn radial_shape() -> List(Card) {
  [
    #("Circle", xeerpe.Circle),
    #("Ellipse", xeerpe.Ellipse),
    #("NullShape", xeerpe.NullShape),
  ]
  |> list.map(fn(s) {
    fill(
      "radial",
      s.0,
      "shape: Some(" <> s.0 <> ")",
      radial(xeerpe.RadialGradientOptions(..rab(), shape: Some(s.1))),
    )
  })
}

fn radial_size() -> List(Card) {
  [
    #("ClosestSide", xeerpe.ClosestSide),
    #("ClosestCorner", xeerpe.ClosestCorner),
    #("FarthestSide", xeerpe.FarthestSide),
    #("FarthestCorner", xeerpe.FarthestCorner),
    #("CustomSize(\"40px 80px\")", xeerpe.CustomSize("40px 80px")),
  ]
  |> list.map(fn(s) {
    // two-length sizes are only valid CSS on an ellipse
    let shape = case s.1 {
      xeerpe.CustomSize(_) -> Some(xeerpe.Ellipse)
      _ -> None
    }
    let code = case shape {
      Some(_) -> "shape: Some(Ellipse), size: Some(" <> s.0 <> ")"
      None -> "size: Some(" <> s.0 <> ")"
    }
    fill(
      "radial",
      s.0,
      code,
      radial(
        xeerpe.RadialGradientOptions(..rab(), shape: shape, size: Some(s.1)),
      ),
    )
  })
}

fn radial_other() -> List(Card) {
  [
    fill(
      "radial",
      "position",
      "position: Some(\"20% 30%\")",
      radial(xeerpe.RadialGradientOptions(..rab(), position: Some("20% 30%"))),
    ),
    fill(
      "radial",
      "color_from/to_position",
      "color_from_position: \"20%\", color_to_position: \"70%\"",
      radial(
        xeerpe.RadialGradientOptions(
          ..rab(),
          color_from_position: Some("20%"),
          color_to_position: Some("70%"),
        ),
      ),
    ),
    fill(
      "radial",
      "background_size",
      "background_size: Some(\"50% 50%\")",
      radial(
        xeerpe.RadialGradientOptions(..rab(), background_size: Some("50% 50%")),
      ),
    ),
  ]
}

fn conic_tiles() -> List(Card) {
  let c = xeerpe.conic_gradient_options
  let stops = [
    xeerpe.Color(colors.crimson),
    xeerpe.PositionedColor(
      colors.saffron,
      Some(xeerpe.Unit(xeerpe.Percent(40.0))),
    ),
    xeerpe.Color(colors.cobalt),
  ]
  [
    fill(
      "conic",
      "from / to",
      "from: Some(coral), to: Some(iris)",
      conic(
        xeerpe.ConicGradientOptions(
          ..c,
          from: Some(colors.coral),
          to: Some(colors.iris),
        ),
      ),
    ),
    fill(
      "conic",
      "colors",
      "colors: Some([Color(..), PositionedColor(..), Color(..)])",
      conic(xeerpe.ConicGradientOptions(..c, colors: Some(stops))),
    ),
    fill(
      "conic",
      "angle",
      "angle: Some(\"90deg\")",
      conic(
        xeerpe.ConicGradientOptions(
          ..c,
          colors: Some(stops),
          angle: Some("90deg"),
        ),
      ),
    ),
    fill(
      "conic",
      "position",
      "position: Some(\"20% 30%\")",
      conic(
        xeerpe.ConicGradientOptions(
          ..c,
          colors: Some(stops),
          position: Some("20% 30%"),
        ),
      ),
    ),
    fill(
      "conic",
      "background_size",
      "background_size: Some(\"50% 50%\")",
      conic(
        xeerpe.ConicGradientOptions(
          ..c,
          colors: Some(stops),
          background_size: Some("50% 50%"),
        ),
      ),
    ),
  ]
}

fn mesh_tiles() -> List(Card) {
  let blob = fn(pos, c) {
    xeerpe.RadialGradientOptions(
      ..rg,
      position: Some(pos),
      from: Some(c),
      to: Some("transparent"),
      color_from_position: Some("0px"),
      color_to_position: Some("55%"),
    )
  }
  let mesh = fn(layers) {
    xeerpe.new()
    |> xeerpe.mesh_gradient(xeerpe.mesh_gradient_options("#050914", layers))
  }
  [
    fill(
      "mesh",
      "layers",
      "mesh_gradient_options(\"#050914\", [blob, blob, blob])",
      mesh([
        blob("15% 20%", colors.malachite),
        blob("70% 30%", colors.amethyst),
        blob("40% 85%", colors.cerulean),
      ]),
    ),
    fill(
      "mesh",
      "layer shape & size",
      "layers: [RadialGradientOptions(..rg, shape: Some(Ellipse), size: Some(ClosestSide))]",
      mesh([
        xeerpe.RadialGradientOptions(
          ..blob("30% 40%", colors.coral),
          shape: Some(xeerpe.Ellipse),
          size: Some(xeerpe.ClosestSide),
        ),
        blob("80% 70%", colors.iris),
      ]),
    ),
  ]
}

fn noise_tiles() -> List(Card) {
  let n = xeerpe.noise_options
  let noisy = fn(o) { sky() |> xeerpe.noise(o) }
  [
    fill(
      "noise",
      "Turbulence",
      "type_: Some(Turbulence), opacity: Some(0.4)",
      noisy(
        xeerpe.NoiseOptions(
          ..n,
          type_: Some(xeerpe.Turbulence),
          opacity: Some(0.4),
        ),
      ),
    ),
    fill(
      "noise",
      "FractalNoise",
      "type_: Some(FractalNoise), opacity: Some(0.4)",
      noisy(
        xeerpe.NoiseOptions(
          ..n,
          type_: Some(xeerpe.FractalNoise),
          opacity: Some(0.4),
        ),
      ),
    ),
    fill(
      "noise",
      "opacity",
      "opacity: Some(0.8)",
      noisy(xeerpe.NoiseOptions(..n, opacity: Some(0.8))),
    ),
    fill(
      "noise",
      "scale",
      "scale: Some(4.0), opacity: Some(0.5)",
      noisy(xeerpe.NoiseOptions(..n, scale: Some(4.0), opacity: Some(0.5))),
    ),
    fill(
      "noise",
      "octaves",
      "octaves: Some(1), opacity: Some(0.5)",
      noisy(xeerpe.NoiseOptions(..n, octaves: Some(1), opacity: Some(0.5))),
    ),
    fill(
      "noise",
      "background_size",
      "background_size: Some(\"80px 80px\")",
      noisy(
        xeerpe.NoiseOptions(
          ..n,
          opacity: Some(0.5),
          background_size: Some("80px 80px"),
        ),
      ),
    ),
  ]
}

fn vignette_tiles() -> List(Card) {
  let v = xeerpe.vignette_options
  let vig = fn(o) { sky() |> xeerpe.vignette(o) }
  [
    fill(
      "vignette",
      "intensity",
      "intensity: Some(0.8)",
      vig(xeerpe.VignetteOptions(..v, intensity: Some(0.8))),
    ),
    fill(
      "vignette",
      "color",
      "color: Some(\"#4a0066\"), intensity: Some(0.8)",
      vig(
        xeerpe.VignetteOptions(
          ..v,
          color: Some("#4a0066"),
          intensity: Some(0.8),
        ),
      ),
    ),
    fill(
      "vignette",
      "spread",
      "spread: Some(0.2), intensity: Some(0.8)",
      vig(xeerpe.VignetteOptions(..v, spread: Some(0.2), intensity: Some(0.8))),
    ),
  ]
}

fn grain_tiles() -> List(Card) {
  let g = xeerpe.grain_options
  let gr = fn(o) { sky() |> xeerpe.grain(o) }
  [
    fill(
      "grain",
      "intensity",
      "intensity: Some(8.0)",
      gr(xeerpe.GrainOptions(..g, intensity: Some(8.0))),
    ),
    fill(
      "grain",
      "size",
      "size: Some(\"3px\"), intensity: Some(6.0)",
      gr(xeerpe.GrainOptions(..g, size: Some("3px"), intensity: Some(6.0))),
    ),
    fill(
      "grain",
      "background_size",
      "background_size: Some(\"60px 60px\")",
      gr(
        xeerpe.GrainOptions(
          ..g,
          intensity: Some(6.0),
          background_size: Some("60px 60px"),
        ),
      ),
    ),
  ]
}

fn glow_tiles() -> List(Card) {
  let g = xeerpe.glow_options
  let glowing = fn(
    title: String,
    code: String,
    o: #(
      Option(xeerpe.GlowType),
      Option(String),
      Option(String),
      Option(String),
    ),
  ) {
    on_dusk(
      "glow",
      title,
      code,
      box_bg()
        |> xeerpe.glow(xeerpe.GlowOptions(
          color: Some(colors.magenta),
          amount: Some("24px"),
          type_: o.0,
          spread: o.1,
          x: o.2,
          y: o.3,
        )),
    )
  }
  [
    glowing("Outer", "type_: Some(Outer)", #(
      Some(xeerpe.Outer),
      None,
      None,
      None,
    )),
    glowing("Inner", "type_: Some(Inner)", #(
      Some(xeerpe.Inner),
      Some("2px"),
      None,
      None,
    )),
    glowing("spread", "spread: Some(\"8px\")", #(None, Some("8px"), None, None)),
    glowing("x / y", "x: Some(\"14px\"), y: Some(\"14px\")", #(
      None,
      None,
      Some("14px"),
      Some("14px"),
    )),
    on_dusk(
      "glow",
      "color / amount",
      "color: Some(saffron), amount: Some(\"40px\")",
      box_bg()
        |> xeerpe.glow(
          xeerpe.GlowOptions(
            ..g,
            color: Some(colors.saffron),
            amount: Some("40px"),
          ),
        ),
    ),
  ]
}

fn blur_tiles() -> List(Card) {
  let backdrop_base =
    q.linear_colors(
      xeerpe.new(),
      [colors.coral, colors.saffron, colors.cerulean, colors.iris],
      deg: 120.0,
    )
  let glass = q.linear(xeerpe.new(), "#ffffff59", "#ffffff14", deg: 135.0)
  [
    on(
      "blur",
      "BackdropBlur",
      "type_: Some(BackdropBlur)",
      backdrop_base,
      glass
        |> xeerpe.blur(xeerpe.BlurOptions(
          Some("8px"),
          Some(xeerpe.BackdropBlur),
        )),
    ),
    on(
      "blur",
      "PlainBlur",
      "type_: Some(PlainBlur)",
      dusk(),
      box_bg()
        |> xeerpe.blur(xeerpe.BlurOptions(Some("4px"), Some(xeerpe.PlainBlur))),
    ),
    on(
      "blur",
      "filter(Blur, ..)",
      "filter(Blur, BlurOptions(amount: Some(\"8px\")))",
      backdrop_base,
      glass |> xeerpe.filter(xeerpe.Blur, xeerpe.BlurOptions(Some("8px"), None)),
    ),
  ]
}

fn dots_tiles() -> List(Card) {
  let d = xeerpe.dots_options
  let dd = fn(o) { dusk() |> xeerpe.dots(o) }
  let base =
    xeerpe.DotsOptions(
      ..d,
      color: Some("#ffffff"),
      size: Some("16px"),
      spacing: Some("22px"),
      opacity: Some(0.5),
    )
  [
    fill(
      "dots",
      "size",
      "size: Some(\"24px\")",
      dd(xeerpe.DotsOptions(..base, size: Some("24px"))),
    ),
    fill(
      "dots",
      "spacing",
      "spacing: Some(\"14px\")",
      dd(xeerpe.DotsOptions(..base, spacing: Some("14px"))),
    ),
    fill(
      "dots",
      "color / opacity",
      "color: Some(saffron), opacity: Some(0.9)",
      dd(
        xeerpe.DotsOptions(
          ..base,
          color: Some(colors.saffron),
          opacity: Some(0.9),
        ),
      ),
    ),
    fill(
      "dots",
      "background",
      "background: Some(\"#4a0066\")",
      dd(xeerpe.DotsOptions(..base, background: Some("#4a0066"))),
    ),
    fill(
      "dots",
      "background_size",
      "background_size: Some(\"44px 44px\")",
      dd(xeerpe.DotsOptions(..base, background_size: Some("44px 44px"))),
    ),
  ]
}

fn stars_tiles() -> List(Card) {
  let st = xeerpe.stars_options
  let on_night = fn(o) { night() |> xeerpe.stars(o) }
  [
    fill("stars", "defaults", "stars_options", on_night(st)),
    fill(
      "stars",
      "count",
      "count: Some(60)",
      on_night(xeerpe.StarsOptions(..st, count: Some(60))),
    ),
    fill(
      "stars",
      "size (tile)",
      "size: Some(\"80px\")",
      on_night(xeerpe.StarsOptions(..st, size: Some("80px"))),
    ),
    fill(
      "stars",
      "stroke_width",
      "stroke_width: Some(\"3px\")",
      on_night(xeerpe.StarsOptions(..st, stroke_width: Some("3px"))),
    ),
    fill(
      "stars",
      "seed",
      "seed: Some(9)",
      on_night(xeerpe.StarsOptions(..st, seed: Some(9))),
    ),
    fill(
      "stars",
      "color / opacity",
      "color: Some(saffron), opacity: Some(0.6)",
      on_night(
        xeerpe.StarsOptions(
          ..st,
          color: Some(colors.saffron),
          opacity: Some(0.6),
        ),
      ),
    ),
    fill(
      "stars",
      "two layers",
      "stars(small, seed: 4) |> stars(big gold, seed: 9)",
      night()
        |> xeerpe.stars(
          xeerpe.StarsOptions(
            ..st,
            size: Some("160px"),
            count: Some(30),
            stroke_width: Some("1px"),
            seed: Some(4),
          ),
        )
        |> xeerpe.stars(
          xeerpe.StarsOptions(
            ..st,
            color: Some("#ffe8b0"),
            size: Some("310px"),
            count: Some(8),
            stroke_width: Some("2px"),
            seed: Some(9),
          ),
        ),
    ),
  ]
}

fn rays_tiles() -> List(Card) {
  let r = xeerpe.rays_options
  let sun =
    xeerpe.new()
    |> xeerpe.radial_gradient(
      xeerpe.RadialGradientOptions(
        ..rg,
        from: Some("#fde68a"),
        to: Some("#f97316"),
      ),
    )
  let on_sun = fn(o) { sun |> xeerpe.rays(o) }
  let base =
    xeerpe.RaysOptions(..r, color: Some("#ffffff"), opacity: Some(0.25))
  [
    fill("rays", "defaults", "rays_options", on_sun(r)),
    fill(
      "rays",
      "count",
      "count: Some(24)",
      on_sun(xeerpe.RaysOptions(..base, count: Some(24))),
    ),
    fill(
      "rays",
      "position",
      "position: Some(\"50% 115%\")",
      on_sun(xeerpe.RaysOptions(..base, position: Some("50% 115%"))),
    ),
    fill(
      "rays",
      "angle",
      "angle: Some(Deg(15.0))",
      on_sun(xeerpe.RaysOptions(..base, angle: Some(xeerpe.Deg(15.0)))),
    ),
    fill(
      "rays",
      "color / opacity",
      "color: Some(crimson), opacity: Some(0.5)",
      on_sun(
        xeerpe.RaysOptions(
          ..base,
          color: Some(colors.crimson),
          opacity: Some(0.5),
        ),
      ),
    ),
    fill(
      "rays",
      "background",
      "background: Some(\"#15130e\")",
      xeerpe.new()
        |> xeerpe.rays(
          xeerpe.RaysOptions(
            ..base,
            color: Some("#e6c35c"),
            background: Some("#15130e"),
          ),
        ),
    ),
  ]
}

fn grid_tiles() -> List(Card) {
  let g = xeerpe.grid_options
  let gg = fn(o) { dusk() |> xeerpe.grid(o) }
  let base =
    xeerpe.GridOptions(
      ..g,
      color: Some("#ffffff"),
      size: Some("24px"),
      opacity: Some(0.3),
    )
  [
    fill(
      "grid",
      "size",
      "size: Some(\"36px\")",
      gg(xeerpe.GridOptions(..base, size: Some("36px"))),
    ),
    fill(
      "grid",
      "stroke_width",
      "stroke_width: Some(\"3px\")",
      gg(xeerpe.GridOptions(..base, stroke_width: Some("3px"))),
    ),
    fill(
      "grid",
      "color / opacity",
      "color: Some(coral), opacity: Some(0.7)",
      gg(
        xeerpe.GridOptions(
          ..base,
          color: Some(colors.coral),
          opacity: Some(0.7),
        ),
      ),
    ),
    fill(
      "grid",
      "background",
      "background: Some(\"#4a0066\")",
      gg(xeerpe.GridOptions(..base, background: Some("#4a0066"))),
    ),
    fill(
      "grid",
      "background_size",
      "background_size: Some(\"56px 56px\")",
      gg(xeerpe.GridOptions(..base, background_size: Some("56px 56px"))),
    ),
  ]
}

fn animation_option_tiles() -> List(Card) {
  let a0 = xeerpe.animation_options
  // `rotate` only goes one way, so easing and count show. `direction` has nothing to
  // show: xeerpe 0.0.19 applies it to pulse/aurora only, and their keyframes are symmetric.
  let hand = q.conic(xeerpe.new(), colors.coral, colors.iris)
  let spinning = fn(title: String, code: String, o: xeerpe.AnimationOptions) {
    on_dusk(
      "animation",
      title,
      code,
      xeerpe.rotate(
        hand,
        xeerpe.AnimationOptions(
          ..o,
          duration: option.or(o.duration, Some("3s")),
        ),
      ),
    )
  }
  [
    spinning("duration", "duration: Some(\"3s\")", a0),
    spinning(
      "easing · steps",
      "easing: Some(\"steps(8)\")",
      xeerpe.AnimationOptions(..a0, easing: Some("steps(8)")),
    ),
    spinning(
      "easing · cubic-bezier",
      "easing: Some(\"cubic-bezier(.7,0,.3,1)\")",
      xeerpe.AnimationOptions(..a0, easing: Some("cubic-bezier(.7,0,.3,1)")),
    ),
    spinning(
      "iteration_count",
      "duration: Some(\"1.5s\"), iteration_count: Some(Count(2))",
      xeerpe.AnimationOptions(
        ..a0,
        duration: Some("1.5s"),
        iteration_count: Some(xeerpe.Count(2)),
      ),
    ),
  ]
}

fn generic_tiles() -> List(Card) {
  let one = xeerpe.animation_options
  [
    fill(
      "generic",
      "gradient",
      "gradient(Linear, LinearGradient(options))",
      xeerpe.new()
        |> xeerpe.gradient(xeerpe.Linear, xeerpe.LinearGradient(ab())),
    ),
    fill(
      "generic",
      "effect",
      "effect(Vignette, VignetteEffect(options))",
      sky()
        |> xeerpe.effect(
          xeerpe.Vignette,
          xeerpe.VignetteEffect(
            xeerpe.VignetteOptions(
              ..xeerpe.vignette_options,
              intensity: Some(0.7),
            ),
          ),
        ),
    ),
    fill(
      "generic",
      "filter",
      "filter(Blur, BlurOptions(..))",
      dusk() |> xeerpe.filter(xeerpe.Blur, xeerpe.blur_options),
    ),
    fill(
      "generic",
      "pattern",
      "pattern(Grid, GridPattern(options))",
      dusk()
        |> xeerpe.pattern(
          xeerpe.Grid,
          xeerpe.GridPattern(
            xeerpe.GridOptions(
              ..xeerpe.grid_options,
              color: Some("#ffffff"),
              opacity: Some(0.3),
            ),
          ),
        ),
    ),
    fill(
      "generic",
      "animation",
      "animation(Pulse, options)",
      sky()
        |> xeerpe.animation(
          xeerpe.Pulse,
          xeerpe.AnimationOptions(..one, duration: Some("1.5s")),
        ),
    ),
  ]
}

fn text_tiles() -> List(Card) {
  let text = fn(title, code, b) { Card("text", title, code, Text(b, "xeerpe")) }
  [
    text(
      "linear",
      "to_text_style(linear)",
      q.linear(xeerpe.new(), colors.sakura, colors.saffron, deg: 90.0),
    ),
    text(
      "multi-stop",
      "to_text_style(linear_colors)",
      q.linear_colors(
        xeerpe.new(),
        [colors.cerulean, colors.malachite, colors.saffron, colors.coral],
        deg: 90.0,
      ),
    ),
    text(
      "conic",
      "to_text_style(conic)",
      q.conic(xeerpe.new(), colors.coral, colors.iris),
    ),
  ]
}

fn color_tiles() -> List(Card) {
  swatches.all
  |> list.map(fn(c) {
    Card("colors", c.0, "colors." <> c.0 <> "  " <> c.1, Swatch(c.1))
  })
}
