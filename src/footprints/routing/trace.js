module.exports = {
  params: {
    width: 0.25,
    side: "F",
    net: { type: "net", value: "net" },
    points: [],
  },
  body: (params) =>
    params.points
      .map(
        ({ start, end }) => `
      (segment (start ${params.xy(start.x, start.y)}) (end ${params.xy(end.x, end.y)}) (width ${params.width}) (layer "${params.side}.Cu") (net ${params.net.index}))
    `,
      )
      .join("\n"),
};
