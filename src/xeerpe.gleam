//// Gleam binding for [xeerpe](https://xeerpe.io), JavaScript target only.
////
//// Names follow xeerpe, in snake_case. Optional fields are `Option`s, and every
//// options type has a `*_options` default to update:
//// `LinearGradientOptions(..linear_gradient_options, from: Some("#fff"))`.
//// A `Builder` is plain data; xeerpe itself runs in `to_style`.

import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/float
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

// -- models/gradient --

pub type GradientType {
  Linear
  Radial
  Conic
  Mesh
}

pub type LinearGradientDirection {
  ToTop
  ToBottom
  ToLeft
  ToRight
  ToTopRight
  ToBottomRight
  ToTopLeft
  ToBottomLeft
}

/// An angle with its unit.
pub type LinearGradientAngle {
  Deg(Float)
  Rad(Float)
  Grad(Float)
  Turn(Float)
}

/// `circle`, `ellipse`, or no shape keyword at all (`null` in xeerpe).
pub type RadialGradientShape {
  Circle
  Ellipse
  NullShape
}

/// A size keyword, or any CSS size.
pub type RadialGradientSize {
  ClosestSide
  ClosestCorner
  FarthestSide
  FarthestCorner
  CustomSize(String)
}

pub type LinearGradientPositionUnit {
  Percent(Float)
  Px(Float)
  Rem(Float)
  Em(Float)
  Vh(Float)
  Vw(Float)
  Vmin(Float)
  Vmax(Float)
}

/// A length or percentage, or a `calc()` (pass what goes inside the parentheses).
pub type LinearGradientPosition {
  Unit(LinearGradientPositionUnit)
  Calc(String)
}

/// A color, optionally with a stop position.
pub type GradientColorStop {
  Color(String)
  PositionedColor(color: String, position: Option(LinearGradientPosition))
}

pub type LinearGradientOptions {
  LinearGradientOptions(
    from: Option(String),
    to: Option(String),
    background_size: Option(String),
    colors: Option(List(GradientColorStop)),
    angle: Option(LinearGradientAngle),
    direction: Option(LinearGradientDirection),
    size: Option(String),
  )
}

pub const linear_gradient_options = LinearGradientOptions(
  None,
  None,
  None,
  None,
  None,
  None,
  None,
)

pub type RadialGradientOptions {
  RadialGradientOptions(
    from: Option(String),
    to: Option(String),
    background_size: Option(String),
    shape: Option(RadialGradientShape),
    position: Option(String),
    size: Option(RadialGradientSize),
    color_from_position: Option(String),
    color_to_position: Option(String),
  )
}

pub const radial_gradient_options = RadialGradientOptions(
  None,
  None,
  None,
  None,
  None,
  None,
  None,
  None,
)

pub type ConicGradientOptions {
  ConicGradientOptions(
    from: Option(String),
    to: Option(String),
    background_size: Option(String),
    colors: Option(List(GradientColorStop)),
    angle: Option(String),
    position: Option(String),
  )
}

pub const conic_gradient_options = ConicGradientOptions(
  None,
  None,
  None,
  None,
  None,
  None,
)

/// `background` and `layers` are required: build it with `mesh_gradient_options`.
pub type MeshGradientOptions {
  MeshGradientOptions(
    from: Option(String),
    to: Option(String),
    background_size: Option(String),
    background: String,
    layers: List(RadialGradientOptions),
  )
}

pub fn mesh_gradient_options(
  background: String,
  layers: List(RadialGradientOptions),
) -> MeshGradientOptions {
  MeshGradientOptions(None, None, None, background, layers)
}

pub type GradientOptions {
  LinearGradient(LinearGradientOptions)
  RadialGradient(RadialGradientOptions)
  ConicGradient(ConicGradientOptions)
  MeshGradient(MeshGradientOptions)
}

// -- models/effects --

pub type EffectType {
  Noise
  Vignette
  Grain
  Glow
}

pub type NoiseType {
  Turbulence
  FractalNoise
}

pub type GlowType {
  Outer
  Inner
}

pub type NoiseOptions {
  NoiseOptions(
    opacity: Option(Float),
    scale: Option(Float),
    type_: Option(NoiseType),
    octaves: Option(Int),
    background_size: Option(String),
  )
}

pub const noise_options = NoiseOptions(None, None, None, None, None)

pub type VignetteOptions {
  VignetteOptions(
    color: Option(String),
    intensity: Option(Float),
    spread: Option(Float),
    background_size: Option(String),
  )
}

pub const vignette_options = VignetteOptions(None, None, None, None)

pub type GrainOptions {
  GrainOptions(
    intensity: Option(Float),
    size: Option(String),
    animated: Option(Bool),
    background_size: Option(String),
  )
}

pub const grain_options = GrainOptions(None, None, None, None)

pub type GlowOptions {
  GlowOptions(
    amount: Option(String),
    spread: Option(String),
    x: Option(String),
    y: Option(String),
    color: Option(String),
    type_: Option(GlowType),
  )
}

pub const glow_options = GlowOptions(None, None, None, None, None, None)

pub type EffectOptions {
  NoiseEffect(NoiseOptions)
  VignetteEffect(VignetteOptions)
  GrainEffect(GrainOptions)
  GlowEffect(GlowOptions)
}

// -- models/filters --

pub type FilterType {
  Blur
}

/// `backdrop-filter`, or a plain `filter`.
pub type BlurType {
  BackdropBlur
  PlainBlur
}

pub type BlurOptions {
  BlurOptions(amount: Option(String), type_: Option(BlurType))
}

pub const blur_options = BlurOptions(None, None)

pub type FilterOptions =
  BlurOptions

// -- models/pattern --

pub type PatternType {
  Dots
  Grid
  Stars
  Rays
}

/// Includes the fields xeerpe inherits from its base pattern options.
pub type DotsOptions {
  DotsOptions(
    color: Option(String),
    background: Option(String),
    size: Option(String),
    spacing: Option(String),
    style: Option(String),
    opacity: Option(Float),
    stroke_width: Option(String),
    background_size: Option(String),
  )
}

pub const dots_options = DotsOptions(
  None,
  None,
  None,
  None,
  None,
  None,
  None,
  None,
)

pub type GridOptions {
  GridOptions(
    color: Option(String),
    background: Option(String),
    size: Option(String),
    opacity: Option(Float),
    stroke_width: Option(String),
    background_size: Option(String),
  )
}

pub const grid_options = GridOptions(None, None, None, None, None, None)

/// A field of small stars on a repeating tile. The layout is pseudo-random
/// but deterministic: `seed` picks it, `count` is the stars per tile.
pub type StarsOptions {
  StarsOptions(
    color: Option(String),
    background: Option(String),
    size: Option(String),
    opacity: Option(Float),
    stroke_width: Option(String),
    background_size: Option(String),
    count: Option(Int),
    seed: Option(Int),
  )
}

pub const stars_options = StarsOptions(
  None,
  None,
  None,
  None,
  None,
  None,
  None,
  None,
)

/// Rays radiating from `position`, like a sunburst. `angle` rotates them.
pub type RaysOptions {
  RaysOptions(
    color: Option(String),
    background: Option(String),
    size: Option(String),
    opacity: Option(Float),
    stroke_width: Option(String),
    background_size: Option(String),
    count: Option(Int),
    position: Option(String),
    angle: Option(LinearGradientAngle),
  )
}

pub const rays_options = RaysOptions(
  None,
  None,
  None,
  None,
  None,
  None,
  None,
  None,
  None,
)

pub type PatternOptions {
  DotsPattern(DotsOptions)
  GridPattern(GridOptions)
  StarsPattern(StarsOptions)
  RaysPattern(RaysOptions)
}

// -- models/animation --

pub type AnimationType {
  Pulse
  Rotate
  Breathe
  Aurora
  Shimmer
  Liquid
  Plasma
  Float
  Drift
}

pub type AnimationDirection {
  Normal
  Reverse
  Alternate
  AlternateReverse
}

/// A number of iterations, or forever.
pub type IterationCount {
  Count(Int)
  Infinite
}

pub type AnimationOptions {
  AnimationOptions(
    duration: Option(String),
    easing: Option(String),
    direction: Option(AnimationDirection),
    iteration_count: Option(IterationCount),
  )
}

pub const animation_options = AnimationOptions(None, None, None, None)

// -- types xeerpe only declares --

pub type LayerType {
  GradientLayer
  FilterLayer
  EffectLayer
  PatternLayer
  AnimationLayer
}

pub type CssProperties {
  CssProperties(
    background: Option(String),
    background_image: Option(String),
    background_color: Option(String),
    background_size: Option(String),
    filter: Option(String),
    backdrop_filter: Option(String),
    box_shadow: Option(String),
    animation: Option(String),
  )
}

pub type BuilderLayer {
  BuilderLayer(type_: LayerType, properties: CssProperties)
}

pub type RgbColor {
  RgbColor(red: Float, green: Float, blue: Float)
}

pub type RgbaColor {
  RgbaColor(red: Float, green: Float, blue: Float, alpha: Option(Float))
}

pub type CssLength {
  CssLength(value: Float, unit: String)
}

// -- core/builder --

/// One recorded call.
pub type Layer {
  GradientCall(GradientType, GradientOptions)
  LinearGradientCall(LinearGradientOptions)
  RadialGradientCall(RadialGradientOptions)
  ConicGradientCall(ConicGradientOptions)
  MeshGradientCall(MeshGradientOptions)
  EffectCall(EffectType, EffectOptions)
  FilterCall(FilterType, FilterOptions)
  PatternCall(PatternType, PatternOptions)
  AnimationCall(AnimationType, AnimationOptions)
  NoiseCall(NoiseOptions)
  VignetteCall(VignetteOptions)
  GrainCall(GrainOptions)
  GlowCall(GlowOptions)
  BlurCall(BlurOptions)
  DotsCall(DotsOptions)
  GridCall(GridOptions)
  StarsCall(StarsOptions)
  RaysCall(RaysOptions)
  PulseCall(AnimationOptions)
  RotateCall(AnimationOptions)
  BreatheCall(AnimationOptions)
  AuroraCall(AnimationOptions)
  ShimmerCall(AnimationOptions)
  LiquidCall(AnimationOptions)
  PlasmaCall(AnimationOptions)
  FloatCall(AnimationOptions)
  DriftCall(AnimationOptions)
}

/// xeerpe's `Builder`, and `Preset` (a `Builder` that starts from a preset).
/// Plain data: nothing runs until `to_style`, so it can sit in a Lustre model
/// and be compared with `==`.
pub opaque type Builder {
  Builder(base: Option(String), layers: List(Layer))
}

/// xeerpe's `PresetConfig`.
pub type PresetConfig =
  fn(Builder) -> Builder

/// `new Builder()`.
pub fn new() -> Builder {
  Builder(None, [])
}

/// `new Preset(name)`. An unknown name is an `Error` instead of an exception.
/// `preset_names` lists the names; the bundled xeerpe has more than 200.
pub fn preset(name: String) -> Result(Builder, String) {
  case preset_exists(name) {
    True -> Ok(Builder(Some(name), []))
    False -> Error(name)
  }
}

@external(javascript, "./xeerpe_ffi.mjs", "preset_exists")
fn preset_exists(name: String) -> Bool

/// xeerpe's `presetNames`: every preset the xeerpe in use knows, in its order.
@external(javascript, "./xeerpe_ffi.mjs", "preset_names")
pub fn preset_names() -> List(String)

/// xeerpe's `presetCategories`: `#(category, names)` pairs, like
/// `#("metals", ["gold", "silver", ...])`.
@external(javascript, "./xeerpe_ffi.mjs", "preset_categories")
pub fn preset_categories() -> List(#(String, List(String)))

/// The version of the xeerpe copy inside this package. Only a label: the code does
/// not read it, and `scripts/update-xeerpe.sh` keeps it up to date.
pub const bundled_version = "1.0.2"

/// Use another xeerpe instead of the bundled one, for example a newer npm release.
/// Pass the module (it needs `Builder` and `Preset`) once, when the app starts.
/// Only the behaviour changes: the types still describe `bundled_version`.
///
/// ```js
/// // my_xeerpe.mjs, after `npm install xeerpe@<version>`
/// import * as xeerpe from "xeerpe";
/// export const module = () => xeerpe;
/// ```
/// ```gleam
/// @external(javascript, "./my_xeerpe.mjs", "module")
/// fn my_xeerpe() -> Dynamic
///
/// let assert Ok(Nil) = xeerpe.use_module(my_xeerpe())
/// ```
@external(javascript, "./xeerpe_ffi.mjs", "use_module")
pub fn use_module(module: Dynamic) -> Result(Nil, String)

/// Back to the bundled xeerpe.
@external(javascript, "./xeerpe_ffi.mjs", "use_bundled")
pub fn use_bundled() -> Nil

/// The calls recorded so far, in order.
pub fn layers(b: Builder) -> List(Layer) {
  b.layers
}

fn add(b: Builder, layer: Layer) -> Builder {
  Builder(..b, layers: list.append(b.layers, [layer]))
}

pub fn gradient(
  b: Builder,
  type_: GradientType,
  options: GradientOptions,
) -> Builder {
  add(b, GradientCall(type_, options))
}

pub fn linear_gradient(b: Builder, options: LinearGradientOptions) -> Builder {
  add(b, LinearGradientCall(options))
}

pub fn radial_gradient(b: Builder, options: RadialGradientOptions) -> Builder {
  add(b, RadialGradientCall(options))
}

pub fn conic_gradient(b: Builder, options: ConicGradientOptions) -> Builder {
  add(b, ConicGradientCall(options))
}

pub fn mesh_gradient(b: Builder, options: MeshGradientOptions) -> Builder {
  add(b, MeshGradientCall(options))
}

pub fn effect(
  b: Builder,
  type_: EffectType,
  options: EffectOptions,
) -> Builder {
  add(b, EffectCall(type_, options))
}

pub fn filter(
  b: Builder,
  type_: FilterType,
  options: FilterOptions,
) -> Builder {
  add(b, FilterCall(type_, options))
}

pub fn pattern(
  b: Builder,
  type_: PatternType,
  options: PatternOptions,
) -> Builder {
  add(b, PatternCall(type_, options))
}

pub fn animation(
  b: Builder,
  type_: AnimationType,
  options: AnimationOptions,
) -> Builder {
  add(b, AnimationCall(type_, options))
}

pub fn noise(b: Builder, options: NoiseOptions) -> Builder {
  add(b, NoiseCall(options))
}

pub fn vignette(b: Builder, options: VignetteOptions) -> Builder {
  add(b, VignetteCall(options))
}

pub fn grain(b: Builder, options: GrainOptions) -> Builder {
  add(b, GrainCall(options))
}

pub fn glow(b: Builder, options: GlowOptions) -> Builder {
  add(b, GlowCall(options))
}

pub fn blur(b: Builder, options: BlurOptions) -> Builder {
  add(b, BlurCall(options))
}

pub fn dots(b: Builder, options: DotsOptions) -> Builder {
  add(b, DotsCall(options))
}

pub fn grid(b: Builder, options: GridOptions) -> Builder {
  add(b, GridCall(options))
}

pub fn stars(b: Builder, options: StarsOptions) -> Builder {
  add(b, StarsCall(options))
}

pub fn rays(b: Builder, options: RaysOptions) -> Builder {
  add(b, RaysCall(options))
}

pub fn pulse(b: Builder, options: AnimationOptions) -> Builder {
  add(b, PulseCall(options))
}

pub fn rotate(b: Builder, options: AnimationOptions) -> Builder {
  add(b, RotateCall(options))
}

pub fn breathe(b: Builder, options: AnimationOptions) -> Builder {
  add(b, BreatheCall(options))
}

pub fn aurora(b: Builder, options: AnimationOptions) -> Builder {
  add(b, AuroraCall(options))
}

pub fn shimmer(b: Builder, options: AnimationOptions) -> Builder {
  add(b, ShimmerCall(options))
}

pub fn liquid(b: Builder, options: AnimationOptions) -> Builder {
  add(b, LiquidCall(options))
}

pub fn plasma(b: Builder, options: AnimationOptions) -> Builder {
  add(b, PlasmaCall(options))
}

pub fn float(b: Builder, options: AnimationOptions) -> Builder {
  add(b, FloatCall(options))
}

pub fn drift(b: Builder, options: AnimationOptions) -> Builder {
  add(b, DriftCall(options))
}

/// `toStyle()`. Keys stay camelCase, as in xeerpe.
pub fn to_style(b: Builder) -> Dict(String, String) {
  dict.from_list(render(b, False))
}

/// `toTextStyle()`.
pub fn to_text_style(b: Builder) -> Dict(String, String) {
  dict.from_list(render(b, True))
}

/// Replays the layers on a fresh xeerpe `Builder`.
fn render(b: Builder, text: Bool) -> List(#(String, String)) {
  build(option.unwrap(b.base, ""), list.map(b.layers, call), text)
}

fn call(layer: Layer) -> #(String, List(Dynamic)) {
  case layer {
    GradientCall(t, o) -> #("gradient", [
      dynamic.string(gradient_name(t)),
      gradient_options(o),
    ])
    LinearGradientCall(o) -> #("linearGradient", [linear_options(o)])
    RadialGradientCall(o) -> #("radialGradient", [radial_options(o)])
    ConicGradientCall(o) -> #("conicGradient", [conic_options(o)])
    MeshGradientCall(o) -> #("meshGradient", [mesh_options(o)])
    EffectCall(t, o) -> #("effect", [
      dynamic.string(effect_name(t)),
      effect_options(o),
    ])
    FilterCall(Blur, o) -> #("filter", [dynamic.string("blur"), blur_opts(o)])
    PatternCall(t, o) -> #("pattern", [
      dynamic.string(pattern_name(t)),
      pattern_options(o),
    ])
    AnimationCall(t, o) -> #("animation", [
      dynamic.string(animation_name(t)),
      animation_opts(o),
    ])
    NoiseCall(o) -> #("noise", [noise_opts(o)])
    VignetteCall(o) -> #("vignette", [vignette_opts(o)])
    GrainCall(o) -> #("grain", [grain_opts(o)])
    GlowCall(o) -> #("glow", [glow_opts(o)])
    BlurCall(o) -> #("blur", [blur_opts(o)])
    DotsCall(o) -> #("dots", [dots_opts(o)])
    GridCall(o) -> #("grid", [grid_opts(o)])
    StarsCall(o) -> #("stars", [stars_opts(o)])
    RaysCall(o) -> #("rays", [rays_opts(o)])
    PulseCall(o) -> #("pulse", [animation_opts(o)])
    RotateCall(o) -> #("rotate", [animation_opts(o)])
    BreatheCall(o) -> #("breathe", [animation_opts(o)])
    AuroraCall(o) -> #("aurora", [animation_opts(o)])
    ShimmerCall(o) -> #("shimmer", [animation_opts(o)])
    LiquidCall(o) -> #("liquid", [animation_opts(o)])
    PlasmaCall(o) -> #("plasma", [animation_opts(o)])
    FloatCall(o) -> #("float", [animation_opts(o)])
    DriftCall(o) -> #("drift", [animation_opts(o)])
  }
}

fn gradient_name(t: GradientType) -> String {
  case t {
    Linear -> "linear"
    Radial -> "radial"
    Conic -> "conic"
    Mesh -> "mesh"
  }
}

fn effect_name(t: EffectType) -> String {
  case t {
    Noise -> "noise"
    Vignette -> "vignette"
    Grain -> "grain"
    Glow -> "glow"
  }
}

fn pattern_name(t: PatternType) -> String {
  case t {
    Dots -> "dots"
    Grid -> "grid"
    Stars -> "stars"
    Rays -> "rays"
  }
}

@external(javascript, "./xeerpe_ffi.mjs", "build")
fn build(
  base: String,
  steps: List(#(String, List(Dynamic))),
  text: Bool,
) -> List(#(String, String))

// -- encoding to the JS options objects --

@external(javascript, "./xeerpe_ffi.mjs", "object")
fn object(pairs: List(#(String, Dynamic))) -> Dynamic

@external(javascript, "./xeerpe_ffi.mjs", "null_")
fn null() -> Dynamic

/// A JS object from the fields that are `Some`.
fn obj(fields: List(#(String, Option(Dynamic)))) -> Dynamic {
  fields
  |> list.filter_map(fn(f) {
    case f.1 {
      Some(v) -> Ok(#(f.0, v))
      None -> Error(Nil)
    }
  })
  |> object
}

fn str(v: Option(String)) -> Option(Dynamic) {
  option.map(v, dynamic.string)
}

fn flt(v: Option(Float)) -> Option(Dynamic) {
  option.map(v, dynamic.float)
}

fn int(v: Option(Int)) -> Option(Dynamic) {
  option.map(v, dynamic.int)
}

fn req(v: String) -> Option(Dynamic) {
  Some(dynamic.string(v))
}

/// `170.0` becomes `"170"`, the way JS prints a number.
fn len(n: Float, unit: String) -> String {
  let s = float.to_string(n)
  case string.ends_with(s, ".0") {
    True -> string.drop_end(s, 2)
    False -> s
  }
  <> unit
}

fn angle_str(a: LinearGradientAngle) -> String {
  case a {
    Deg(n) -> len(n, "deg")
    Rad(n) -> len(n, "rad")
    Grad(n) -> len(n, "grad")
    Turn(n) -> len(n, "turn")
  }
}

fn direction_str(d: LinearGradientDirection) -> String {
  case d {
    ToTop -> "to top"
    ToBottom -> "to bottom"
    ToLeft -> "to left"
    ToRight -> "to right"
    ToTopRight -> "to top right"
    ToBottomRight -> "to bottom right"
    ToTopLeft -> "to top left"
    ToBottomLeft -> "to bottom left"
  }
}

fn position_str(p: LinearGradientPosition) -> String {
  case p {
    Calc(expr) -> "calc(" <> expr <> ")"
    Unit(Percent(n)) -> len(n, "%")
    Unit(Px(n)) -> len(n, "px")
    Unit(Rem(n)) -> len(n, "rem")
    Unit(Em(n)) -> len(n, "em")
    Unit(Vh(n)) -> len(n, "vh")
    Unit(Vw(n)) -> len(n, "vw")
    Unit(Vmin(n)) -> len(n, "vmin")
    Unit(Vmax(n)) -> len(n, "vmax")
  }
}

fn stop(c: GradientColorStop) -> Dynamic {
  case c {
    Color(color) -> dynamic.string(color)
    PositionedColor(color, position) ->
      obj([
        #("color", req(color)),
        #(
          "position",
          option.map(position, fn(p) { dynamic.string(position_str(p)) }),
        ),
      ])
  }
}

fn stops(v: Option(List(GradientColorStop))) -> Option(Dynamic) {
  option.map(v, fn(l) { dynamic.list(list.map(l, stop)) })
}

fn linear_options(o: LinearGradientOptions) -> Dynamic {
  obj([
    #("from", str(o.from)),
    #("to", str(o.to)),
    #("backgroundSize", str(o.background_size)),
    #("colors", stops(o.colors)),
    #("angle", option.map(o.angle, fn(a) { dynamic.string(angle_str(a)) })),
    #(
      "direction",
      option.map(o.direction, fn(d) { dynamic.string(direction_str(d)) }),
    ),
    #("size", str(o.size)),
  ])
}

fn radial_options(o: RadialGradientOptions) -> Dynamic {
  obj([
    #("from", str(o.from)),
    #("to", str(o.to)),
    #("backgroundSize", str(o.background_size)),
    #(
      "shape",
      option.map(o.shape, fn(s) {
        case s {
          Circle -> dynamic.string("circle")
          Ellipse -> dynamic.string("ellipse")
          NullShape -> null()
        }
      }),
    ),
    #("position", str(o.position)),
    #(
      "size",
      option.map(o.size, fn(s) {
        dynamic.string(case s {
          ClosestSide -> "closest-side"
          ClosestCorner -> "closest-corner"
          FarthestSide -> "farthest-side"
          FarthestCorner -> "farthest-corner"
          CustomSize(v) -> v
        })
      }),
    ),
    #("colorFromPosition", str(o.color_from_position)),
    #("colorToPosition", str(o.color_to_position)),
  ])
}

fn conic_options(o: ConicGradientOptions) -> Dynamic {
  obj([
    #("from", str(o.from)),
    #("to", str(o.to)),
    #("backgroundSize", str(o.background_size)),
    #("colors", stops(o.colors)),
    #("angle", str(o.angle)),
    #("position", str(o.position)),
  ])
}

fn mesh_options(o: MeshGradientOptions) -> Dynamic {
  obj([
    #("from", str(o.from)),
    #("to", str(o.to)),
    #("backgroundSize", str(o.background_size)),
    #("background", req(o.background)),
    #("layers", Some(dynamic.list(list.map(o.layers, radial_options)))),
  ])
}

fn gradient_options(o: GradientOptions) -> Dynamic {
  case o {
    LinearGradient(x) -> linear_options(x)
    RadialGradient(x) -> radial_options(x)
    ConicGradient(x) -> conic_options(x)
    MeshGradient(x) -> mesh_options(x)
  }
}

fn noise_opts(o: NoiseOptions) -> Dynamic {
  obj([
    #("opacity", flt(o.opacity)),
    #("scale", flt(o.scale)),
    #(
      "type",
      option.map(o.type_, fn(t) {
        dynamic.string(case t {
          Turbulence -> "turbulence"
          FractalNoise -> "fractalNoise"
        })
      }),
    ),
    #("octaves", option.map(o.octaves, dynamic.int)),
    #("backgroundSize", str(o.background_size)),
  ])
}

fn vignette_opts(o: VignetteOptions) -> Dynamic {
  obj([
    #("color", str(o.color)),
    #("intensity", flt(o.intensity)),
    #("spread", flt(o.spread)),
    #("backgroundSize", str(o.background_size)),
  ])
}

fn grain_opts(o: GrainOptions) -> Dynamic {
  obj([
    #("intensity", flt(o.intensity)),
    #("size", str(o.size)),
    #("animated", option.map(o.animated, dynamic.bool)),
    #("backgroundSize", str(o.background_size)),
  ])
}

fn glow_opts(o: GlowOptions) -> Dynamic {
  obj([
    #("amount", str(o.amount)),
    #("spread", str(o.spread)),
    #("x", str(o.x)),
    #("y", str(o.y)),
    #("color", str(o.color)),
    #(
      "type",
      option.map(o.type_, fn(t) {
        dynamic.string(case t {
          Outer -> "outer"
          Inner -> "inner"
        })
      }),
    ),
  ])
}

fn effect_options(o: EffectOptions) -> Dynamic {
  case o {
    NoiseEffect(x) -> noise_opts(x)
    VignetteEffect(x) -> vignette_opts(x)
    GrainEffect(x) -> grain_opts(x)
    GlowEffect(x) -> glow_opts(x)
  }
}

fn blur_opts(o: BlurOptions) -> Dynamic {
  obj([
    #("amount", str(o.amount)),
    #(
      "type",
      option.map(o.type_, fn(t) {
        dynamic.string(case t {
          BackdropBlur -> "backdrop"
          PlainBlur -> "blur"
        })
      }),
    ),
  ])
}

fn dots_opts(o: DotsOptions) -> Dynamic {
  obj([
    #("color", str(o.color)),
    #("background", str(o.background)),
    #("size", str(o.size)),
    #("spacing", str(o.spacing)),
    #("style", str(o.style)),
    #("opacity", flt(o.opacity)),
    #("strokeWidth", str(o.stroke_width)),
    #("backgroundSize", str(o.background_size)),
  ])
}

fn grid_opts(o: GridOptions) -> Dynamic {
  obj([
    #("color", str(o.color)),
    #("background", str(o.background)),
    #("size", str(o.size)),
    #("opacity", flt(o.opacity)),
    #("strokeWidth", str(o.stroke_width)),
    #("backgroundSize", str(o.background_size)),
  ])
}

fn stars_opts(o: StarsOptions) -> Dynamic {
  obj([
    #("color", str(o.color)),
    #("background", str(o.background)),
    #("size", str(o.size)),
    #("opacity", flt(o.opacity)),
    #("strokeWidth", str(o.stroke_width)),
    #("backgroundSize", str(o.background_size)),
    #("count", int(o.count)),
    #("seed", int(o.seed)),
  ])
}

fn rays_opts(o: RaysOptions) -> Dynamic {
  obj([
    #("color", str(o.color)),
    #("background", str(o.background)),
    #("size", str(o.size)),
    #("opacity", flt(o.opacity)),
    #("strokeWidth", str(o.stroke_width)),
    #("backgroundSize", str(o.background_size)),
    #("count", int(o.count)),
    #("position", str(o.position)),
    #("angle", option.map(o.angle, fn(a) { dynamic.string(angle_str(a)) })),
  ])
}

fn pattern_options(o: PatternOptions) -> Dynamic {
  case o {
    DotsPattern(x) -> dots_opts(x)
    GridPattern(x) -> grid_opts(x)
    StarsPattern(x) -> stars_opts(x)
    RaysPattern(x) -> rays_opts(x)
  }
}

fn animation_name(t: AnimationType) -> String {
  case t {
    Pulse -> "pulse"
    Rotate -> "rotate"
    Breathe -> "breathe"
    Aurora -> "aurora"
    Shimmer -> "shimmer"
    Liquid -> "liquid"
    Plasma -> "plasma"
    Float -> "float"
    Drift -> "drift"
  }
}

fn animation_opts(o: AnimationOptions) -> Dynamic {
  obj([
    #("duration", str(o.duration)),
    #("easing", str(o.easing)),
    #(
      "direction",
      option.map(o.direction, fn(d) {
        dynamic.string(case d {
          Normal -> "normal"
          Reverse -> "reverse"
          Alternate -> "alternate"
          AlternateReverse -> "alternate-reverse"
        })
      }),
    ),
    #(
      "iterationCount",
      option.map(o.iteration_count, fn(c) {
        case c {
          Count(n) -> dynamic.int(n)
          Infinite -> dynamic.string("infinite")
        }
      }),
    ),
  ])
}
