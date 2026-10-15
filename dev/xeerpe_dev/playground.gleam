//// The Playground tab: stack layers, tweak them, copy the Gleam that draws it.
//// Every layer gives both its code and its builder step from the same values,
//// so the preview is always what the snippet produces.

import gleam/float
import gleam/int
import gleam/list
import gleam/order
import gleam/string
import lustre/attribute.{class}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import xeerpe
import xeerpe/css
import xeerpe/quick as q

pub type Kind {
  Linear
  Radial
  Conic
  Noise
  Vignette
  Grain
  Glow
  Blur
  Dots
  Grid
  Stars
  Rays
  Animation
}

type Input {
  ColorIn
  Range(min: Float, max: Float, step: Float)
  TextIn
  Choice(List(String))
}

type Field {
  Field(label: String, input: Input, value: String)
}

type Layer {
  Layer(kind: Kind, fields: List(Field))
}

pub opaque type Model {
  // selected: the open layer, -1 for none
  Model(
    preset: String,
    layers: List(Layer),
    selected: Int,
    copied: Bool,
    picker: Bool,
    query: String,
  )
}

pub type Msg {
  Add(Kind)
  Select(Int)
  Remove(Int)
  Up(Int)
  Down(Int)
  SetField(layer: Int, field: Int, value: String)
  SetPreset(String)
  TogglePicker
  SetQuery(String)
  Copy
  Reset
}

@external(javascript, "../xeerpe_dev_ffi.mjs", "copy")
fn copy(text: String) -> Nil

@external(javascript, "../xeerpe_dev_ffi.mjs", "attempt")
fn attempt(f: fn() -> a) -> Result(a, String)

/// The README's sky.
pub fn init() -> Model {
  Model(
    "",
    [layer(Linear), layer(Vignette), layer(Grain), layer(Animation)],
    0,
    False,
    False,
    "",
  )
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  let model = Model(..model, copied: False)
  let count = list.length(model.layers)
  case msg {
    Add(kind) -> #(add(model, kind), effect.none())
    Select(i) -> #(
      Model(..model, selected: case model.selected == i {
        True -> -1
        False -> i
      }),
      effect.none(),
    )
    Remove(i) -> #(
      Model(
        ..model,
        layers: list.append(
          list.take(model.layers, i),
          list.drop(model.layers, i + 1),
        ),
        selected: case int.compare(model.selected, i) {
          order.Gt -> model.selected - 1
          order.Eq -> -1
          order.Lt -> model.selected
        },
      ),
      effect.none(),
    )
    Up(i) if i > 0 -> #(swap(model, i - 1), effect.none())
    Down(i) if i < count - 1 -> #(swap(model, i), effect.none())
    Up(_) | Down(_) -> #(model, effect.none())
    SetField(i, f, value) -> #(
      Model(
        ..model,
        layers: update_at(model.layers, i, fn(l) {
          Layer(
            ..l,
            fields: update_at(l.fields, f, fn(field) {
              Field(..field, value: value)
            }),
          )
        }),
      ),
      effect.none(),
    )
    SetPreset(name) -> #(
      Model(..model, preset: name, picker: False),
      effect.none(),
    )
    TogglePicker -> #(Model(..model, picker: !model.picker), effect.none())
    SetQuery(query) -> #(Model(..model, query: query), effect.none())
    Copy -> #(
      Model(..model, copied: True),
      effect.from(fn(_) { copy(code(model)) }),
    )
    Reset -> #(init(), effect.none())
  }
}

/// xeerpe draws the first gradient on top, so a new gradient goes above the
/// others and fades to transparent: otherwise an opaque one would hide it.
fn add(model: Model, kind: Kind) -> Model {
  let first_gradient =
    list.index_map(model.layers, fn(l, i) { #(l, i) })
    |> list.find(fn(p) { is_gradient(p.0.kind) })
  case is_gradient(kind), first_gradient {
    True, Ok(#(_, at)) -> {
      let new =
        Layer(
          ..layer(kind),
          fields: list.map(layer(kind).fields, fn(f) {
            // a linear also turns, so it does not repeat the one below
            case f.label, kind {
              "to", _ -> Field(..f, value: "transparent")
              "from", Linear -> Field(..f, value: "#FF5FB8")
              "deg", Linear -> Field(..f, value: "90")
              _, _ -> f
            }
          }),
        )
      Model(
        ..model,
        layers: list.flatten([
          list.take(model.layers, at),
          [new],
          list.drop(model.layers, at),
        ]),
        selected: at,
      )
    }
    _, _ ->
      Model(
        ..model,
        layers: list.append(model.layers, [layer(kind)]),
        selected: list.length(model.layers),
      )
  }
}

/// Swaps layers `i` and `i + 1`; the open one stays open.
fn swap(model: Model, i: Int) -> Model {
  let layers = case list.split(model.layers, i) {
    #(before, [a, b, ..rest]) -> list.append(before, [b, a, ..rest])
    _ -> model.layers
  }
  let selected = case model.selected {
    s if s == i -> i + 1
    s if s == i + 1 -> i
    s -> s
  }
  Model(..model, layers: layers, selected: selected)
}

fn update_at(items: List(a), i: Int, f: fn(a) -> a) -> List(a) {
  list.index_map(items, fn(x, j) {
    case i == j {
      True -> f(x)
      False -> x
    }
  })
}

// -- layers --

const kinds = [
  #("Gradients", [Linear, Radial, Conic]),
  #("Effects", [Noise, Vignette, Grain, Glow, Blur]),
  #("Patterns", [Dots, Grid, Stars, Rays]),
  #("Animation", [Animation]),
]

const animations = [
  "pulse", "rotate", "breathe", "aurora", "shimmer", "liquid", "plasma", "float",
  "drift",
]

const targets = ["default", "gradients", "patterns", "all"]

fn kind_name(kind: Kind) -> String {
  case kind {
    Linear -> "linear"
    Radial -> "radial"
    Conic -> "conic"
    Noise -> "noise"
    Vignette -> "vignette"
    Grain -> "grain"
    Glow -> "glow"
    Blur -> "blur"
    Dots -> "dots"
    Grid -> "grid"
    Stars -> "stars"
    Rays -> "rays"
    Animation -> "animation"
  }
}

fn is_gradient(kind: Kind) -> Bool {
  kind == Linear || kind == Radial || kind == Conic
}

/// The CSS class that colors a layer by its group.
fn group_class(kind: Kind) -> String {
  case kind {
    Linear | Radial | Conic -> "g-grad"
    Dots | Grid | Stars | Rays -> "g-pat"
    Animation -> "g-anim"
    _ -> "g-fx"
  }
}

/// A new layer with its default values.
fn layer(kind: Kind) -> Layer {
  let color = fn(label, value) { Field(label, ColorIn, value) }
  let range = fn(label, value, min, max, step) {
    Field(label, Range(min, max, step), value)
  }
  let text = fn(label, value) { Field(label, TextIn, value) }
  Layer(kind, case kind {
    Linear -> [
      color("from", "#FFB347"),
      color("to", "#4A1942"),
      range("deg", "170", 0.0, 360.0, 1.0),
    ]
    Radial -> [color("from", "#FF7A18"), color("to", "#1A0B05")]
    Conic -> [color("from", "#00C9FF"), color("to", "#92FE9D")]
    Noise -> [range("opacity", "0.3", 0.0, 1.0, 0.05)]
    Vignette -> [
      range("intensity", "0.3", 0.0, 1.0, 0.05),
      color("color", "#1A0B1F"),
    ]
    Grain -> [range("intensity", "3", 0.0, 10.0, 0.5)]
    Glow -> [color("color", "#FF5FB8"), text("amount", "34px")]
    Blur -> [text("amount", "2px")]
    Dots -> [
      color("color", "#FFFFFF"),
      text("size", "16px"),
      text("spacing", "20px"),
      range("opacity", "0.4", 0.0, 1.0, 0.05),
    ]
    Grid -> [
      color("color", "#FFFFFF"),
      text("size", "24px"),
      range("opacity", "0.2", 0.0, 1.0, 0.05),
    ]
    Stars -> [
      color("color", "#FFFFFF"),
      text("size", "160px"),
      range("count", "30", 1.0, 200.0, 1.0),
      range("seed", "4", 0.0, 100.0, 1.0),
    ]
    Rays -> [
      color("color", "#FFFFFF"),
      range("count", "12", 1.0, 48.0, 1.0),
      text("position", "center"),
      range("opacity", "0.2", 0.0, 1.0, 0.05),
    ]
    Animation -> [
      Field("type", Choice(animations), "breathe"),
      text("duration", "6s"),
      Field("target", Choice(targets), "default"),
    ]
  })
}

type Step =
  #(String, fn(xeerpe.Builder) -> xeerpe.Builder)

/// The code and the builder step of a layer, from the same values.
fn steps(l: Layer) -> List(Step) {
  let v = list.map(l.fields, fn(f) { f.value })
  let s = string.inspect
  case l.kind, v {
    Linear, [a, b, d] -> [
      #(
        "quick.linear(" <> s(a) <> ", " <> s(b) <> ", deg: " <> fl(d) <> ")",
        fn(x) { q.linear(x, a, b, deg: num(d)) },
      ),
    ]
    Radial, [a, b] -> [
      #("quick.radial(" <> s(a) <> ", " <> s(b) <> ")", q.radial(_, a, b)),
    ]
    Conic, [a, b] -> [
      #("quick.conic(" <> s(a) <> ", " <> s(b) <> ")", q.conic(_, a, b)),
    ]
    Noise, [o] -> [#("quick.noise(" <> fl(o) <> ")", q.noise(_, num(o)))]
    Vignette, [i, c] -> [
      #("quick.vignette(" <> fl(i) <> ", " <> s(c) <> ")", q.vignette(
        _,
        num(i),
        c,
      )),
    ]
    Grain, [i] -> [#("quick.grain(" <> fl(i) <> ")", q.grain(_, num(i)))]
    Glow, [c, a] -> [
      #("quick.glow(" <> s(c) <> ", " <> s(a) <> ")", q.glow(_, c, a)),
    ]
    Blur, [a] -> [#("quick.blur(" <> s(a) <> ")", q.blur(_, a))]
    Dots, [c, size, spacing, o] -> [
      #(
        "quick.dots("
          <> string.join([s(c), s(size), s(spacing), fl(o)], ", ")
          <> ")",
        q.dots(_, c, size, spacing, num(o)),
      ),
    ]
    Grid, [c, size, o] -> [
      #(
        "quick.grid(" <> string.join([s(c), s(size), fl(o)], ", ") <> ")",
        q.grid(_, c, size, num(o)),
      ),
    ]
    Stars, [c, size, n, seed] -> [
      #(
        "quick.stars("
          <> string.join([s(c), s(size), it(n), it(seed)], ", ")
          <> ")",
        q.stars(_, c, size, whole(n), whole(seed)),
      ),
    ]
    Rays, [c, n, p, o] -> [
      #(
        "quick.rays(" <> string.join([s(c), it(n), s(p), fl(o)], ", ") <> ")",
        q.rays(_, c, whole(n), p, num(o)),
      ),
    ]
    Animation, [name, d, target] ->
      [#("quick." <> name <> "(" <> s(d) <> ")", animate(name)(_, d))]
      |> list.append(case target {
        "gradients" -> [target_step("TargetGradients", xeerpe.TargetGradients)]
        "patterns" -> [target_step("TargetPatterns", xeerpe.TargetPatterns)]
        "all" -> [target_step("TargetAll", xeerpe.TargetAll)]
        _ -> []
      })
    _, _ -> []
  }
}

fn target_step(name: String, target: xeerpe.AnimationTarget) -> Step {
  #("xeerpe.animation_target(xeerpe." <> name <> ")", xeerpe.animation_target(
    _,
    target,
  ))
}

fn animate(name: String) -> fn(xeerpe.Builder, String) -> xeerpe.Builder {
  case name {
    "pulse" -> q.pulse
    "rotate" -> q.rotate
    "aurora" -> q.aurora
    "shimmer" -> q.shimmer
    "liquid" -> q.liquid
    "plasma" -> q.plasma
    "float" -> q.float
    "drift" -> q.drift
    _ -> q.breathe
  }
}

/// A number field as a Float; "3" and "3.0" both work, anything else is 0.
fn num(v: String) -> Float {
  case float.parse(v), int.parse(v) {
    Ok(f), _ -> f
    _, Ok(i) -> int.to_float(i)
    _, _ -> 0.0
  }
}

fn whole(v: String) -> Int {
  float.round(num(v))
}

fn fl(v: String) -> String {
  float.to_string(num(v))
}

fn it(v: String) -> String {
  int.to_string(whole(v))
}

fn all_steps(model: Model) -> List(Step) {
  list.flat_map(model.layers, steps)
}

fn builder(model: Model) -> xeerpe.Builder {
  let base = case model.preset {
    "" -> xeerpe.new()
    name ->
      case xeerpe.preset(name) {
        Ok(b) -> b
        Error(_) -> xeerpe.new()
      }
  }
  list.fold(all_steps(model), base, fn(b, step) { step.1(b) })
}

fn code(model: Model) -> String {
  let start = case model.preset {
    "" -> "  xeerpe.new()"
    name ->
      "  let assert Ok(base) = xeerpe.preset("
      <> string.inspect(name)
      <> ")\n  base"
  }
  let calls = list.map(all_steps(model), fn(step) { step.0 })
  let imports = case list.any(calls, string.starts_with(_, "quick.")) {
    True -> "import xeerpe\nimport xeerpe/quick\n\n"
    False -> "import xeerpe\n\n"
  }
  imports
  <> "pub fn background() -> xeerpe.Builder {\n"
  <> start
  <> string.concat(list.map(calls, fn(c) { "\n  |> " <> c }))
  <> "\n}\n\n// In a Lustre view, with `import xeerpe/css`:\n"
  <> "// html.div([attribute.styles(css.properties(background()))], [])\n"
}

// -- view --

pub fn view(model: Model) -> Element(Msg) {
  let preview = case model.layers, model.preset {
    [], "" ->
      html.div([class("pg-pv pg-empty")], [
        html.text("Add a layer or start from a preset."),
      ])
    _, _ ->
      case attempt(fn() { css.properties(builder(model)) }) {
        Ok(props) -> html.div([class("pg-pv"), attribute.styles(props)], [])
        Error(message) ->
          html.div([class("pg-pv pg-empty pg-error")], [
            html.text("xeerpe: " <> message),
          ])
      }
  }
  let gradients = list.count(model.layers, fn(l) { is_gradient(l.kind) })
  html.section([class("pg")], [
    html.div([class("pg-controls")], [
      preset_picker(model),
      html.div(
        [class("pg-layers")],
        list.index_map(model.layers, fn(l, i) {
          layer_view(l, i, i == model.selected, list.length(model.layers))
        }),
      ),
      case gradients > 1 {
        True ->
          html.p([class("pg-note")], [
            html.text(
              "Gradients stack in order: the first one is drawn on top, so it needs transparent parts to show the ones below.",
            ),
          ])
        False -> element.none()
      },
      add_buttons(model.layers),
    ]),
    html.div([class("pg-out")], [
      preview,
      html.div([class("pg-code")], [
        html.div([class("pg-code-bar")], [
          html.span([], [html.text("Gleam")]),
          html.button([class("pg-primary"), event.on_click(Copy)], [
            html.text(case model.copied {
              True -> "Copied ✓"
              False -> "Copy"
            }),
          ]),
          html.button([event.on_click(Reset)], [html.text("Reset")]),
        ]),
        html.pre([], [html.code([], highlight(code(model)))]),
      ]),
    ]),
  ])
}

/// A button with the current start; it opens a searchable grid of every preset,
/// each drawn with its own background.
fn preset_picker(model: Model) -> Element(Msg) {
  let current = case model.preset {
    "" -> "xeerpe.new()"
    name -> name
  }
  let swatch = case model.preset {
    "" -> html.span([class("pg-pick-sw pg-pick-empty")], [])
    name -> html.span([class("pg-pick-sw"), preset_style(name)], [])
  }
  let query = string.lowercase(string.trim(model.query))
  let groups =
    xeerpe.preset_categories()
    |> list.filter_map(fn(group) {
      case list.filter(group.1, string.contains(_, query)) {
        [] -> Error(Nil)
        names -> Ok(#(group.0, names))
      }
    })
  html.div([class("pg-preset")], [
    html.span([class("pg-preset-label")], [html.text("Start from")]),
    html.button(
      [
        class("pg-pick"),
        attribute.classes([#("on", model.picker)]),
        event.on_click(TogglePicker),
      ],
      [
        swatch,
        html.span([class("pg-pick-name")], [html.text(current)]),
        html.span([class("pg-pick-caret")], [html.text("▾")]),
      ],
    ),
    case model.picker {
      False -> element.none()
      True ->
        html.div([class("pg-pop")], [
          html.div([class("pg-pop-top")], [
            html.input([
              class("pg-search"),
              attribute.placeholder(
                "Search "
                <> int.to_string(list.length(xeerpe.preset_names()))
                <> " presets…",
              ),
              attribute.value(model.query),
              attribute.autofocus(True),
              event.on_input(SetQuery),
            ]),
            html.button(
              [
                class("pg-chip"),
                attribute.classes([#("on", model.preset == "")]),
                event.on_click(SetPreset("")),
              ],
              [html.text("xeerpe.new()")],
            ),
          ]),
          html.div([class("pg-pop-list")], case groups {
            [] -> [
              html.p([class("pg-pop-none")], [html.text("No preset matches.")]),
            ]
            _ ->
              list.map(groups, fn(group) {
                html.div([], [
                  html.h4([], [html.text(group.0)]),
                  html.div(
                    [class("pg-pop-grid")],
                    list.map(group.1, fn(name) {
                      html.button(
                        [
                          class("pg-tile"),
                          attribute.classes([#("on", name == model.preset)]),
                          attribute.title(name),
                          event.on_click(SetPreset(name)),
                        ],
                        [
                          html.span(
                            [class("pg-tile-sw"), preset_style(name)],
                            [],
                          ),
                          html.span([class("pg-tile-name")], [html.text(name)]),
                        ],
                      )
                    }),
                  ),
                ])
              })
          }),
        ])
    },
  ])
}

fn preset_style(name: String) -> attribute.Attribute(msg) {
  case xeerpe.preset(name) {
    Ok(b) ->
      case attempt(fn() { css.properties(b) }) {
        Ok(props) -> attribute.styles(props)
        Error(_) -> attribute.none()
      }
    Error(_) -> attribute.none()
  }
}

fn layer_view(l: Layer, i: Int, open: Bool, count: Int) -> Element(Msg) {
  let action = fn(msg, label, title, disabled) {
    html.button(
      [
        class("pg-icon"),
        event.stop_propagation(event.on_click(msg)),
        attribute.disabled(disabled),
        attribute.title(title),
        attribute.aria_label(title),
      ],
      [html.text(label)],
    )
  }
  let swatches =
    l.fields
    |> list.filter(fn(f) { f.input == ColorIn })
    |> list.map(fn(f) {
      html.span(
        [class("pg-sw"), attribute.styles([#("background", f.value)])],
        [],
      )
    })
  let summary =
    l.fields
    |> list.filter(fn(f) { f.input != ColorIn && f.value != "default" })
    |> list.map(fn(f) { f.value })
    |> string.join(" · ")
  html.div(
    [
      class("pg-layer " <> group_class(l.kind)),
      attribute.classes([#("open", open)]),
    ],
    [
      html.div([class("pg-head"), event.on_click(Select(i))], [
        html.span([class("pg-name")], [html.text(kind_name(l.kind))]),
        html.span(
          [class("pg-sum")],
          list.append(swatches, [html.text(summary)]),
        ),
        action(Up(i), "↑", "Move up", i == 0),
        action(Down(i), "↓", "Move down", i == count - 1),
        action(Remove(i), "✕", "Remove", False),
      ]),
      case open {
        True ->
          html.div([class("pg-body")], [
            layer_preview(l),
            html.div(
              [class("pg-fields")],
              list.index_map(l.fields, fn(f, j) { field_view(i, f, j) }),
            ),
          ])
        False -> element.none()
      },
    ],
  )
}

/// The layer on its own. Gradients sit on a checkerboard to show transparency;
/// the rest need something under them to show at all.
fn layer_preview(l: Layer) -> Element(msg) {
  // light to dark, so both a dark vignette and white dots show
  let mid = q.linear(xeerpe.new(), "#c9c9da", "#2e2e44", deg: 135.0)
  let base = case l.kind {
    Linear | Radial | Conic -> xeerpe.new()
    Animation | Blur | Glow -> q.dots(mid, "#ffffff", "3px", "18px", 0.35)
    _ -> mid
  }
  let b = list.fold(steps(l), base, fn(b, step) { step.1(b) })
  html.div([class("pg-mini")], [
    case attempt(fn() { css.properties(b) }) {
      Ok(props) -> html.div([class("pg-mini-in"), attribute.styles(props)], [])
      Error(message) ->
        html.div([class("pg-mini-in pg-error")], [html.text(message)])
    },
  ])
}

fn field_view(layer: Int, f: Field, i: Int) -> Element(Msg) {
  let set = SetField(layer, i, _)
  let input = case f.input {
    ColorIn -> [
      html.input([
        attribute.type_("color"),
        attribute.value(picker_value(f.value)),
        event.on_input(set),
      ]),
      html.input([attribute.value(f.value), event.on_input(set)]),
    ]
    Range(min, max, step) -> {
      let bounds = [
        attribute.min(float.to_string(min)),
        attribute.max(float.to_string(max)),
        attribute.step(float.to_string(step)),
        attribute.value(f.value),
        event.on_input(set),
      ]
      [
        html.input([attribute.type_("range"), ..bounds]),
        html.input([class("pg-num"), attribute.type_("number"), ..bounds]),
      ]
    }
    TextIn -> [html.input([attribute.value(f.value), event.on_input(set)])]
    Choice(options) -> [
      html.div(
        [class("pg-pills")],
        list.map(options, fn(o) {
          html.button(
            [
              class("pg-pill"),
              attribute.classes([#("on", o == f.value)]),
              event.on_click(set(o)),
            ],
            [html.text(o)],
          )
        }),
      ),
    ]
  }
  // a label would forward clicks on the pills to the first one
  let wrap = case f.input {
    Choice(_) -> html.div
    _ -> html.label
  }
  wrap([class("pg-field")], [html.span([], [html.text(f.label)]), ..input])
}

// -- Gleam syntax colors for the snippet --

type Token {
  Plain(String)
  Token(class: String, text: String)
}

fn highlight(source: String) -> List(Element(msg)) {
  tokens(source, [])
  |> list.map(fn(t) {
    case t {
      Plain(text) -> html.text(text)
      Token(class: c, text: text) -> html.span([class(c)], [html.text(text)])
    }
  })
}

/// Splits Gleam source into colored tokens. Covers what `code` writes:
/// comments, strings, numbers, keywords, types, calls, modules and `|>`.
fn tokens(source: String, acc: List(Token)) -> List(Token) {
  case source {
    "" -> list.reverse(acc)
    "//" <> _ -> {
      let #(comment, rest) = take_until(source, "\n")
      tokens(rest, [Token("t-com", comment), ..acc])
    }
    "\"" <> rest -> {
      let #(body, rest) = string_body(rest, "")
      tokens(rest, [Token("t-str", "\"" <> body), ..acc])
    }
    "|>" <> rest -> tokens(rest, [Token("t-op", "|>"), ..acc])
    _ -> {
      let assert Ok(#(c, rest)) = string.pop_grapheme(source)
      case is_word(c), is_digit(c) {
        _, True -> {
          let #(n, rest) = take_while(source, fn(c) { is_digit(c) || c == "." })
          tokens(rest, [Token("t-num", n), ..acc])
        }
        True, _ -> {
          let #(word, rest) = take_while(source, is_word)
          tokens(rest, [word_token(word, rest), ..acc])
        }
        _, _ -> tokens(rest, push_plain(acc, c))
      }
    }
  }
}

fn word_token(word: String, rest: String) -> Token {
  let keywords = ["import", "pub", "fn", "let", "assert", "case"]
  case list.contains(keywords, word), rest {
    True, _ -> Token("t-kw", word)
    _, "." <> _ -> Token("t-mod", word)
    _, "(" <> _ -> Token("t-fn", word)
    _, _ ->
      case
        string.uppercase(string.slice(word, 0, 1)) == string.slice(word, 0, 1)
        && !string.starts_with(word, "_")
      {
        True -> Token("t-type", word)
        False -> Plain(word)
      }
  }
}

fn push_plain(acc: List(Token), c: String) -> List(Token) {
  case acc {
    [Plain(text), ..rest] -> [Plain(text <> c), ..rest]
    _ -> [Plain(c), ..acc]
  }
}

/// The rest of a string literal after its opening quote, with the closing one.
fn string_body(source: String, acc: String) -> #(String, String) {
  case source {
    "" -> #(acc, "")
    "\\" <> rest ->
      case string.pop_grapheme(rest) {
        Ok(#(c, rest)) -> string_body(rest, acc <> "\\" <> c)
        Error(_) -> #(acc <> "\\", "")
      }
    "\"" <> rest -> #(acc <> "\"", rest)
    _ -> {
      let assert Ok(#(c, rest)) = string.pop_grapheme(source)
      string_body(rest, acc <> c)
    }
  }
}

fn take_until(source: String, stop: String) -> #(String, String) {
  take_while(source, fn(c) { c != stop })
}

fn take_while(source: String, keep: fn(String) -> Bool) -> #(String, String) {
  do_take_while(source, keep, "")
}

fn do_take_while(
  source: String,
  keep: fn(String) -> Bool,
  acc: String,
) -> #(String, String) {
  case string.pop_grapheme(source) {
    Ok(#(c, rest)) ->
      case keep(c) {
        True -> do_take_while(rest, keep, acc <> c)
        False -> #(acc, source)
      }
    Error(_) -> #(acc, source)
  }
}

fn is_digit(c: String) -> Bool {
  string.contains("0123456789", c)
}

fn is_word(c: String) -> Bool {
  c == "_" || string.lowercase(c) != string.uppercase(c) || is_digit(c)
}

/// `<input type=color>` only takes #rrggbb.
fn picker_value(v: String) -> String {
  case string.to_graphemes(string.lowercase(v)) {
    ["#", _, _, _, _, _, _] -> string.lowercase(v)
    // #abc is #aabbcc
    ["#", r, g, b] -> "#" <> r <> r <> g <> g <> b <> b
    _ -> "#000000"
  }
}

/// A kind already in the chain is lit, with a count when it is there twice.
fn add_buttons(layers: List(Layer)) -> Element(Msg) {
  html.div(
    [class("pg-add")],
    list.map(kinds, fn(group) {
      html.div([class("pg-add-row")], [
        html.span([], [html.text(group.0)]),
        ..list.map(group.1, fn(kind) {
          let n = list.count(layers, fn(l) { l.kind == kind })
          html.button(
            [
              class("pg-chip " <> group_class(kind)),
              attribute.classes([#("on", n > 0)]),
              event.on_click(Add(kind)),
            ],
            [
              html.text("+ " <> kind_name(kind)),
              case n > 1 {
                True ->
                  html.span([class("pg-count")], [html.text(int.to_string(n))])
                False -> element.none()
              },
            ],
          )
        })
      ])
    }),
  )
}

pub const styles = "
  .pg { display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1.25fr); gap: 1.5rem; margin-top: 2rem; align-items: start }
  .g-grad { --accent: #ff5fb8 } .g-fx { --accent: #8b7bff } .g-pat { --accent: #3fd0c9 } .g-anim { --accent: #ffb347 }

  .pg-preset { position: relative; display: flex; align-items: center; gap: .75rem; margin-bottom: 1rem; font-size: .85rem }
  .pg-preset-label { opacity: .7 }
  .pg-pick { flex: 1; display: flex; align-items: center; gap: .6rem; padding: .35rem .6rem .35rem .4rem; background: #14141c; border-color: #2c2c3c; border-radius: 10px; text-align: left }
  .pg-pick:hover, .pg-pick.on { border-color: #8b7bff }
  .pg-pick-sw { width: 1.6rem; height: 1.6rem; flex: none; border-radius: 6px; box-shadow: inset 0 0 0 1px rgba(255,255,255,.15) }
  .pg-pick-empty { background-color: #12121a; background-image: conic-gradient(#22222e 25%, transparent 0 50%, #22222e 0 75%, transparent 0); background-size: 8px 8px }
  .pg-pick-name { flex: 1; font-family: ui-monospace, monospace; font-size: .82rem }
  .pg-pick-caret { opacity: .5; transition: transform .15s }
  .pg-pick.on .pg-pick-caret { transform: rotate(180deg) }
  .pg-pop { position: absolute; z-index: 20; top: calc(100% + .4rem); left: 0; right: 0; background: #161620; border: 1px solid #34344a; border-radius: 14px; box-shadow: 0 24px 60px rgba(0,0,0,.6); overflow: hidden }
  .pg-pop-top { display: flex; gap: .5rem; padding: .6rem; border-bottom: 1px solid #23232f }
  .pg-search { flex: 1 }
  .pg-pop-list { max-height: 380px; overflow: auto; padding: .2rem .6rem .7rem }
  .pg-pop h4 { margin: .7rem 0 .4rem; font-size: .7rem; text-transform: uppercase; letter-spacing: .08em; opacity: .5 }
  .pg-pop-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(92px, 1fr)); gap: .4rem }
  .pg-tile { display: grid; gap: .3rem; padding: .3rem; background: #1b1b26; border: 1px solid transparent; border-radius: 9px; text-align: left }
  .pg-tile:hover { border-color: #4a4a66 }
  .pg-tile.on { border-color: #ff5fb8 }
  .pg-tile-sw { height: 42px; border-radius: 6px; background-repeat: no-repeat }
  .pg-tile-name { font-size: .68rem; opacity: .75; white-space: nowrap; overflow: hidden; text-overflow: ellipsis }
  .pg-pop-none { margin: 1rem 0; text-align: center; opacity: .6; font-size: .82rem }
  .pg select, .pg input { min-width: 0; background: #0c0c12; color: inherit; border: 1px solid #2c2c3c; border-radius: 8px; padding: .4rem .55rem; font: inherit; font-size: .85rem }
  .pg select:focus, .pg input:focus { outline: none; border-color: #8b7bff; box-shadow: 0 0 0 3px rgba(139,123,255,.2) }
  .pg-preset select { flex: 1 }

  .pg-layers { display: grid; gap: .5rem }
  .pg-layer { background: #14141c; border: 1px solid #23232f; border-radius: 12px; overflow: hidden; transition: border-color .15s, background .15s }
  .pg-layer.open { background: #181822; border-color: #34344a }
  .pg-head { display: flex; align-items: center; gap: .5rem; padding: .55rem .6rem .55rem .85rem; cursor: pointer; user-select: none }
  .pg-head:hover { background: rgba(255,255,255,.025) }
  .pg-name { font-weight: 600; font-size: .92rem; color: var(--accent) }
  .pg-sum { flex: 1; min-width: 0; display: flex; align-items: center; gap: .3rem; font-size: .76rem; color: #8c8ca0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; font-family: ui-monospace, monospace }
  .pg-sw { width: .8rem; height: .8rem; flex: none; border-radius: 50%; box-shadow: inset 0 0 0 1px rgba(255,255,255,.25) }
  .pg-icon { width: 1.75rem; height: 1.75rem; padding: 0; display: grid; place-items: center; background: transparent; border: 1px solid transparent; border-radius: 7px; font-size: .8rem; opacity: .55 }
  .pg-icon:hover:not(:disabled) { opacity: 1; background: #23232f; border-color: #34344a }
  .pg-icon:disabled { opacity: .15; cursor: default }

  .pg-body { padding: .35rem .85rem .9rem }
  .pg-mini { height: 110px; margin-bottom: .8rem; padding: 14px; border-radius: 10px; background-color: #12121a; background-image: conic-gradient(#1c1c27 25%, transparent 0 50%, #1c1c27 0 75%, transparent 0); background-size: 16px 16px }
  .pg-mini-in { height: 100%; border-radius: 8px; display: grid; place-items: center; font-size: .75rem; text-align: center }
  .pg-fields { display: grid; gap: .55rem }
  .pg-field { display: flex; align-items: center; gap: .55rem; font-size: .82rem }
  .pg-field > span { width: 4.6rem; flex: none; opacity: .6 }
  .pg-field input, .pg-field select { flex: 1 }
  .pg-field input[type=color] { flex: none; width: 2.1rem; height: 2rem; padding: .15rem; cursor: pointer }
  .pg-field input[type=range] { padding: 0; border: 0; background: none; accent-color: var(--accent); box-shadow: none }
  .pg-field .pg-num { flex: none; width: 4.4rem }

  .pg-note { margin: .75rem 0 0; padding: .55rem .75rem; border-radius: 10px; background: rgba(255,95,184,.08); border: 1px solid rgba(255,95,184,.2); font-size: .78rem; line-height: 1.45; color: #f2c6df }

  .pg-add { display: grid; gap: .45rem; margin-top: 1.25rem; padding-top: 1rem; border-top: 1px dashed #2c2c3c }
  .pg-add-row { display: flex; flex-wrap: wrap; align-items: center; gap: .35rem }
  .pg-add-row > span { width: 5.2rem; font-size: .72rem; text-transform: uppercase; letter-spacing: .07em; opacity: .5 }
  .pg-chip { padding: .28rem .7rem; font-size: .78rem; border-radius: 999px; background: #14141c; border-color: #2c2c3c }
  .pg-chip:hover { border-color: var(--accent); color: var(--accent) }
  .pg-chip.on { background: color-mix(in srgb, var(--accent) 16%, #14141c); border-color: color-mix(in srgb, var(--accent) 55%, transparent); color: var(--accent) }
  .pg-pop .pg-chip.on { --accent: #ff5fb8 }
  .pg-count { display: inline-grid; place-items: center; min-width: 1.05rem; height: 1.05rem; margin-left: .35rem; padding: 0 .25rem; border-radius: 999px; background: var(--accent); color: #14141c; font-size: .66rem; font-weight: 700 }
  .pg-pills { flex: 1; display: flex; flex-wrap: wrap; gap: .3rem }
  .pg-pill { padding: .22rem .6rem; font-size: .76rem; border-radius: 999px; background: #0c0c12; border-color: #2c2c3c }
  .pg-pill:hover { border-color: #4a4a66 }
  .pg-pill.on { background: #ffb347; border-color: #ffb347; color: #1a1206; font-weight: 600 }
  .pg-field:has(.pg-pills) { align-items: flex-start } .pg-field:has(.pg-pills) > span { padding-top: .25rem }

  .pg-out { position: sticky; top: 1rem; display: grid; gap: 1rem }
  .pg-pv { height: 340px; border-radius: 16px; overflow: hidden; box-shadow: 0 0 0 1px #23232f, 0 18px 50px rgba(0,0,0,.45) }
  .pg-empty { display: grid; place-items: center; padding: 1rem; text-align: center; font-size: .85rem; color: #9a9aae; background-color: #12121a; background-image: conic-gradient(#191923 25%, transparent 0 50%, #191923 0 75%, transparent 0); background-size: 22px 22px }
  .pg-error { color: #ff9aa8; background-color: #1d0f14 }
  .pg-code { background: #14141c; border: 1px solid #23232f; border-radius: 14px; overflow: hidden }
  .pg-code-bar { display: flex; align-items: center; gap: .5rem; padding: .55rem .6rem .55rem .9rem; border-bottom: 1px solid #23232f }
  .pg-code-bar span { margin-right: auto; font-size: .75rem; text-transform: uppercase; letter-spacing: .08em; opacity: .6 }
  .pg-code-bar button { padding: .3rem .8rem; font-size: .8rem }
  .pg-code .t-kw { color: #ff7ab8 } .pg-code .t-str { color: #a6e3a1 } .pg-code .t-num { color: #fab387 }
  .pg-code .t-com { color: #6c6c84; font-style: italic } .pg-code .t-mod { color: #89b4fa } .pg-code .t-fn { color: #f9e2af }
  .pg-code .t-type { color: #cba6f7 } .pg-code .t-op { color: #94e2d5 }
  .pg-primary { background: #ff5fb8; border-color: #ff5fb8; color: #1a0b14; font-weight: 600 }
  .pg-code pre { margin: 0; border-radius: 0; padding: .9rem 1rem; font-size: .78rem; background: transparent; max-height: 420px; overflow: auto; white-space: pre }

  @media (max-width: 760px) { .pg { grid-template-columns: 1fr } .pg-out { position: static; order: -1 } .pg-pv { height: 200px } }
"
