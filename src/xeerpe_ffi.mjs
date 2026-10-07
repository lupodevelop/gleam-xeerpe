import * as bundled from "./xeerpe_vendor/xeerpe.mjs";
import { Error as GError, Ok, toList } from "./gleam.mjs";

// The xeerpe in use: the bundled copy unless the app swaps it.
let impl = bundled;

export function use_module(m) {
  if (typeof m?.Builder !== "function" || typeof m?.Preset !== "function") {
    return new GError("expected a module exporting Builder and Preset");
  }
  impl = m;
  return new Ok(undefined);
}

export function use_bundled() {
  impl = bundled;
}

export const object = (pairs) => Object.fromEntries(pairs.toArray());
export const null_ = () => null;

export const preset_exists = (name) => {
  try {
    new impl.Preset(name);
    return true;
  } catch (_) {
    return false;
  }
};

// presetNames / presetCategories arrived in xeerpe 1.0; older modules get [].
export const preset_names = () => toList(impl.presetNames ?? []);
export const preset_categories = () =>
  toList(Object.entries(impl.presetCategories ?? {}).map(([k, v]) => [k, toList(v)]));

// Gleam lists to arrays, at any depth inside plain objects.
const toArg = (a) =>
  a?.toArray
    ? a.toArray().map(toArg)
    : a?.constructor === Object
      ? Object.fromEntries(Object.entries(a).map(([k, v]) => [k, toArg(v)]))
      : a;

// base: a Preset name, or "" for a plain Builder.
export function build(base, steps, text) {
  const b = base ? new impl.Preset(base) : new impl.Builder();
  for (const [method, args] of steps.toArray()) b[method](...args.toArray().map(toArg));
  const style = text ? b.toTextStyle() : b.toStyle();
  return toList(Object.entries(style));
}

// Adds the keyframes to <head> once. Does nothing outside a browser.
export function ensure_keyframes(css) {
  if (typeof document === "undefined" || document.getElementById("xeerpe-keyframes")) return;
  const el = document.createElement("style");
  el.id = "xeerpe-keyframes";
  el.textContent = css;
  document.head.appendChild(el);
}
