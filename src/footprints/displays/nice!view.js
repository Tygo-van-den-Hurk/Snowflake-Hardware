let padDirection;

module.exports = {
  params: {
    designator: "nice!view",
    SCK: { type: "net", value: "SCK" },
    MOSI: { type: "net", value: "MOSI" },
    VCC: { type: "net", value: "VCC" },
    GND: { type: "net", value: "GND" },
    CS: { type: "net", value: "CS" },
    pads: "top",
    locked: true,
  },
  body: (p) => {
    p.pads = `${p.pads}`.toLowerCase();
    if (p.pads !== "top" && p.pads !== "bottom") {
      throw new Error(
        `expected 'pads' parameter to be either 'top' or 'bottom', but found: '${p.pads}'`,
      );
    }

    padDirection = p.pads === "top" ? "-" : "";
    const module = `
      (module "nice!view" ${p.at}

        ${p.locked ? "(locked yes)" : ""}

        (pad 1M thru_hole rect (at ${2.54 * -2} ${padDirection}0.0 ${p.rot}) (size 1.7 1.7) (layers *.Cu *.Mask)         (clearance 0.1905) (drill 1.0)    ${p.local_net("1").str})
        (pad 1J thru_hole rect (at ${2.54 * -2} ${padDirection}1.6 ${p.rot}) (size 1.7 0.4) (layers *.Cu *.Paste *.Mask) (clearance 0.1905) (drill 0.2)    ${p.local_net("1").str})
        (pad 1A smd       rect (at ${2.54 * -2} ${padDirection}2.2 ${p.rot}) (size 1.7 0.4) (layers F.Cu F.Paste F.Mask) (clearance 0.1905)                ${p.MOSI.str})
        (pad 1B smd       rect (at ${2.54 * -2} ${padDirection}2.2 ${p.rot}) (size 1.7 0.4) (layers B.Cu B.Paste B.Mask) (clearance 0.1905)                ${p.CS.str})

        (pad 2M thru_hole rect (at ${2.54 * -1} ${padDirection}0.0 ${p.rot}) (size 1.7 1.7) (layers *.Cu *.Mask)         (clearance 0.1905) (drill 1.0)    ${p.local_net("2").str})
        (pad 2J thru_hole rect (at ${2.54 * -1} ${padDirection}1.6 ${p.rot}) (size 1.7 0.4) (layers *.Cu *.Paste *.Mask) (clearance 0.1905) (drill 0.2)    ${p.local_net("2").str})
        (pad 2A smd       rect (at ${2.54 * -1} ${padDirection}2.2 ${p.rot}) (size 1.7 0.4) (layers F.Cu F.Paste F.Mask) (clearance 0.1905)                ${p.SCK.str})
        (pad 2B smd       rect (at ${2.54 * -1} ${padDirection}2.2 ${p.rot}) (size 1.7 0.4) (layers B.Cu B.Paste B.Mask) (clearance 0.1905)                ${p.GND.str})

        (pad 3M thru_hole rect (at ${2.54 * 0} ${padDirection}0.0 ${p.rot}) (size 1.7 1.7) (layers *.Cu *.Mask)         (clearance 0.1905) (drill 1.0)    ${p.local_net("3").str})
        (pad 3J thru_hole rect (at ${2.54 * 0} ${padDirection}1.6 ${p.rot}) (size 1.7 0.4) (layers *.Cu *.Paste *.Mask) (clearance 0.1905) (drill 0.2)    ${p.local_net("3").str})
        (pad 3A thru_hole rect (at ${2.54 * 0} ${padDirection}2.2 ${p.rot}) (size 1.7 0.4) (layers *.Cu *.Paste *.Mask) (clearance 0.1905) (drill 0.2)    ${p.VCC.str})

        (pad 4M thru_hole rect (at ${2.54 * 1} ${padDirection}0.0 ${p.rot}) (size 1.7 1.7) (layers *.Cu *.Mask)         (clearance 0.1905) (drill 1.0)    ${p.local_net("4").str})
        (pad 4J thru_hole rect (at ${2.54 * 1} ${padDirection}1.6 ${p.rot}) (size 1.7 0.4) (layers *.Cu *.Paste *.Mask) (clearance 0.1905) (drill 0.2)    ${p.local_net("4").str})
        (pad 4A smd       rect (at ${2.54 * 1} ${padDirection}2.2 ${p.rot}) (size 1.7 0.4) (layers F.Cu F.Paste F.Mask) (clearance 0.1905)                ${p.GND.str})
        (pad 4B smd       rect (at ${2.54 * 1} ${padDirection}2.2 ${p.rot}) (size 1.7 0.4) (layers B.Cu B.Paste B.Mask) (clearance 0.1905)                ${p.SCK.str})

        (pad 5M thru_hole rect (at ${2.54 * 2} ${padDirection}0.0 ${p.rot}) (size 1.7 1.7) (layers *.Cu *.Mask)         (clearance 0.1905) (drill 1.0)    ${p.local_net("5").str})
        (pad 5J thru_hole rect (at ${2.54 * 2} ${padDirection}1.6 ${p.rot}) (size 1.7 0.4) (layers *.Cu *.Paste *.Mask) (clearance 0.1905) (drill 0.2)    ${p.local_net("5").str})
        (pad 5A smd       rect (at ${2.54 * 2} ${padDirection}2.2 ${p.rot}) (size 1.7 0.4) (layers F.Cu F.Paste F.Mask) (clearance 0.1905)                ${p.CS.str})
        (pad 5B smd       rect (at ${2.54 * 2} ${padDirection}2.2 ${p.rot}) (size 1.7 0.4) (layers B.Cu B.Paste B.Mask) (clearance 0.1905)                ${p.MOSI.str})
      )
    `;

    padDirection = p.pads === "top" ? -1 : 1;
    const traces = `
      (segment (start ${p.xy(2.54 * -2, padDirection * 0)}) (end ${p.xy(2.54 * -2, padDirection * 1.6)}) (width 0.25) (layer F.Cu))
      (segment (start ${p.xy(2.54 * -2, padDirection * 0)}) (end ${p.xy(2.54 * -2, padDirection * 1.6)}) (width 0.25) (layer B.Cu))
      (segment (start ${p.xy(2.54 * -1, padDirection * 0)}) (end ${p.xy(2.54 * -1, padDirection * 1.6)}) (width 0.25) (layer F.Cu))
      (segment (start ${p.xy(2.54 * -1, padDirection * 0)}) (end ${p.xy(2.54 * -1, padDirection * 1.6)}) (width 0.25) (layer B.Cu))
      (segment (start ${p.xy(2.54 * 0, padDirection * 0)}) (end ${p.xy(2.54 * 0, padDirection * 1.6)}) (width 0.25) (layer F.Cu))
      (segment (start ${p.xy(2.54 * 0, padDirection * 0)}) (end ${p.xy(2.54 * 0, padDirection * 1.6)}) (width 0.25) (layer B.Cu))
      (segment (start ${p.xy(2.54 * 1, padDirection * 0)}) (end ${p.xy(2.54 * 1, padDirection * 1.6)}) (width 0.25) (layer F.Cu))
      (segment (start ${p.xy(2.54 * 1, padDirection * 0)}) (end ${p.xy(2.54 * 1, padDirection * 1.6)}) (width 0.25) (layer B.Cu))
      (segment (start ${p.xy(2.54 * 2, padDirection * 0)}) (end ${p.xy(2.54 * 2, padDirection * 1.6)}) (width 0.25) (layer F.Cu))
      (segment (start ${p.xy(2.54 * 2, padDirection * 0)}) (end ${p.xy(2.54 * 2, padDirection * 1.6)}) (width 0.25) (layer B.Cu))
    `;

    return `
      ${module}
      ${traces}
    `;
  },
};
