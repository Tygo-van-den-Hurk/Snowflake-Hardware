module.exports = {
  params: {
    designator: "threeWayJumperSameSide",
    A: { type: "net", value: "A" },
    B: { type: "net", value: "B" },
    C: { type: "net", value: "C" },
    locked: true,
  },
  body: (p) => {
    spacing = 1.0;
    return `
      (module Jumper_1TH_2SMD (layer F.Cu) (tedit 0) (descr "Jumper: 1 through-hole, 2 pads")
        ${p.at}

        ${p.locked ? "(locked yes)" : ""}

        (fp_text reference ${p.ref} (at 0 -2) (layer F.SilkS) hide)
        (fp_text value Jumper (at 0 2) (layer F.Fab) hide)
        (pad 1 thru_hole rect (at 0 0 ${p.rot})           (size 1.2 0.6) (drill 0.3) (layers *.Cu *.Paste *.Mask) ${p.A.str})
        (pad 2 thru_hole rect (at 0 -${spacing} ${p.rot}) (size 1.2 0.6) (drill 0.3) (layers *.Cu *.Paste *.Mask) ${p.B.str})
        (pad 3 thru_hole rect (at 0  ${spacing} ${p.rot}) (size 1.2 0.6) (drill 0.3) (layers *.Cu *.Paste *.Mask) ${p.C.str})
      )`;
  },
};
