// Via
// Nets
// net: the net this via should be connected to

module.exports = {
  params: {
    net: undefined,
    locked: true,
  },
  body: (p) => `
    (via ${p.at.replace(/ [-\d]+\)$/, ")")}
      ${p.locked ? "(locked yes)" : ""}
      (size 0.8)
      (drill 0.4)
      (layers "F.Cu" "B.Cu")
      (net ${p.net.index})
    )`,
};
