import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import lustre
import lustre/attribute.{type Attribute, class}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import xeerpe
import xeerpe/colors
import xeerpe/css
import xeerpe/quick as q
import xeerpe_dev/gallery.{type Card, Card, Fill, On, Swatch, Text}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

type Tab {
  GalleryTab
  ReferenceTab
}

type Model {
  Model(tab: Tab, random: List(Card))
}

type Msg {
  Shuffle
  Generated(List(Card))
  SetTab(Tab)
}

@external(javascript, "./xeerpe_dev_ffi.mjs", "read_hash")
fn read_hash() -> String

@external(javascript, "./xeerpe_dev_ffi.mjs", "write_hash")
fn write_hash(hash: String) -> Nil

/// `#reference` opens the Reference tab.
fn init(_) -> #(Model, Effect(Msg)) {
  let tab = case read_hash() {
    "#reference" -> ReferenceTab
    _ -> GalleryTab
  }
  #(Model(tab, []), generate())
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    Shuffle -> #(Model(..model, random: []), generate())
    Generated(cards) -> #(Model(..model, random: cards), effect.none())
    SetTab(tab) -> #(
      Model(..model, tab: tab),
      effect.from(fn(_) {
        write_hash(case tab {
          ReferenceTab -> "#reference"
          GalleryTab -> ""
        })
      }),
    )
  }
}

// -- random chains --

type Step =
  #(String, fn(xeerpe.Builder) -> xeerpe.Builder)

fn generate() -> Effect(Msg) {
  effect.from(fn(dispatch) {
    dispatch(Generated([1, 2, 3, 4, 5, 6] |> list.map(random_card)))
  })
}

fn pick(items: List(a)) -> a {
  let assert Ok(x) = items |> list.shuffle |> list.first
  x
}

const palette = [
  #("coral", colors.coral),
  #("saffron", colors.saffron),
  #("malachite", colors.malachite),
  #("cerulean", colors.cerulean),
  #("iris", colors.iris),
  #("crimson", colors.crimson),
  #("magenta", colors.magenta),
  #("teal", colors.teal),
  #("sakura", colors.sakura),
  #("amethyst", colors.amethyst),
  #("peach", colors.peach),
  #("cobalt", colors.cobalt),
]

fn random_base() -> Step {
  let #(a, ac) = pick(palette)
  let #(b, bc) = pick(palette)
  case int.random(5) {
    0 -> {
      let deg = int.random(360)
      #(
        "quick.linear("
          <> a
          <> ", "
          <> b
          <> ", deg: "
          <> int.to_string(deg)
          <> ".0)",
        fn(x) { q.linear(x, ac, bc, deg: int.to_float(deg)) },
      )
    }
    1 -> {
      let more = list.take(list.shuffle(palette), 3)
      let names = list.map(more, fn(c) { c.0 })
      let hexes = list.map(more, fn(c) { c.1 })
      let deg = int.random(360)
      #(
        "quick.linear_colors(["
          <> string.join(names, ", ")
          <> "], deg: "
          <> int.to_string(deg)
          <> ".0)",
        fn(x) { q.linear_colors(x, hexes, deg: int.to_float(deg)) },
      )
    }
    2 -> #("quick.radial(" <> a <> ", " <> b <> ")", fn(x) {
      q.radial(x, ac, bc)
    })
    3 -> #("quick.conic(" <> a <> ", " <> b <> ")", fn(x) { q.conic(x, ac, bc) })
    _ -> {
      let blobs =
        list.take(list.shuffle(palette), 3)
        |> list.map(fn(c) {
          #(
            int.to_string(int.random(100))
              <> "% "
              <> int.to_string(int.random(100))
              <> "%",
            c,
          )
        })
      let code =
        list.map(blobs, fn(b) { "#(\"" <> b.0 <> "\", " <> b.1.0 <> ")" })
        |> string.join(", ")
      #("quick.mesh(\"#050914\", [" <> code <> "])", fn(x) {
        q.mesh(x, "#050914", list.map(blobs, fn(b) { #(b.0, b.1.1) }))
      })
    }
  }
}

fn random_extras() -> List(Step) {
  let pool: List(Step) = [
    #("quick.noise(0.3)", fn(x) { q.noise(x, 0.3) }),
    #("quick.grain(3.0)", fn(x) { q.grain(x, 3.0) }),
    #("quick.vignette(0.5, \"#000000\")", fn(x) {
      q.vignette(x, 0.5, "#000000")
    }),
    #("quick.dots(\"#ffffff\", \"16px\", \"20px\", 0.4)", fn(x) {
      q.dots(x, "#ffffff", "16px", "20px", 0.4)
    }),
    #("quick.grid(\"#ffffff\", \"24px\", 0.2)", fn(x) {
      q.grid(x, "#ffffff", "24px", 0.2)
    }),
  ]
  let chosen = pool |> list.shuffle |> list.take(int.random(4))
  // breathe/aurora/liquid resize every layer and stretch dots/grid,
  // so a patterned chain only gets the others.
  let patterned =
    list.any(chosen, fn(s) {
      string.contains(s.0, "dots") || string.contains(s.0, "grid")
    })
  let safe: List(Step) = [
    #("quick.pulse(\"1.5s\")", fn(x) { q.pulse(x, "1.5s") }),
    #("quick.plasma(\"6s\")", fn(x) { q.plasma(x, "6s") }),
    #("quick.float(\"2s\")", fn(x) { q.float(x, "2s") }),
    #("quick.drift(\"5s\")", fn(x) { q.drift(x, "5s") }),
  ]
  let resizing: List(Step) = [
    #("quick.breathe(\"3s\")", fn(x) { q.breathe(x, "3s") }),
    #("quick.aurora(\"2.5s\")", fn(x) { q.aurora(x, "2.5s") }),
    #("quick.liquid(\"4s\")", fn(x) { q.liquid(x, "4s") }),
  ]
  let animations = case patterned {
    True -> safe
    False -> list.append(safe, resizing)
  }
  // any order
  case int.random(2) {
    0 -> list.shuffle([pick(animations), ..chosen])
    _ -> chosen
  }
}

fn random_card(n: Int) -> Card {
  let base = random_base()
  let extras = random_extras()
  let steps = [base, ..extras]
  let builder = list.fold(steps, xeerpe.new(), fn(b, step) { step.1(b) })
  let code =
    "xeerpe.new()\n|> " <> string.join(list.map(steps, fn(s) { s.0 }), "\n|> ")
  Card("Random", "#" <> int.to_string(n), code, Fill(builder))
}

// -- hero, styled with xeerpe --

type Fit {
  Cover
  Bare
  Big
}

fn logo(
  src: String,
  alt: String,
  look: xeerpe.Builder,
  fit: Fit,
) -> Element(msg) {
  html.div(
    [
      class(case fit {
        Big -> "lt res"
        _ -> "lt"
      }),
      style(look),
    ],
    [
      html.img([
        attribute.src(src),
        attribute.alt(alt),
        class(case fit {
          Cover | Big -> "cover"
          Bare -> "bare"
        }),
      ]),
    ],
  )
}

fn glow(color: String) -> xeerpe.Builder {
  glow_with(color, "34px")
}

fn glow_with(color: String, amount: String) -> xeerpe.Builder {
  q.glow(xeerpe.new(), color, amount)
}

/// The logo covers the tile, so only the glow is worth drawing.
fn result_tile() -> xeerpe.Builder {
  glow_with(colors.magenta, "56px")
}

fn backdrop() -> xeerpe.Builder {
  q.mesh(xeerpe.new(), "#0a0a12", [
    #("12% 8%", colors.iris),
    #("88% 14%", colors.magenta),
    #("55% 42%", colors.cobalt),
  ])
  |> q.grain(2.0)
}

fn title_gradient() -> xeerpe.Builder {
  q.linear_colors(
    xeerpe.new(),
    [colors.sakura, colors.magenta, colors.coral, colors.saffron],
    deg: 90.0,
  )
}

fn view(model: Model) -> Element(Msg) {
  let sections =
    list.map(gallery.groups, fn(group) {
      html.section([], [
        html.h2([], [html.text(group)]),
        html.div(
          [class("grid")],
          gallery.cards()
            |> list.filter(fn(c) { c.group == group })
            |> list.map(tile(_, False)),
        ),
      ])
    })
  let footer =
    html.footer([], [
      html.text("A Gleam wrapper around "),
      html.a([attribute.href("https://github.com/nicolacentonze/xeerpe")], [
        html.text("xeerpe"),
      ]),
      html.text(
        " by Nicola Centonze. All credit for the effects goes to xeerpe; the pink logo is a parody of its green one. The xeerpe, Lustre and Gleam logos belong to their projects.",
      ),
    ])
  let content = case model.tab {
    GalleryTab ->
      list.append(
        [
          html.section([], [
            html.div([class("bar")], [
              html.h2([], [html.text("Random")]),
              html.button([event.on_click(Shuffle)], [html.text("Shuffle")]),
            ]),
            html.div([class("grid")], list.map(model.random, tile(_, False))),
          ]),
        ],
        sections,
      )
    ReferenceTab -> reference_sections()
  }
  html.div([class("page")], [
    html.style([], css),
    html.div([class("bg"), style(backdrop())], []),
    html.header([class("hero")], [
      html.div([class("eq")], [
        logo("xeerpe.png", "xeerpe", glow(colors.malachite), Cover),
        html.span([class("op")], [html.text("+")]),
        logo("gleam.svg", "Gleam", xeerpe.new(), Bare),
        html.span([class("op")], [html.text("=")]),
        logo("logo.png", "xeerpe for Gleam", result_tile(), Big),
        html.span([class("op heart")], [html.text("♥")]),
        logo("lustre.png", "Lustre", glow(colors.iris), Cover),
      ]),
      html.h1([text_style(title_gradient())], [html.text("xeerpe for Gleam")]),
      html.p([class("sub")], [
        html.text("Made for Lustre, works anywhere on JavaScript"),
      ]),
      html.code([class("install")], [html.text("gleam add xeerpe")]),
      html.nav([], [
        html.a([attribute.href("https://xeerpe.io")], [html.text("xeerpe.io")]),
        html.a([attribute.href("https://github.com/nicolacentonze/xeerpe")], [
          html.text("xeerpe on GitHub"),
        ]),
      ]),
    ]),
    tabs(model.tab),
    ..list.append(content, [footer])
  ])
}

fn tabs(current: Tab) -> Element(Msg) {
  let tab = fn(label, t) {
    html.button(
      [
        class(case t == current {
          True -> "tab on"
          False -> "tab"
        }),
        event.on_click(SetTab(t)),
      ],
      [html.text(label)],
    )
  }
  html.nav([class("tabs")], [
    tab("Gallery", GalleryTab),
    tab("Reference", ReferenceTab),
  ])
}

fn reference_sections() -> List(Element(Msg)) {
  list.map(gallery.reference(), fn(section) {
    html.section([], [
      html.h2([], [html.text(section.0)]),
      html.div([class("grid sm")], list.map(section.1, tile(_, True))),
    ])
  })
}

fn style(b: xeerpe.Builder) -> Attribute(msg) {
  attribute.styles(css.properties(b))
}

fn text_style(b: xeerpe.Builder) -> Attribute(msg) {
  attribute.styles(css.text_properties(b))
}

/// Keeps gradient-only backgrounds from repeating: a repeated copy can show as a
/// 1px line along an edge (a green one under `northern-lights`). Patterns and
/// explicit sizes need to repeat, so they are left alone.
fn no_repeat_gradient(b: xeerpe.Builder) -> Attribute(msg) {
  let style = xeerpe.to_style(b)
  let image = dict.get(style, "backgroundImage") |> result.unwrap("")
  let size = dict.get(style, "backgroundSize") |> result.unwrap("auto")
  let all_auto =
    string.split(size, ",")
    |> list.all(fn(part) { string.trim(part) == "auto" })
  case !string.contains(image, "url(") && all_auto {
    True -> attribute.styles([#("background-repeat", "no-repeat")])
    False -> attribute.none()
  }
}

fn tile(card: Card, small: Bool) -> Element(msg) {
  html.article(
    [
      class(case small {
        True -> "tile sm"
        False -> "tile"
      }),
    ],
    [
      case card.preview {
        Fill(b) -> html.div([class("pv"), style(b), no_repeat_gradient(b)], [])
        On(base, box) ->
          html.div([class("pv"), style(base), no_repeat_gradient(base)], [
            html.div([class("box"), style(box), no_repeat_gradient(box)], []),
          ])
        Text(b, label) ->
          html.div([class("pv text")], [
            html.span([text_style(b)], [html.text(label)]),
          ])
        Swatch(color) ->
          html.div(
            [class("pv"), attribute.styles([#("background", color)])],
            [],
          )
      },
      html.h3([], [html.text(card.title)]),
      html.pre([], [html.code([], [html.text(card.code)])]),
    ],
  )
}

const css = "
  body { margin: 0; overflow-x: hidden; background: #0c0c12; color: #e8e8ee; font-family: system-ui, sans-serif }
  .page { max-width: 1100px; margin: 0 auto; padding: 0 1.25rem 4rem }
  .page { position: relative }
  .bg { position: absolute; inset: 0 -50vw auto -50vw; height: 820px; z-index: -1; opacity: .5; -webkit-mask-image: linear-gradient(#000 35%, transparent); mask-image: linear-gradient(#000 35%, transparent) }
  .hero { padding: 3.5rem 0 1.5rem; color: #fff; text-align: center }
  .eq { display: flex; align-items: center; justify-content: center; flex-wrap: wrap; gap: clamp(.5rem, 2.2vw, 1.6rem); margin-bottom: 2rem }
  .lt { width: clamp(64px, 13vw, 112px); aspect-ratio: 1; border-radius: 26%; display: grid; place-items: center }
  .lt.res { width: clamp(96px, 22vw, 184px) }
  .lt img.cover { width: 100%; height: 100%; border-radius: 26%; object-fit: cover }
  .lt img.bare { width: 100%; height: 100%; filter: drop-shadow(0 0 14px #ff8be9) }
  .op { font-size: clamp(1.4rem, 4vw, 2.4rem); font-weight: 300; opacity: .7 }
  .op.heart { color: #ff5fb8; opacity: 1; font-weight: 400 }
  .sub { margin: .6rem 0 0; opacity: .85 }
  .install { display: inline-block; margin: 1rem 0 .75rem; padding: .35rem .8rem; background: rgba(0,0,0,.35); border-radius: 8px; font-size: .95rem }
  .hero nav { display: flex; gap: 1.25rem; justify-content: center }
  .hero a { color: #fff; opacity: .9 }
  footer { margin-top: 3rem; padding-top: 1.5rem; border-top: 1px solid #23232f; font-size: .85rem; opacity: .65; text-align: center }
  footer a { color: inherit }
  .hero h1 { margin: 0; font-size: clamp(2rem, 6vw, 3.4rem); letter-spacing: -.02em }
  .bar { display: flex; align-items: center; gap: 1rem; margin-top: 2.5rem }
  .bar h2 { margin: 0 }
  button { background: #23232f; color: #e8e8ee; border: 1px solid #34344a; border-radius: 8px; padding: .4rem .9rem; cursor: pointer; font: inherit }
  .bar + .grid { margin-top: 1rem }
  h2 { margin: 2.5rem 0 1rem; font-size: 1.1rem; text-transform: uppercase; letter-spacing: .08em; opacity: .7 }
  .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 1rem }
  .tabs { display: flex; gap: .5rem; justify-content: center; margin: 1.5rem 0 .5rem }
  .tab { padding: .45rem 1.1rem; border-radius: 999px }
  .tab.on { background: #fff; color: #14141c; border-color: #fff; font-weight: 600 }
  .grid.sm { grid-template-columns: repeat(auto-fill, minmax(190px, 1fr)); gap: .75rem }
  .tile.sm { padding: .6rem }
  .tile.sm .pv { height: 96px }
  .tile.sm h3 { font-size: .85rem; margin: .55rem 0 .3rem }
  .tile.sm pre { font-size: .66rem }
  .pv.text { background: #0c0c12 }
  .pv.text span { font-size: 2.2rem; font-weight: 800; letter-spacing: -.02em }
  .tile { background: #14141c; border: 1px solid #23232f; border-radius: 14px; padding: .75rem }
  .pv { height: 170px; border-radius: 10px; overflow: hidden; display: grid; place-items: center }
  .box { width: 80px; height: 80px; border-radius: 16px }
  h3 { margin: .75rem 0 .4rem; font-size: .95rem }
  pre { margin: 0; padding: .5rem .6rem; background: #0c0c12; border-radius: 8px; font-size: .72rem; line-height: 1.4; white-space: pre-wrap; word-break: break-word; color: #b8b8c8 }
"
