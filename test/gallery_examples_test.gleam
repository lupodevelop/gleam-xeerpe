// The "Examples" cards show Gleam code. This compiles that code as written
// (only `xeerpe.` / `quick.` prefixes dropped by the imports) and checks it
// makes the same CSS as the card's preview.
import gleam/list
import gleam/option.{Some}
import xeerpe.{
  Color, ConicGradientOptions, Deg, DotsOptions, GlowOptions, Inner,
  LinearGradientOptions, RadialGradientOptions, conic_gradient_options,
  dots_options, glow_options, linear_gradient_options, radial_gradient_options,
}
import xeerpe/css
import xeerpe/quick
import xeerpe_dev/gallery.{On, Text}

fn card(title: String) -> gallery.Preview {
  let assert Ok(c) = gallery.cards() |> list.find(fn(c) { c.title == title })
  c.preview
}

fn same_box(title: String, b: xeerpe.Builder) {
  let assert On(_, box) = card(title)
  assert css.properties(box) == css.properties(b)
}

pub fn neon_button_test() {
  xeerpe.new()
  |> quick.linear("#06080f", "#0b1020", deg: 180.0)
  |> quick.glow("#22d3ee", "18px")
  |> xeerpe.glow(
    GlowOptions(
      ..glow_options,
      type_: Some(Inner),
      color: Some("#22d3ee"),
      amount: Some("12px"),
    ),
  )
  |> same_box("Neon button", _)
}

pub fn avatar_ring_test() {
  xeerpe.new()
  |> xeerpe.conic_gradient(
    ConicGradientOptions(
      ..conic_gradient_options,
      colors: Some([
        Color("#5EB847"),
        Color("#CAD328"),
        Color("#22d3ee"),
        Color("#7a5cff"),
        Color("#5EB847"),
      ]),
    ),
  )
  |> quick.rotate("4s")
  |> same_box("Avatar ring", _)
}

pub fn loading_skeleton_test() {
  xeerpe.new()
  |> xeerpe.linear_gradient(
    LinearGradientOptions(
      ..linear_gradient_options,
      colors: Some([Color("#1c2620"), Color("#2f3d34"), Color("#1c2620")]),
      angle: Some(Deg(90.0)),
      background_size: Some("200% 100%"),
    ),
  )
  |> quick.shimmer("1.6s")
  |> same_box("Loading skeleton", _)
}

pub fn spotlight_card_test() {
  xeerpe.new()
  |> xeerpe.radial_gradient(
    RadialGradientOptions(
      ..radial_gradient_options,
      from: Some("rgba(94,184,71,0.35)"),
      to: Some("transparent"),
      position: Some("0% 0%"),
      color_to_position: Some("70%"),
    ),
  )
  |> quick.linear("#0c140e", "#060906", deg: 180.0)
  |> xeerpe.dots(
    DotsOptions(
      ..dots_options,
      color: Some("#5EB847"),
      size: Some("18px"),
      opacity: Some(0.18),
    ),
  )
  |> xeerpe.glow(
    GlowOptions(
      ..glow_options,
      type_: Some(Inner),
      color: Some("rgba(94,184,71,0.35)"),
      amount: Some("30px"),
    ),
  )
  |> same_box("Spotlight card", _)
}

pub fn frosted_glass_test() {
  xeerpe.new()
  |> quick.linear(
    "rgba(255,255,255,0.22)",
    "rgba(255,255,255,0.06)",
    deg: 180.0,
  )
  |> quick.backdrop_blur("14px")
  |> same_box("Frosted glass", _)
}

pub fn gradient_text_test() {
  let assert Text(b, _) = card("Gradient text")
  let shown =
    xeerpe.new()
    |> quick.linear_colors(["#5EB847", "#CAD328", "#ffd166"], deg: 90.0)
    |> css.text_properties
  assert shown == css.text_properties(b)
}
