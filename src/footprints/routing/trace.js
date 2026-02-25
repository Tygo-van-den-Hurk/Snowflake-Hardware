module.exports = {
  params: {
    width: 0.25,
    side: "F",
    net: { type: "net", value: "undefined" },
    traces: [],
    locked: true,
  },
  body: (params) =>
    params.traces
      .map((point) => {
        if (typeof point.start !== "object") {
          throw new Error(
            `expected 'start' property to be an Object or Array, but found ${typeof point.start}`,
          );
        }

        const start = Array.isArray(point.start)
          ? { x: point.start[0], y: point.start[1] }
          : { x: point.start.x, y: point.start.y };

        if (typeof point.end !== "object") {
          throw new Error(
            `expected 'end' property to be an Object or Array, but found ${typeof point.end}`,
          );
        }

        const end = Array.isArray(point.end)
          ? { x: point.end[0], y: point.end[1] }
          : { x: point.end.x, y: point.end.y };

        const width = point.width ?? params.width;
        if (typeof width !== "number") {
          throw new Error(
            `expected 'width' to be of type number, but found ${typeof width}`,
          );
        }

        const side = point.side ?? params.side;
        if (!["*", "F", "B"].includes(side)) {
          throw new Error(
            `expected 'side' property to be one of '*', 'F', 'B', but found ${side}`,
          );
        }

        const net = params.net.str === "undefined" ? params.net : undefined;

        return `(segment
      (start ${params.xy(start.x, start.y)})
      (end ${params.xy(end.x, end.y)})
      (width ${width})
      (layer ${side}.Cu)
      ${params.locked ? "(locked yes)" : ""}
      ${net ? `(net ${params.net.index})` : ""}
    )`;
      })
      .join("\n"),
};
