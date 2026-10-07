//// Short forms of the common calls. They are plain `xeerpe` calls underneath;
//// for anything else use `xeerpe` directly.
////
//// ```gleam
//// xeerpe.new()
//// |> quick.linear("#FFB347", "#4A1942", deg: 170.0)
//// |> quick.grain(3.0)
//// |> quick.breathe("6s")
//// ```

import gleam/list
import gleam/option.{Some}
import xeerpe.{type AnimationOptions, type Builder, AnimationOptions}

// -- gradients --

pub fn linear(b: Builder, from: String, to: String, deg deg: Float) -> Builder {
  xeerpe.linear_gradient(
    b,
    xeerpe.LinearGradientOptions(
      ..xeerpe.linear_gradient_options,
      from: Some(from),
      to: Some(to),
      angle: Some(xeerpe.Deg(deg)),
    ),
  )
}

pub fn linear_colors(
  b: Builder,
  colors: List(String),
  deg deg: Float,
) -> Builder {
  xeerpe.linear_gradient(
    b,
    xeerpe.LinearGradientOptions(
      ..xeerpe.linear_gradient_options,
      colors: Some(list.map(colors, xeerpe.Color)),
      angle: Some(xeerpe.Deg(deg)),
    ),
  )
}

pub fn radial(b: Builder, from: String, to: String) -> Builder {
  xeerpe.radial_gradient(
    b,
    xeerpe.RadialGradientOptions(
      ..xeerpe.radial_gradient_options,
      from: Some(from),
      to: Some(to),
    ),
  )
}

pub fn conic(b: Builder, from: String, to: String) -> Builder {
  xeerpe.conic_gradient(
    b,
    xeerpe.ConicGradientOptions(
      ..xeerpe.conic_gradient_options,
      from: Some(from),
      to: Some(to),
    ),
  )
}

/// A mesh of soft color blobs, each `#(position, color)`, e.g. `#("20% 30%", "#0f0")`.
pub fn mesh(
  b: Builder,
  background: String,
  blobs: List(#(String, String)),
) -> Builder {
  let layers =
    list.map(blobs, fn(blob) {
      xeerpe.RadialGradientOptions(
        ..xeerpe.radial_gradient_options,
        position: Some(blob.0),
        from: Some(blob.1),
        to: Some("transparent"),
        color_from_position: Some("0px"),
        color_to_position: Some("55%"),
      )
    })
  xeerpe.mesh_gradient(b, xeerpe.mesh_gradient_options(background, layers))
}

// -- effects --

pub fn noise(b: Builder, opacity: Float) -> Builder {
  xeerpe.noise(
    b,
    xeerpe.NoiseOptions(..xeerpe.noise_options, opacity: Some(opacity)),
  )
}

pub fn vignette(b: Builder, intensity: Float, color: String) -> Builder {
  xeerpe.vignette(
    b,
    xeerpe.VignetteOptions(
      ..xeerpe.vignette_options,
      intensity: Some(intensity),
      color: Some(color),
    ),
  )
}

pub fn grain(b: Builder, intensity: Float) -> Builder {
  xeerpe.grain(
    b,
    xeerpe.GrainOptions(..xeerpe.grain_options, intensity: Some(intensity)),
  )
}

pub fn glow(b: Builder, color: String, amount: String) -> Builder {
  xeerpe.glow(
    b,
    xeerpe.GlowOptions(
      ..xeerpe.glow_options,
      color: Some(color),
      amount: Some(amount),
    ),
  )
}

pub fn blur(b: Builder, amount: String) -> Builder {
  xeerpe.blur(
    b,
    xeerpe.BlurOptions(..xeerpe.blur_options, amount: Some(amount)),
  )
}

/// Blurs what is behind the element.
pub fn backdrop_blur(b: Builder, amount: String) -> Builder {
  xeerpe.blur(
    b,
    xeerpe.BlurOptions(amount: Some(amount), type_: Some(xeerpe.BackdropBlur)),
  )
}

// -- patterns --

/// 8-digit hex colors need xeerpe 0.0.19 or newer; before that, use `#rrggbb` and `opacity`.
pub fn dots(
  b: Builder,
  color: String,
  size: String,
  spacing: String,
  opacity: Float,
) -> Builder {
  xeerpe.dots(
    b,
    xeerpe.DotsOptions(
      ..xeerpe.dots_options,
      color: Some(color),
      size: Some(size),
      spacing: Some(spacing),
      opacity: Some(opacity),
    ),
  )
}

pub fn grid(
  b: Builder,
  color: String,
  size: String,
  opacity: Float,
) -> Builder {
  xeerpe.grid(
    b,
    xeerpe.GridOptions(
      ..xeerpe.grid_options,
      color: Some(color),
      size: Some(size),
      opacity: Some(opacity),
    ),
  )
}

/// Stars on a tile of `size`; `count` per tile, `seed` picks the layout.
pub fn stars(
  b: Builder,
  color: String,
  size: String,
  count: Int,
  seed: Int,
) -> Builder {
  xeerpe.stars(
    b,
    xeerpe.StarsOptions(
      ..xeerpe.stars_options,
      color: Some(color),
      size: Some(size),
      count: Some(count),
      seed: Some(seed),
    ),
  )
}

/// `count` rays from `position` (CSS position syntax, like `"50% 115%"`).
pub fn rays(
  b: Builder,
  color: String,
  count: Int,
  position: String,
  opacity: Float,
) -> Builder {
  xeerpe.rays(
    b,
    xeerpe.RaysOptions(
      ..xeerpe.rays_options,
      color: Some(color),
      count: Some(count),
      position: Some(position),
      opacity: Some(opacity),
    ),
  )
}

// -- animations --

fn duration(d: String) -> AnimationOptions {
  AnimationOptions(..xeerpe.animation_options, duration: Some(d))
}

pub fn pulse(b: Builder, d: String) -> Builder {
  xeerpe.pulse(b, duration(d))
}

pub fn rotate(b: Builder, d: String) -> Builder {
  xeerpe.rotate(b, duration(d))
}

pub fn breathe(b: Builder, d: String) -> Builder {
  xeerpe.breathe(b, duration(d))
}

pub fn aurora(b: Builder, d: String) -> Builder {
  xeerpe.aurora(b, duration(d))
}

pub fn shimmer(b: Builder, d: String) -> Builder {
  xeerpe.shimmer(b, duration(d))
}

pub fn liquid(b: Builder, d: String) -> Builder {
  xeerpe.liquid(b, duration(d))
}

pub fn plasma(b: Builder, d: String) -> Builder {
  xeerpe.plasma(b, duration(d))
}

pub fn float(b: Builder, d: String) -> Builder {
  xeerpe.float(b, duration(d))
}

pub fn drift(b: Builder, d: String) -> Builder {
  xeerpe.drift(b, duration(d))
}
