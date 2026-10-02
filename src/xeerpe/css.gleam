//// The style of a `Builder` as CSS, for any framework or for plain DOM code.
////
//// In Lustre: `attribute.styles(css.properties(builder))`.

import gleam/dict
import gleam/list
import gleam/string
import xeerpe.{type Builder}

/// The CSS properties of a builder as `#(name, value)` pairs, with CSS names
/// (`background-image`). If the background animates, the keyframes it needs are
/// added to the page once.
pub fn properties(b: Builder) -> List(#(String, String)) {
  kebab_pairs(xeerpe.to_style(b))
}

/// Same for a gradient text fill (`toTextStyle()`).
pub fn text_properties(b: Builder) -> List(#(String, String)) {
  kebab_pairs(xeerpe.to_text_style(b))
}

/// The properties as the text of a `style` attribute: `"name:value;name:value"`.
pub fn inline(b: Builder) -> String {
  properties(b)
  |> list.map(fn(pair) { pair.0 <> ":" <> pair.1 })
  |> string.join(";")
}

/// Adds the keyframes to the page, once. Does nothing outside a browser.
/// `properties` already calls it when the background animates.
@external(javascript, "../xeerpe_ffi.mjs", "ensure_keyframes")
fn add_keyframes_ffi(css: String) -> Nil

pub fn add_keyframes() -> Nil {
  add_keyframes_ffi(keyframes)
}

fn kebab_pairs(style: dict.Dict(String, String)) -> List(#(String, String)) {
  case dict.has_key(style, "animation") {
    True -> add_keyframes()
    False -> Nil
  }
  style
  |> dict.to_list
  |> list.map(fn(pair) { #(kebab(pair.0), pair.1) })
}

/// xeerpe keys are camelCase; CSS wants kebab-case.
fn kebab(s: String) -> String {
  s
  |> string.to_graphemes
  |> list.map(fn(c) {
    case c != string.lowercase(c) {
      True -> "-" <> string.lowercase(c)
      False -> c
    }
  })
  |> string.concat
}

/// xeerpe's `animations.css`, kept as a string so no bundler has to import CSS.
/// For a server-rendered page, put it in a `<style>`.
pub const keyframes = "@keyframes xeerpe-pulse {
    0%, 100% {
        opacity: 1;
    }
    50% {
        opacity: 0.7;
    }
}

@keyframes xeerpe-rotate {
    from {
        transform: rotate(0deg);
    }
    to {
        transform: rotate(360deg);
    }
}

@keyframes xeerpe-breathe {
    0%, 100% {
        background-size: 100% 100%;
    }
    50% {
        background-size: 200% 200%;
    }
}

@keyframes xeerpe-aurora {
    0% {
        background-size: 100% 100%;
    }
    50% {
        background-size: 120% 120%;
    }
    100% {
        background-size: 100% 100%;
    }
}

@keyframes xeerpe-shimmer {
    0% {
        background-position: 200% center;
    }
    100% {
        background-position: -200% center;
    }
}

@keyframes xeerpe-liquid {
    0% {
        background-position: 0% 50%;
        background-size: 100% 100%;
        filter: hue-rotate(0deg);
    }
    50% {
        background-position: 100% 50%;
        background-size: 200% 200%;
        filter: hue-rotate(30deg);
    }
    100% {
        background-position: 0% 50%;
        background-size: 100% 100%;
        filter: hue-rotate(0deg);
    }
}

@keyframes xeerpe-plasma {
    0% {
        filter: hue-rotate(0deg);
    }
    100% {
        filter: hue-rotate(360deg);
    }
}

@keyframes xeerpe-float {
    0%, 100% {
        transform: translateY(0px);
    }
    50% {
        transform: translateY(-10px);
    }
}

@keyframes xeerpe-drift {
    0% {
        background-position: 0% 0%;
    }
    50% {
        background-position: 100% 100%;
    }
    100% {
        background-position: 0% 0%;
    }
}"
