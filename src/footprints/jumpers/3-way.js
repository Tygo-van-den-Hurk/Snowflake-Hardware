module.exports = {
  params: {
    designator: "threeWayJumper",
    A: { type: "net", value: "A" },
    B: { type: "net", value: "B" },
    C: { type: "net", value: "C" },
    size: "2.54",
  },
  body: (p) => {
    spacing = p.size / 2;
    return `
      (module Jumper_1TH_2SMD (layer F.Cu) (tedit 0) (descr "Jumper: 1 through-hole, 2 SMD pads")
        ${p.at}
        (fp_text reference ${p.ref} (at 0 -2) (layer F.SilkS) hide)
        (fp_text value Jumper (at 0 2) (layer F.Fab) hide)
        (pad 1 thru_hole rect (at -${spacing} 0 ${p.rot}) (size 1.2 1.2) (drill 0.3) (layers *.Cu *.Mask) ${p.A.str})
        (pad 2 smd rect (at ${spacing} 0 ${p.rot}) (size 1.2 1.2) (layers F.Cu F.Paste F.Mask) ${p.B.str})
        (pad 3 smd rect (at ${spacing} 0 ${p.rot}) (size 1.2 1.2) (layers B.Cu B.Paste B.Mask) ${p.C.str})
      )`;
  },
};
