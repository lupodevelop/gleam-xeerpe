import { Error as GError, Ok } from "./gleam.mjs";

export const read_hash = () => (typeof location === "undefined" ? "" : location.hash);

export const write_hash = (hash) => {
  if (typeof history !== "undefined") history.replaceState(null, "", hash || location.pathname + location.search);
};

export const copy = (text) => {
  navigator.clipboard?.writeText(text).catch(() => {});
};

// A thrown xeerpe validation error (a bad color, say) becomes an Error.
export const attempt = (f) => {
  try {
    return new Ok(f());
  } catch (e) {
    return new GError(String(e?.message ?? e));
  }
};
