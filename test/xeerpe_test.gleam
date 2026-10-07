import gleam/dict
import gleam/dynamic.{type Dynamic}
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import gleeunit
import lustre/attribute
import lustre/element
import lustre/element/html
import xeerpe.{
  type Builder, AnimationOptions, BackdropBlur, BlurOptions, Calc, Color, Count,
  DotsOptions, GlowOptions, GrainOptions, GridOptions, Infinite, Inner,
  LinearGradientOptions, NoiseOptions, Percent, PositionedColor,
  RadialGradientOptions, RaysOptions, StarsOptions, ToTopRight, Turbulence, Unit,
  VignetteOptions,
}
import xeerpe/css
import xeerpe/quick

pub fn main() {
  gleeunit.main()
}

@external(javascript, "./reference.mjs", "reference")
fn reference(name: String) -> List(#(String, String))

fn same(name: String, b: Builder) {
  assert xeerpe.to_style(b) == dict.from_list(reference(name))
}

const lg = xeerpe.linear_gradient_options

const rg = xeerpe.radial_gradient_options

pub fn linear_test() {
  xeerpe.new()
  |> xeerpe.linear_gradient(
    LinearGradientOptions(
      ..lg,
      from: Some("#111"),
      to: Some("#222"),
      angle: Some(xeerpe.Deg(170.0)),
    ),
  )
  |> same("linear", _)
}

pub fn linear_colors_test() {
  xeerpe.new()
  |> xeerpe.linear_gradient(
    LinearGradientOptions(
      ..lg,
      colors: Some([
        Color("#f00"),
        PositionedColor("#0f0", Some(Unit(Percent(50.0)))),
        PositionedColor("#00f", Some(Calc("100% - 4px"))),
      ]),
      direction: Some(ToTopRight),
      size: Some("50% 50%"),
    ),
  )
  |> same("linear_colors", _)
}

pub fn radial_test() {
  xeerpe.new()
  |> xeerpe.radial_gradient(
    RadialGradientOptions(
      ..rg,
      from: Some("#fff"),
      to: Some("#000"),
      shape: Some(xeerpe.NullShape),
      size: Some(xeerpe.ClosestSide),
      position: Some("10% 20%"),
      color_from_position: Some("0px"),
      color_to_position: Some("60%"),
    ),
  )
  |> same("radial", _)
}

pub fn conic_test() {
  xeerpe.new()
  |> xeerpe.conic_gradient(
    xeerpe.ConicGradientOptions(
      ..xeerpe.conic_gradient_options,
      colors: Some([Color("#f00"), Color("#00f")]),
      angle: Some("0.5turn"),
      position: Some("center"),
    ),
  )
  |> same("conic", _)
}

pub fn mesh_test() {
  xeerpe.new()
  |> xeerpe.mesh_gradient(
    xeerpe.mesh_gradient_options("#050914", [
      RadialGradientOptions(
        ..rg,
        position: Some("15% 15%"),
        from: Some("#0f0"),
        to: Some("transparent"),
      ),
      RadialGradientOptions(
        ..rg,
        from: Some("#00f"),
        to: Some("transparent"),
        shape: Some(xeerpe.Ellipse),
      ),
    ]),
  )
  |> same("mesh", _)
}

pub fn effects_test() {
  xeerpe.new()
  |> xeerpe.noise(NoiseOptions(
    Some(0.2),
    Some(2.0),
    Some(Turbulence),
    Some(4),
    None,
  ))
  |> xeerpe.vignette(VignetteOptions(Some("#000"), Some(0.3), Some(2.0), None))
  |> xeerpe.grain(GrainOptions(Some(3.0), Some("2px"), Some(True), None))
  |> xeerpe.glow(GlowOptions(
    Some("10px"),
    Some("2px"),
    Some("1px"),
    Some("2px"),
    Some("#f0f"),
    Some(Inner),
  ))
  |> same("effects", _)
}

pub fn blur_test() {
  xeerpe.new()
  |> xeerpe.blur(BlurOptions(Some("8px"), Some(BackdropBlur)))
  |> xeerpe.filter(xeerpe.Blur, BlurOptions(Some("2px"), None))
  |> same("blur", _)
}

pub fn patterns_test() {
  xeerpe.new()
  |> xeerpe.dots(
    DotsOptions(
      ..xeerpe.dots_options,
      color: Some("#fff"),
      size: Some("2px"),
      spacing: Some("20px"),
      opacity: Some(0.5),
    ),
  )
  |> xeerpe.grid(
    GridOptions(
      ..xeerpe.grid_options,
      color: Some("#999"),
      size: Some("10px"),
      stroke_width: Some("2px"),
    ),
  )
  |> xeerpe.pattern(
    xeerpe.Dots,
    xeerpe.DotsPattern(
      DotsOptions(..xeerpe.dots_options, background: Some("#000")),
    ),
  )
  |> same("patterns", _)
}

pub fn animations_test() {
  let a = xeerpe.animation_options
  xeerpe.new()
  |> xeerpe.pulse(AnimationOptions(..a, duration: Some("1s")))
  |> xeerpe.rotate(
    AnimationOptions(
      ..a,
      easing: Some("linear"),
      direction: Some(xeerpe.AlternateReverse),
    ),
  )
  |> xeerpe.breathe(AnimationOptions(..a, iteration_count: Some(Count(3))))
  |> xeerpe.aurora(AnimationOptions(..a, iteration_count: Some(Infinite)))
  |> xeerpe.animation(xeerpe.Pulse, a)
  |> same("animations", _)
}

pub fn generic_test() {
  xeerpe.new()
  |> xeerpe.gradient(
    xeerpe.Linear,
    xeerpe.LinearGradient(
      LinearGradientOptions(..lg, from: Some("#aa0000"), to: Some("#0000bb")),
    ),
  )
  |> xeerpe.effect(
    xeerpe.Grain,
    xeerpe.GrainEffect(GrainOptions(Some(1.0), None, None, None)),
  )
  |> same("generic", _)
}

pub fn text_style_test() {
  let b =
    xeerpe.new()
    |> xeerpe.linear_gradient(
      LinearGradientOptions(..lg, from: Some("#111"), to: Some("#222")),
    )
  assert xeerpe.to_text_style(b) == dict.from_list(reference("text"))
}

pub fn preset_test() {
  let assert Ok(p) = xeerpe.preset("northern-lights")
  p
  |> xeerpe.vignette(
    VignetteOptions(..xeerpe.vignette_options, intensity: Some(0.5)),
  )
  |> same("preset", _)
  assert xeerpe.preset("nope") == Error("nope")
}

pub fn immutable_test() {
  let base =
    xeerpe.new()
    |> xeerpe.linear_gradient(
      LinearGradientOptions(..lg, from: Some("#111111"), to: Some("#222222")),
    )
  let _ = xeerpe.pulse(base, xeerpe.animation_options)
  assert dict.has_key(xeerpe.to_style(base), "animation") == False
}

pub fn lustre_kebab_test() {
  let el =
    html.div(
      [
        style(
          xeerpe.new()
          |> xeerpe.breathe(
            AnimationOptions(..xeerpe.animation_options, duration: Some("2s")),
          ),
        ),
      ],
      [],
    )
  let html = element.to_string(el)
  assert string.contains(
    html,
    "animation:xeerpe-breathe 2s ease-in-out infinite",
  )
  assert string.contains(html, "background-position:center")
}

pub fn any_order_and_repeats_test() {
  let g = fn(i) { GrainOptions(..xeerpe.grain_options, intensity: Some(i)) }
  xeerpe.new()
  |> xeerpe.aurora(
    AnimationOptions(..xeerpe.animation_options, duration: Some("3s")),
  )
  |> xeerpe.grain(g(1.0))
  |> xeerpe.linear_gradient(
    LinearGradientOptions(..lg, from: Some("#aa0000"), to: Some("#0000bb")),
  )
  |> xeerpe.vignette(
    VignetteOptions(..xeerpe.vignette_options, intensity: Some(0.2)),
  )
  |> xeerpe.radial_gradient(
    RadialGradientOptions(..rg, from: Some("#00aa00"), to: Some("#cc00cc")),
  )
  |> xeerpe.grain(g(5.0))
  |> xeerpe.dots(DotsOptions(..xeerpe.dots_options, color: Some("#fff")))
  |> xeerpe.blur(BlurOptions(Some("2px"), None))
  |> same("shuffled", _)
}

pub fn pipeline_is_comparable_data_test() {
  let make = fn() {
    xeerpe.new()
    |> xeerpe.linear_gradient(
      LinearGradientOptions(..lg, from: Some("#111111"), to: Some("#222222")),
    )
    |> xeerpe.pulse(xeerpe.animation_options)
  }
  assert make() == make()
  assert make() != xeerpe.new()
  assert xeerpe.layers(make())
    == [
      xeerpe.LinearGradientCall(
        LinearGradientOptions(..lg, from: Some("#111111"), to: Some("#222222")),
      ),
      xeerpe.PulseCall(xeerpe.animation_options),
    ]
}

pub fn sunrise_preset_test() {
  let assert Ok(p) = xeerpe.preset("sunrise")
  same("sunrise", p)
}

pub fn quick_equals_core_test() {
  let core =
    xeerpe.new()
    |> xeerpe.linear_gradient(
      LinearGradientOptions(
        ..lg,
        from: Some("#111111"),
        to: Some("#222222"),
        angle: Some(xeerpe.Deg(170.0)),
      ),
    )
    |> xeerpe.vignette(
      VignetteOptions(
        ..xeerpe.vignette_options,
        intensity: Some(0.3),
        color: Some("#000"),
      ),
    )
    |> xeerpe.breathe(
      AnimationOptions(..xeerpe.animation_options, duration: Some("6s")),
    )
  let short =
    xeerpe.new()
    |> quick.linear("#111111", "#222222", deg: 170.0)
    |> quick.vignette(0.3, "#000")
    |> quick.breathe("6s")
  assert short == core
}

@external(javascript, "./reference.mjs", "npm_module")
fn npm_module() -> Dynamic

@external(javascript, "./reference.mjs", "fake_module")
fn fake_module() -> Dynamic

@external(javascript, "./reference.mjs", "bad_module")
fn bad_module() -> Dynamic

pub fn use_module_test() {
  let b =
    xeerpe.new() |> xeerpe.grain(GrainOptions(Some(3.0), None, None, None))
  let bundled = xeerpe.to_style(b)

  // the npm package gives the same output
  assert xeerpe.use_module(npm_module()) == Ok(Nil)
  assert xeerpe.to_style(b) == bundled

  // and the swap really takes effect
  assert xeerpe.use_module(fake_module()) == Ok(Nil)
  assert xeerpe.to_style(b) == dict.from_list([#("marker", "override")])

  // a module without Preset is rejected and changes nothing
  assert xeerpe.use_module(bad_module()) != Ok(Nil)
  assert xeerpe.to_style(b) == dict.from_list([#("marker", "override")])

  xeerpe.use_bundled()
  assert xeerpe.to_style(b) == bundled
}

pub fn new_animations_test() {
  let a = xeerpe.animation_options
  let d = fn(x) { AnimationOptions(..a, duration: Some(x)) }
  xeerpe.new()
  |> xeerpe.shimmer(d("1s"))
  |> xeerpe.liquid(AnimationOptions(..a, easing: Some("linear")))
  |> xeerpe.plasma(AnimationOptions(..a, iteration_count: Some(Count(2))))
  |> xeerpe.float(AnimationOptions(..a, direction: Some(xeerpe.Reverse)))
  |> xeerpe.drift(d("5s"))
  |> xeerpe.animation(xeerpe.Shimmer, d("2s"))
  |> same("animations2", _)
}

pub fn hex8_colors_test() {
  xeerpe.new()
  |> xeerpe.dots(DotsOptions(..xeerpe.dots_options, color: Some("#ffffff80")))
  |> xeerpe.grid(GridOptions(..xeerpe.grid_options, color: Some("#ff000040")))
  |> xeerpe.vignette(
    VignetteOptions(..xeerpe.vignette_options, color: Some("#ffffff80")),
  )
  |> same("hex8", _)
}

// -- every field and variant, against xeerpe --

const sa = Some("#FFB347")

const sb = Some("#4A1942")

fn lin(o: xeerpe.LinearGradientOptions) {
  fn(b) { xeerpe.linear_gradient(b, o) }
}

fn all(b: Builder, steps: List(fn(Builder) -> Builder)) -> Builder {
  list.fold(steps, b, fn(acc, step) { step(acc) })
}

pub fn every_linear_variant_test() {
  let dirs = [
    xeerpe.ToTop, xeerpe.ToBottom, xeerpe.ToLeft, xeerpe.ToRight,
    xeerpe.ToTopRight, xeerpe.ToBottomRight, xeerpe.ToTopLeft,
    xeerpe.ToBottomLeft,
  ]
  let angles = [
    xeerpe.Deg(135.0),
    xeerpe.Rad(2.4),
    xeerpe.Grad(150.0),
    xeerpe.Turn(0.4),
  ]
  let positions = [
    Unit(Percent(50.0)),
    Unit(xeerpe.Px(120.0)),
    Unit(xeerpe.Rem(8.0)),
    Unit(xeerpe.Em(8.0)),
    Unit(xeerpe.Vh(15.0)),
    Unit(xeerpe.Vw(10.0)),
    Unit(xeerpe.Vmin(12.0)),
    Unit(xeerpe.Vmax(8.0)),
    Calc("50% + 20px"),
  ]
  xeerpe.new()
  |> all(
    list.map(dirs, fn(d) {
      lin(LinearGradientOptions(..lg, from: sa, to: sb, direction: Some(d)))
    }),
  )
  |> all(
    list.map(angles, fn(a) {
      lin(LinearGradientOptions(..lg, from: sa, to: sb, angle: Some(a)))
    }),
  )
  |> all(
    list.map(positions, fn(p) {
      lin(
        LinearGradientOptions(
          ..lg,
          colors: Some([
            Color("#ff0000"),
            PositionedColor("#00ff00", Some(p)),
            Color("#0000ff"),
          ]),
        ),
      )
    }),
  )
  |> xeerpe.linear_gradient(
    LinearGradientOptions(
      ..lg,
      from: sa,
      to: sb,
      size: Some("60%"),
      background_size: Some("200% 100%"),
    ),
  )
  |> same("ks_linear", _)
}

pub fn every_radial_variant_test() {
  let shapes = [xeerpe.Circle, xeerpe.Ellipse, xeerpe.NullShape]
  let sizes = [
    xeerpe.ClosestSide,
    xeerpe.ClosestCorner,
    xeerpe.FarthestSide,
    xeerpe.FarthestCorner,
    xeerpe.CustomSize("40px 80px"),
  ]
  xeerpe.new()
  |> all(
    list.map(shapes, fn(s) {
      fn(b) {
        xeerpe.radial_gradient(
          b,
          RadialGradientOptions(..rg, from: sa, to: sb, shape: Some(s)),
        )
      }
    }),
  )
  |> all(
    list.map(sizes, fn(s) {
      fn(b) {
        xeerpe.radial_gradient(
          b,
          RadialGradientOptions(..rg, from: sa, to: sb, size: Some(s)),
        )
      }
    }),
  )
  |> xeerpe.radial_gradient(RadialGradientOptions(
    from: sa,
    to: sb,
    background_size: Some("50% 50%"),
    shape: Some(xeerpe.Ellipse),
    position: Some("20% 30%"),
    size: Some(xeerpe.ClosestSide),
    color_from_position: Some("10%"),
    color_to_position: Some("70%"),
  ))
  |> same("ks_radial", _)
}

pub fn every_conic_and_mesh_field_test() {
  xeerpe.new()
  |> xeerpe.conic_gradient(
    xeerpe.ConicGradientOptions(
      ..xeerpe.conic_gradient_options,
      from: sa,
      to: sb,
    ),
  )
  |> xeerpe.conic_gradient(xeerpe.ConicGradientOptions(
    from: None,
    to: None,
    background_size: Some("50% 50%"),
    colors: Some([
      Color("#ff0000"),
      PositionedColor("#00ff00", Some(Unit(Percent(40.0)))),
      Color("#0000ff"),
    ]),
    angle: Some("90deg"),
    position: Some("20% 30%"),
  ))
  |> same("ks_conic", _)

  xeerpe.new()
  |> xeerpe.mesh_gradient(
    xeerpe.MeshGradientOptions(
      from: sa,
      to: sb,
      background_size: Some("100% 100%"),
      background: "#050914",
      layers: [
        RadialGradientOptions(
          from: Some("#00ff88"),
          to: Some("transparent"),
          background_size: Some("50% 50%"),
          shape: Some(xeerpe.Ellipse),
          position: Some("10% 20%"),
          size: Some(xeerpe.ClosestSide),
          color_from_position: Some("0px"),
          color_to_position: Some("55%"),
        ),
        RadialGradientOptions(
          ..rg,
          from: Some("#8800ff"),
          to: Some("transparent"),
        ),
      ],
    ),
  )
  |> same("ks_mesh", _)
}

pub fn every_effect_field_test() {
  xeerpe.new()
  |> xeerpe.noise(NoiseOptions(
    Some(0.3),
    Some(2.0),
    Some(Turbulence),
    Some(3),
    Some("50% 50%"),
  ))
  |> xeerpe.noise(
    NoiseOptions(..xeerpe.noise_options, type_: Some(xeerpe.FractalNoise)),
  )
  |> xeerpe.vignette(VignetteOptions(
    Some("#112233"),
    Some(0.4),
    Some(1.5),
    Some("100% 100%"),
  ))
  |> xeerpe.grain(GrainOptions(
    Some(2.0),
    Some("3px"),
    Some(True),
    Some("50% 50%"),
  ))
  |> xeerpe.glow(GlowOptions(
    Some("20px"),
    Some("4px"),
    Some("6px"),
    Some("8px"),
    Some("#ff00ff"),
    Some(xeerpe.Outer),
  ))
  |> xeerpe.glow(GlowOptions(..xeerpe.glow_options, type_: Some(Inner)))
  |> same("ks_effects", _)
}

pub fn every_filter_and_pattern_field_test() {
  xeerpe.new()
  |> xeerpe.blur(BlurOptions(Some("6px"), Some(xeerpe.PlainBlur)))
  |> xeerpe.blur(BlurOptions(Some("4px"), Some(BackdropBlur)))
  |> xeerpe.filter(
    xeerpe.Blur,
    BlurOptions(Some("2px"), Some(xeerpe.PlainBlur)),
  )
  |> same("ks_filters", _)

  xeerpe.new()
  |> xeerpe.dots(DotsOptions(
    Some("#ffffff"),
    Some("#000000"),
    Some("12px"),
    Some("30px"),
    Some("ring"),
    Some(0.4),
    Some("2px"),
    Some("40px 40px"),
  ))
  |> xeerpe.grid(GridOptions(
    Some("#ff0000"),
    Some("#000000"),
    Some("16px"),
    Some(0.3),
    Some("3px"),
    Some("40px 40px"),
  ))
  |> xeerpe.stars(StarsOptions(
    Some("#ffe8b0"),
    Some("#000000"),
    Some("160px"),
    Some(0.8),
    Some("2px"),
    Some("40px 40px"),
    Some(30),
    Some(4),
  ))
  |> xeerpe.rays(RaysOptions(
    Some("#e6c35c"),
    Some("#000000"),
    Some("300px"),
    Some(0.12),
    Some("2px"),
    Some("40px 40px"),
    Some(18),
    Some("50% 115%"),
    Some(xeerpe.Deg(270.0)),
  ))
  |> xeerpe.stars(xeerpe.stars_options)
  |> xeerpe.rays(xeerpe.rays_options)
  |> xeerpe.pattern(
    xeerpe.Stars,
    xeerpe.StarsPattern(StarsOptions(..xeerpe.stars_options, seed: Some(9))),
  )
  |> xeerpe.pattern(
    xeerpe.Rays,
    xeerpe.RaysPattern(RaysOptions(..xeerpe.rays_options, count: Some(6))),
  )
  |> xeerpe.pattern(xeerpe.Grid, xeerpe.GridPattern(xeerpe.grid_options))
  |> same("ks_patterns", _)
}

// The stars and rays examples from xeerpe.io/guide/patterns.
pub fn site_patterns_test() {
  let st = xeerpe.stars_options
  xeerpe.new()
  |> xeerpe.linear_gradient(
    LinearGradientOptions(
      ..lg,
      from: Some("#0b1026"),
      to: Some("#2a1f5c"),
      direction: Some(xeerpe.ToBottom),
    ),
  )
  |> xeerpe.stars(
    StarsOptions(
      ..st,
      size: Some("160px"),
      count: Some(30),
      stroke_width: Some("1px"),
      seed: Some(4),
    ),
  )
  |> xeerpe.stars(
    StarsOptions(
      ..st,
      color: Some("#ffe8b0"),
      size: Some("310px"),
      count: Some(8),
      stroke_width: Some("2px"),
      seed: Some(9),
    ),
  )
  |> same("site_stars", _)

  xeerpe.new()
  |> xeerpe.radial_gradient(
    RadialGradientOptions(
      ..rg,
      from: Some("#e6c35c"),
      to: Some("#15130e"),
      position: Some("50% 115%"),
      color_to_position: Some("70%"),
    ),
  )
  |> xeerpe.rays(
    RaysOptions(
      ..xeerpe.rays_options,
      color: Some("#e6c35c"),
      count: Some(18),
      position: Some("50% 115%"),
      angle: Some(xeerpe.Deg(270.0)),
      opacity: Some(0.12),
    ),
  )
  |> xeerpe.vignette(
    VignetteOptions(
      ..xeerpe.vignette_options,
      intensity: Some(0.5),
      spread: Some(0.5),
    ),
  )
  |> same("site_rays", _)
}

@external(javascript, "./reference.mjs", "npm_preset_names")
fn npm_preset_names() -> List(String)

@external(javascript, "./reference.mjs", "npm_preset_categories")
fn npm_preset_categories() -> List(#(String, List(String)))

pub fn preset_names_test() {
  let names = xeerpe.preset_names()
  assert names == npm_preset_names()
  assert list.length(names) > 200
  assert list.contains(names, "gold")
  let assert Ok(_) = xeerpe.preset("gold")

  let categories = xeerpe.preset_categories()
  assert categories == npm_preset_categories()
  assert list.flat_map(categories, fn(c) { c.1 }) == names
}

pub fn every_animation_variant_test() {
  let a = xeerpe.animation_options
  let types = [
    xeerpe.Pulse, xeerpe.Rotate, xeerpe.Breathe, xeerpe.Aurora, xeerpe.Shimmer,
    xeerpe.Liquid, xeerpe.Plasma, xeerpe.Float, xeerpe.Drift,
  ]
  let dirs = [
    xeerpe.Normal,
    xeerpe.Reverse,
    xeerpe.Alternate,
    xeerpe.AlternateReverse,
  ]
  xeerpe.new()
  |> all(
    list.map(types, fn(t) {
      fn(b) {
        xeerpe.animation(b, t, AnimationOptions(..a, duration: Some("2s")))
      }
    }),
  )
  |> all(
    list.map(dirs, fn(d) {
      fn(b) { xeerpe.float(b, AnimationOptions(..a, direction: Some(d))) }
    }),
  )
  |> xeerpe.pulse(AnimationOptions(
    Some("1s"),
    Some("cubic-bezier(.2,.8,.2,1)"),
    Some(xeerpe.Alternate),
    Some(Count(3)),
  ))
  |> xeerpe.drift(AnimationOptions(..a, iteration_count: Some(Infinite)))
  |> same("ks_animations", _)
}

pub fn every_generic_type_test() {
  xeerpe.new()
  |> xeerpe.gradient(
    xeerpe.Linear,
    xeerpe.LinearGradient(LinearGradientOptions(..lg, from: sa, to: sb)),
  )
  |> xeerpe.gradient(
    xeerpe.Radial,
    xeerpe.RadialGradient(RadialGradientOptions(..rg, from: sa, to: sb)),
  )
  |> xeerpe.gradient(
    xeerpe.Conic,
    xeerpe.ConicGradient(
      xeerpe.ConicGradientOptions(
        ..xeerpe.conic_gradient_options,
        from: sa,
        to: sb,
      ),
    ),
  )
  |> xeerpe.gradient(
    xeerpe.Mesh,
    xeerpe.MeshGradient(
      xeerpe.mesh_gradient_options("#000000", [
        RadialGradientOptions(..rg, from: sa, to: sb),
      ]),
    ),
  )
  |> xeerpe.effect(
    xeerpe.Noise,
    xeerpe.NoiseEffect(NoiseOptions(..xeerpe.noise_options, opacity: Some(0.2))),
  )
  |> xeerpe.effect(
    xeerpe.Vignette,
    xeerpe.VignetteEffect(
      VignetteOptions(..xeerpe.vignette_options, intensity: Some(0.3)),
    ),
  )
  |> xeerpe.effect(
    xeerpe.Grain,
    xeerpe.GrainEffect(
      GrainOptions(..xeerpe.grain_options, intensity: Some(1.0)),
    ),
  )
  |> xeerpe.effect(
    xeerpe.Glow,
    xeerpe.GlowEffect(
      GlowOptions(..xeerpe.glow_options, color: Some("#ff00ff")),
    ),
  )
  |> xeerpe.filter(
    xeerpe.Blur,
    BlurOptions(..xeerpe.blur_options, amount: Some("3px")),
  )
  |> xeerpe.pattern(
    xeerpe.Dots,
    xeerpe.DotsPattern(
      DotsOptions(..xeerpe.dots_options, color: Some("#ffffff")),
    ),
  )
  |> xeerpe.pattern(
    xeerpe.Grid,
    xeerpe.GridPattern(
      GridOptions(..xeerpe.grid_options, color: Some("#ffffff")),
    ),
  )
  |> xeerpe.animation(
    xeerpe.Aurora,
    AnimationOptions(..xeerpe.animation_options, duration: Some("3s")),
  )
  |> same("ks_generic", _)
}

pub fn text_style_every_stop_test() {
  let b =
    xeerpe.new()
    |> xeerpe.linear_gradient(
      LinearGradientOptions(
        ..lg,
        colors: Some([Color("#FFB347"), Color("#4A1942"), Color("#00ccff")]),
        angle: Some(xeerpe.Deg(90.0)),
      ),
    )
  assert xeerpe.to_text_style(b) == dict.from_list(reference("ks_text"))
}

// -- the bundled copy and the Gleam files stay in step with npm --

@external(javascript, "./reference.mjs", "bundled_is_npm")
fn bundled_is_npm() -> Bool

@external(javascript, "./reference.mjs", "npm_version")
fn npm_version() -> String

@external(javascript, "./reference.mjs", "vendor_version_file")
fn vendor_version_file() -> String

@external(javascript, "./reference.mjs", "animations_css_is_npm")
fn animations_css_is_npm(css: String) -> Bool

@external(javascript, "./reference.mjs", "colors_in_sync")
fn colors_in_sync() -> Bool

pub fn bundled_copy_is_the_npm_package_test() {
  assert bundled_is_npm()
}

pub fn versions_agree_test() {
  assert xeerpe.bundled_version == npm_version()
  assert string.starts_with(vendor_version_file(), "xeerpe@" <> npm_version())
}

pub fn keyframes_are_the_npm_css_test() {
  assert animations_css_is_npm(css.keyframes)
}

pub fn colors_match_npm_test() {
  assert colors_in_sync()
}

// -- shortcuts, adapter, README --

pub fn quick_matches_core_test() {
  let d = fn(x) {
    AnimationOptions(..xeerpe.animation_options, duration: Some(x))
  }
  let core =
    xeerpe.new()
    |> xeerpe.dots(
      DotsOptions(
        ..xeerpe.dots_options,
        color: Some("#ffffff"),
        size: Some("16px"),
        spacing: Some("20px"),
        opacity: Some(0.4),
      ),
    )
    |> xeerpe.grid(
      GridOptions(
        ..xeerpe.grid_options,
        color: Some("#ffffff"),
        size: Some("24px"),
        opacity: Some(0.2),
      ),
    )
    |> xeerpe.noise(NoiseOptions(..xeerpe.noise_options, opacity: Some(0.3)))
    |> xeerpe.glow(
      GlowOptions(
        ..xeerpe.glow_options,
        color: Some("#ff00ff"),
        amount: Some("20px"),
      ),
    )
    |> xeerpe.blur(BlurOptions(..xeerpe.blur_options, amount: Some("4px")))
    |> xeerpe.blur(BlurOptions(Some("8px"), Some(BackdropBlur)))
    |> xeerpe.pulse(d("1s"))
    |> xeerpe.rotate(d("2s"))
    |> xeerpe.aurora(d("3s"))
    |> xeerpe.shimmer(d("4s"))
    |> xeerpe.liquid(d("5s"))
    |> xeerpe.plasma(d("6s"))
    |> xeerpe.float(d("7s"))
    |> xeerpe.drift(d("8s"))
  let short =
    xeerpe.new()
    |> quick.dots("#ffffff", "16px", "20px", 0.4)
    |> quick.grid("#ffffff", "24px", 0.2)
    |> quick.noise(0.3)
    |> quick.glow("#ff00ff", "20px")
    |> quick.blur("4px")
    |> quick.backdrop_blur("8px")
    |> quick.pulse("1s")
    |> quick.rotate("2s")
    |> quick.aurora("3s")
    |> quick.shimmer("4s")
    |> quick.liquid("5s")
    |> quick.plasma("6s")
    |> quick.float("7s")
    |> quick.drift("8s")
  assert short == core
}

pub fn quick_gradients_match_core_test() {
  let blob = fn(pos, color) {
    RadialGradientOptions(
      ..rg,
      position: Some(pos),
      from: Some(color),
      to: Some("transparent"),
      color_from_position: Some("0px"),
      color_to_position: Some("55%"),
    )
  }
  assert xeerpe.new()
    |> quick.mesh("#050914", [#("10% 20%", "#00ff88"), #("80% 70%", "#8800ff")])
    == {
      xeerpe.new()
      |> xeerpe.mesh_gradient(
        xeerpe.mesh_gradient_options("#050914", [
          blob("10% 20%", "#00ff88"),
          blob("80% 70%", "#8800ff"),
        ]),
      )
    }
  assert xeerpe.new() |> quick.radial("#aa0000", "#0000bb")
    == {
      xeerpe.new()
      |> xeerpe.radial_gradient(
        RadialGradientOptions(..rg, from: Some("#aa0000"), to: Some("#0000bb")),
      )
    }
  assert xeerpe.new() |> quick.conic("#aa0000", "#0000bb")
    == {
      xeerpe.new()
      |> xeerpe.conic_gradient(
        xeerpe.ConicGradientOptions(
          ..xeerpe.conic_gradient_options,
          from: Some("#aa0000"),
          to: Some("#0000bb"),
        ),
      )
    }
  assert xeerpe.new() |> quick.linear_colors(["#aa0000", "#00bb00"], deg: 45.0)
    == {
      xeerpe.new()
      |> xeerpe.linear_gradient(
        LinearGradientOptions(
          ..lg,
          colors: Some([Color("#aa0000"), Color("#00bb00")]),
          angle: Some(xeerpe.Deg(45.0)),
        ),
      )
    }
}

pub fn text_attribute_test() {
  let html =
    html.h1(
      [
        text_style(
          xeerpe.new() |> quick.linear("#FFB347", "#4A1942", deg: 90.0),
        ),
      ],
      [],
    )
    |> element.to_string
  assert string.contains(html, "background-clip:text")
  assert string.contains(html, "-webkit-background-clip:text")
  assert string.contains(html, "-webkit-text-fill-color:transparent")
}

pub fn keyframes_cover_every_animation_test() {
  let text = css.keyframes
  list.each(
    [
      "pulse",
      "rotate",
      "breathe",
      "aurora",
      "shimmer",
      "liquid",
      "plasma",
      "float",
      "drift",
    ],
    fn(name) {
      assert string.contains(text, "@keyframes xeerpe-" <> name)
    },
  )
}

pub fn unknown_preset_is_an_error_test() {
  assert xeerpe.preset("sunrise") |> result.is_ok
  assert xeerpe.preset("northern-lights") |> result.is_ok
  assert xeerpe.preset("nope") == Error("nope")
}

// the README example
fn sky() {
  xeerpe.new()
  |> quick.linear("#FFB347", "#4A1942", deg: 170.0)
  |> quick.vignette(0.3, "#1a0b1f")
  |> quick.grain(3.0)
  |> quick.breathe("6s")
}

pub fn readme_example_test() {
  let html = html.div([style(sky())], []) |> element.to_string
  assert string.contains(
    html,
    "animation:xeerpe-breathe 6s ease-in-out infinite",
  )
  assert string.contains(html, "background-image:radial-gradient")
}

@external(javascript, "./reference.mjs", "readme_versions")
fn readme_versions() -> List(String)

pub fn readme_version_is_current_test() {
  let versions = readme_versions()
  assert versions != []
  assert list.all(versions, fn(v) { v == xeerpe.bundled_version })
}

// -- css (no framework) --

fn style(b: Builder) {
  attribute.styles(css.properties(b))
}

fn text_style(b: Builder) {
  attribute.styles(css.text_properties(b))
}

pub fn css_properties_use_css_names_test() {
  let props =
    xeerpe.new()
    |> quick.linear("#FFB347", "#4A1942", deg: 170.0)
    |> quick.breathe("6s")
    |> css.properties
  assert list.key_find(props, "background-image") |> result.is_ok
  assert list.key_find(props, "background-size") |> result.is_ok
  assert list.key_find(props, "animation")
    == Ok("xeerpe-breathe 6s ease-in-out infinite")
  assert list.all(props, fn(pair) { string.lowercase(pair.0) == pair.0 })
}

pub fn css_inline_is_a_style_attribute_test() {
  let text =
    xeerpe.new() |> quick.linear("#FFB347", "#4A1942", deg: 90.0) |> css.inline
  assert string.starts_with(text, "background-")
  assert string.contains(text, ";")
  assert !string.contains(text, "backgroundImage")
}

pub fn css_text_properties_test() {
  let props =
    xeerpe.new()
    |> quick.linear("#FFB347", "#4A1942", deg: 90.0)
    |> css.text_properties
  assert list.key_find(props, "-webkit-background-clip") == Ok("text")
  assert list.key_find(props, "color") == Ok("transparent")
}

pub fn keyframes_are_added_outside_a_browser_without_error_test() {
  // no document in Node: must be a no-op, not a crash
  assert css.add_keyframes() == Nil
}
