// Via
// Nets
// net: the net this via should be connected to

module.exports = {
  params: {
    net: { type: "net", value: "net" },
  },
  body: (params) => `
    (via
      ${params.at.replace(/ [-\d]+\)$/, ")")}
      (size 0.8)
      (drill 0.4)
      (layers "F.Cu" "B.Cu")
      (net ${params.net.index})
    )
  `,
};
