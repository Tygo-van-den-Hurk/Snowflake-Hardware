module.exports = {
  params: {
    designator: "S",
    reverse: true,
    r1: { type: "net", value: "r1" },
    r2: { type: "net", value: "r2" },
  },
  body: (p) => `
        (footprint 434121025816 (tedit 63B6D2D4) ${p.at}

            (fp_line (start -3.0 1.95) (end 3.0 1.95) (layer F.Fab) (width 0.1))
            (fp_line (start 3.0 1.95) (end 3.0 -1.95) (layer F.Fab) (width 0.1))
            (fp_line (start 3.0 -1.95) (end -3.0 -1.95) (layer F.Fab) (width 0.1))
            (fp_line (start -3.0 -1.95) (end -3.0 1.95) (layer F.Fab) (width 0.1))

            (fp_line (start -3.1 -1.1) (end -3.1 -2.05) (layer B.SilkS) (width 0.2))
            (fp_line (start -3.1 -2.05) (end 3.1 -2.05) (layer B.SilkS) (width 0.2))
            (fp_line (start 3.1 -2.05) (end 3.1 -1.1) (layer B.SilkS) (width 0.2))
            (fp_line (start -3.1 1.1) (end -3.1 2.05) (layer B.SilkS) (width 0.2))
            (fp_line (start -3.1 2.05) (end 3.1 2.05) (layer B.SilkS) (width 0.2))
            (fp_line (start 3.1 2.05) (end 3.1 1.1) (layer B.SilkS) (width 0.2))
            (fp_circle (center 2.6 1.2) (end 2.5 1.2) (layer B.SilkS) (width 0.2))

            (fp_line (start -3.1 -1.1) (end -3.1 -2.05) (layer F.SilkS) (width 0.2))
            (fp_line (start -3.1 -2.05) (end 3.1 -2.05) (layer F.SilkS) (width 0.2))
            (fp_line (start 3.1 -2.05) (end 3.1 -1.1) (layer F.SilkS) (width 0.2))
            (fp_line (start -3.1 1.1) (end -3.1 2.05) (layer F.SilkS) (width 0.2))
            (fp_line (start -3.1 2.05) (end 3.1 2.05) (layer F.SilkS) (width 0.2))
            (fp_line (start 3.1 2.05) (end 3.1 1.1) (layer F.SilkS) (width 0.2))
            (fp_circle (center -2.6 -1.2) (end -2.5 -1.2) (layer F.SilkS) (width 0.2))

            (pad 1 thru_hole rect (at -3.25 0.0 ${p.rot}) (size 1.5 1.4) (drill 1.0) (layers *.Cu *.Mask) ${p.r1.str})
            (pad 2 thru_hole rect (at  3.25 0.0 ${p.rot}) (size 1.5 1.4) (drill 1.0) (layers *.Cu *.Mask) ${p.r2.str})
        )
    `,
};
