module.exports = {
  params: {
    points: [],
    locked: true,
  },
  body: (p) => {
    const points = p.points
      .map((point) =>
        Array.isArray(point)
          ? `(xy ${p.xy(point[0], point[1])})`
          : `(xy ${p.xy(point.x, point.y)})`,
      )
      .join("\n");

    return `
      (zone
        ${p.locked ? "(locked yes)" : ""}
        (layers "F&B.Cu")
        (hatch edge 0.5)
        (connect_pads (clearance 0))
        (min_thickness 0.25)
        (filled_areas_thickness no)
        (keepout
          (tracks not_allowed)
          (vias not_allowed)
          (pads not_allowed)
          (copperpour allowed)
          (footprints allowed)
        )
        (fill (thermal_gap 0.5) (thermal_bridge_width 0.5))
        (polygon
          (pts ${points})
        )
      )`;
  },
};
