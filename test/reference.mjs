// The same chains written straight against the npm package.
import { pathToFileURL } from "node:url";

const npmDir = "test/npm-xeerpe/node_modules/xeerpe";
const npm = await import(pathToFileURL(`${process.cwd()}/${npmDir}/dist/index.mjs`));
const { Builder, Preset } = npm;
import { toList } from "./gleam.mjs";

const out = (s) => toList(Object.entries(s));

const A = "#FFB347", B = "#4A1942";
const DIRS = ["to top", "to bottom", "to left", "to right", "to top right", "to bottom right", "to top left", "to bottom left"];
const POS = ["50%", "120px", "8rem", "8em", "15vh", "10vw", "12vmin", "8vmax", "calc(50% + 20px)"];

const scenarios = {
  ks_linear: () => {
    const b = new Builder();
    for (const direction of DIRS) b.linearGradient({ from: A, to: B, direction });
    for (const angle of ["135deg", "2.4rad", "150grad", "0.4turn"]) b.linearGradient({ from: A, to: B, angle });
    for (const position of POS) b.linearGradient({ colors: ["#ff0000", { color: "#00ff00", position }, "#0000ff"] });
    b.linearGradient({ from: A, to: B, size: "60%", backgroundSize: "200% 100%" });
    return b.toStyle();
  },
  ks_radial: () => {
    const b = new Builder();
    for (const shape of ["circle", "ellipse", null]) b.radialGradient({ from: A, to: B, shape });
    for (const size of ["closest-side", "closest-corner", "farthest-side", "farthest-corner", "40px 80px"]) b.radialGradient({ from: A, to: B, size });
    b.radialGradient({ from: A, to: B, shape: "ellipse", size: "closest-side", position: "20% 30%", colorFromPosition: "10%", colorToPosition: "70%", backgroundSize: "50% 50%" });
    return b.toStyle();
  },
  ks_conic: () =>
    new Builder().conicGradient({ from: A, to: B }).conicGradient({ colors: ["#ff0000", { color: "#00ff00", position: "40%" }, "#0000ff"], angle: "90deg", position: "20% 30%", backgroundSize: "50% 50%" }).toStyle(),
  ks_mesh: () =>
    new Builder().meshGradient({ background: "#050914", from: A, to: B, backgroundSize: "100% 100%", layers: [{ position: "10% 20%", from: "#00ff88", to: "transparent", shape: "ellipse", size: "closest-side", colorFromPosition: "0px", colorToPosition: "55%", backgroundSize: "50% 50%" }, { from: "#8800ff", to: "transparent" }] }).toStyle(),
  ks_effects: () =>
    new Builder()
      .noise({ type: "turbulence", opacity: 0.3, scale: 2, octaves: 3, backgroundSize: "50% 50%" })
      .noise({ type: "fractalNoise" })
      .vignette({ color: "#112233", intensity: 0.4, spread: 1.5, backgroundSize: "100% 100%" })
      .grain({ intensity: 2, size: "3px", animated: true, backgroundSize: "50% 50%" })
      .glow({ amount: "20px", spread: "4px", x: "6px", y: "8px", color: "#ff00ff", type: "outer" })
      .glow({ type: "inner" })
      .toStyle(),
  ks_filters: () => new Builder().blur({ amount: "6px", type: "blur" }).blur({ amount: "4px", type: "backdrop" }).filter("blur", { amount: "2px", type: "blur" }).toStyle(),
  ks_patterns: () =>
    new Builder()
      .dots({ color: "#ffffff", background: "#000000", size: "12px", spacing: "30px", style: "ring", opacity: 0.4, strokeWidth: "2px", backgroundSize: "40px 40px" })
      .grid({ color: "#ff0000", background: "#000000", size: "16px", opacity: 0.3, strokeWidth: "3px", backgroundSize: "40px 40px" })
      .pattern("grid", {}).toStyle(),
  ks_animations: () => {
    const b = new Builder();
    for (const t of ["pulse", "rotate", "breathe", "aurora", "shimmer", "liquid", "plasma", "float", "drift"]) b.animation(t, { duration: "2s" });
    for (const direction of ["normal", "reverse", "alternate", "alternate-reverse"]) b.float({ direction });
    b.pulse({ duration: "1s", easing: "cubic-bezier(.2,.8,.2,1)", direction: "alternate", iterationCount: 3 });
    b.drift({ iterationCount: "infinite" });
    return b.toStyle();
  },
  ks_generic: () =>
    new Builder()
      .gradient("linear", { from: A, to: B }).gradient("radial", { from: A, to: B }).gradient("conic", { from: A, to: B }).gradient("mesh", { background: "#000000", layers: [{ from: A, to: B }] })
      .effect("noise", { opacity: 0.2 }).effect("vignette", { intensity: 0.3 }).effect("grain", { intensity: 1 }).effect("glow", { color: "#ff00ff" })
      .filter("blur", { amount: "3px" }).pattern("dots", { color: "#ffffff" }).pattern("grid", { color: "#ffffff" }).animation("aurora", { duration: "3s" })
      .toStyle(),
  ks_text: () => new Builder().linearGradient({ colors: [A, B, "#00ccff"], angle: "90deg" }).toTextStyle(),
  linear: () => new Builder().linearGradient({ from: "#111", to: "#222", angle: "170deg" }).toStyle(),
  linear_colors: () =>
    new Builder()
      .linearGradient({ colors: ["#f00", { color: "#0f0", position: "50%" }, { color: "#00f", position: "calc(100% - 4px)" }], direction: "to top right", size: "50% 50%" })
      .toStyle(),
  radial: () => new Builder().radialGradient({ from: "#fff", to: "#000", shape: null, size: "closest-side", position: "10% 20%", colorFromPosition: "0px", colorToPosition: "60%" }).toStyle(),
  conic: () => new Builder().conicGradient({ colors: ["#f00", "#00f"], angle: "0.5turn", position: "center" }).toStyle(),
  mesh: () => new Builder().meshGradient({ background: "#050914", layers: [{ position: "15% 15%", from: "#0f0", to: "transparent" }, { from: "#00f", to: "transparent", shape: "ellipse" }] }).toStyle(),
  effects: () =>
    new Builder().noise({ opacity: 0.2, scale: 2, type: "turbulence", octaves: 4 }).vignette({ intensity: 0.3, color: "#000", spread: 2 }).grain({ intensity: 3, size: "2px", animated: true }).glow({ amount: "10px", spread: "2px", x: "1px", y: "2px", color: "#f0f", type: "inner" }).toStyle(),
  blur: () => new Builder().blur({ amount: "8px", type: "backdrop" }).filter("blur", { amount: "2px" }).toStyle(),
  patterns: () => new Builder().dots({ color: "#fff", size: "2px", spacing: "20px", opacity: 0.5 }).grid({ color: "#999", size: "10px", strokeWidth: "2px" }).pattern("dots", { background: "#000" }).toStyle(),
  animations: () =>
    new Builder().pulse({ duration: "1s" }).rotate({ easing: "linear", direction: "alternate-reverse" }).breathe({ iterationCount: 3 }).aurora({ iterationCount: "infinite" }).animation("pulse", {}).toStyle(),
  generic: () => new Builder().gradient("linear", { from: "#aa0000", to: "#0000bb" }).effect("grain", { intensity: 1 }).toStyle(),
  text: () => new Builder().linearGradient({ from: "#111", to: "#222" }).toTextStyle(),
  animations2: () =>
    new Builder().shimmer({ duration: "1s" }).liquid({ easing: "linear" }).plasma({ iterationCount: 2 }).float({ direction: "reverse" }).drift({ duration: "5s" }).animation("shimmer", { duration: "2s" }).toStyle(),
  hex8: () => new Builder().dots({ color: "#ffffff80" }).grid({ color: "#ff000040" }).vignette({ color: "#ffffff80" }).toStyle(),
  // another order, repeated calls, the same layer type twice
  shuffled: () =>
    new Builder().aurora({ duration: "3s" }).grain({ intensity: 1 }).linearGradient({ from: "#aa0000", to: "#0000bb" }).vignette({ intensity: 0.2 }).radialGradient({ from: "#00aa00", to: "#cc00cc" }).grain({ intensity: 5 }).dots({ color: "#fff" }).blur({ amount: "2px" }).toStyle(),
  sunrise: () => new Preset("sunrise").toStyle(),
  preset: () => new Preset("northern-lights").vignette({ intensity: 0.5 }).toStyle(),
};

export const reference = (name) => out(scenarios[name]());

// the npm module, and a fake one to show the override is used
export const npm_module = () => npm;
export const fake_module = () => ({
  Builder: class extends Builder {
    toStyle() { return { marker: "override" }; }
  },
  Preset,
});
export const bad_module = () => ({ Builder });

// -- the bundled copy and the Gleam files against npm --
import { readFileSync } from "node:fs";
const root = process.cwd();
const read = (path) => readFileSync(`${root}/${path}`, "utf8");

export const bundled_is_npm = () => read("src/xeerpe_vendor/xeerpe.mjs") === read(`${npmDir}/dist/index.mjs`);

export const npm_version = () => JSON.parse(read(`${npmDir}/package.json`)).version;

export const vendor_version_file = () => read("src/xeerpe_vendor/VERSION");

export const animations_css_is_npm = (css) => css === read(`${npmDir}/dist/animations.css`).trim();

// every npm color has a `pub const` with the same value, and colors.gleam has nothing else
export const colors_in_sync = () => {
  const snake = (k) => k.replace(/[A-Z]/g, (m) => "_" + m.toLowerCase());
  const mine = Object.fromEntries([...read("src/xeerpe/colors.gleam").matchAll(/^pub const (\w+) = "([^"]+)"/gm)].map((m) => [m[1], m[2]]));
  const theirs = Object.fromEntries(Object.entries(npm.colors).map(([k, v]) => [snake(k), v]));
  return JSON.stringify(Object.entries(mine).sort()) === JSON.stringify(Object.entries(theirs).sort());
};

// the version numbers the README keeps between <!--v--> markers
export const readme_versions = () => toList([...read("README.md").matchAll(/<!--v-->([^<]*)<!--\/v-->/g)].map((m) => m[1]));
