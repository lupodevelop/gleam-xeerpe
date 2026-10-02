//// Lustre helpers for `xeerpe`.

import gleam/dict.{type Dict}
import gleam/list
import gleam/string
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import xeerpe.{type Builder}

/// An inline `style` attribute for any element. If the pipeline animates, the
/// keyframes are added to the page once.
pub fn attribute(b: Builder) -> Attribute(msg) {
  styles(xeerpe.to_style(b))
}

/// A gradient text fill (`toTextStyle()`).
pub fn text_attribute(b: Builder) -> Attribute(msg) {
  styles(xeerpe.to_text_style(b))
}

/// A `<style>` with xeerpe's keyframes, for pages rendered on the server. In the
/// browser `attribute` adds them by itself.
pub fn animations() -> Element(msg) {
  html.style([], animations_css)
}

@external(javascript, "../xeerpe_ffi.mjs", "ensure_keyframes")
fn ensure_keyframes(css: String) -> Nil

/// xeerpe keys are camelCase; CSS wants kebab-case.
fn styles(style: Dict(String, String)) -> Attribute(msg) {
  case dict.has_key(style, "animation") {
    True -> ensure_keyframes(animations_css)
    False -> Nil
  }
  style
  |> dict.to_list
  |> list.map(fn(p) { #(kebab(p.0), p.1) })
  |> attribute.styles
}

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
pub const animations_css = "@keyframes xeerpe-pulse {
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
