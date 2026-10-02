export const read_hash = () => (typeof location === "undefined" ? "" : location.hash);

export const write_hash = (hash) => {
  if (typeof history !== "undefined") history.replaceState(null, "", hash || location.pathname + location.search);
};
