# JS is such a pile of garbage
# This needs to get a lot better (pretty printing and meaningful diff)

export let def stringify(x)
  let t = typeof(x)
  console.log("STR", t, x)
  if x === true || x === false || t === "string" || t === "number"
    JSON.stringify(x)
  else if Array.isArray(x)
    "[" + x.map(do |el| stringify(el)).join(", ") + "]"
  else if x instanceof Map
    let entries = Array.from(x.entries)
    "Map.new([" + entries.map(do |k,v| "[{stringify(k)}, {stringify(v)}]").join(", ") + "])"
  else if x instanceof Set
    let entries = Array.from(x.entries)
    "Set.new([" + entries.map(do |el| "{stringify(el)}").join(", ") + "])"
  else if t === "object"
    "\{" + Object.entries(x).map(do |k,v| "{stringify(k)}: {stringify(v)}").join(", ") + "\}"
  else
    # JS is horrible
    console.log "Javascript is horrible garbage: {t} {JSON.stringify(x)}"
    JSON.stringify(x)
