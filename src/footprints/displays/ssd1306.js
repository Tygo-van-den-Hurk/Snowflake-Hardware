"use-strict";

const params = {
  designator: "ssd1306",
  SDA: { type: "net", value: "SDA" },
  SCL: { type: "net", value: "SCL" },
  VCC: { type: "net", value: "VCC" },
  GND: { type: "net", value: "GND" },
  pads: "top",
  order: ["SDA", "SCL", "VCC", "GND"],
  locked: true,
};

function body(p) {
  /* Checking if all parameters are included */ {
    Object.keys(params).forEach(key => {
      if (p?.[key] === undefined) {
        throw new Error(
          `expected '${key}' within the parameter, but found: '${undefined}'`,
        );
      }
    })
  }

  /* Checking if types of the parameters are as expected */ {
    Object.keys(params).forEach(key => {
      if (typeof p[key] !== typeof params[key]) {
        throw new Error(
          `expected '${key}' parameter to be either of type '${typeof params[key]}', but found: '${typeof p[key]}'`,
        );
      }
    })
  }

  /* Checking that parameters contain all the right networks */ {
    params.order.forEach((element) => {
      if (!p?.[element]) {
        throw new Error(
          `expected "${element}" within parameters, but the parameters does not include it`,
        );
      }
    });
  }

  /* Checking type of `order` parameter */ {
    if (!Array.isArray(p.order)) {
      throw new Error(
        `expected 'order' parameter to of type 'string[]', but found type '${typeof p.order}'`,
      );
    }
  }

  /* Checking if order parameter contains all need elements. */ {
    params.order.forEach((element) => {
      if (!p.order.includes(element)) {
        throw new Error(
          `expected "${element}" in order parameter, but order does not include it: [${order.join(", ")}]`,
        );
      }
    });
  }

  /* Checking if order parameter only contains legal elements. */ {
    p.order.forEach((element, index) => {
      if (!params.order.includes(element)) {
        throw new Error(
          `order parameter can only contain one of ${params.order.join(" or ")},` +
            ` but found: "${element}" at index ${index}`,
        );
      }
    });
  }

  /* Checking if pads if one of the allowed options */ {
    p.pads = p.pads.toLowerCase();
    if (p.pads !== "top" && p.pads !== "bottom") {
      throw new Error(
        `expected 'pads' parameter to be either 'top' or 'bottom', but found: '${p.pads}'`,
      );
    }
  }

  let padDirection;

  padDirection = p.pads === "top" ? "-" : "";
  const module = `
      (module "ssd1306" ${p.at}

        ${p.locked ? "(locked yes)" : ""}

        (pad 1M thru_hole rect (at ${2.54 * -1.5} ${padDirection}0.0 ${p.rot}) (size 1.7 1.7) (layers *.Cu *.Mask)         (drill 1.0)        ${p.local_net("1").str})
        (pad 1J thru_hole rect (at ${2.54 * -1.5} ${padDirection}1.6 ${p.rot}) (size 1.7 0.4) (layers *.Cu *.Paste *.Mask) (drill 0.2)        ${p.local_net("1").str})
        (pad 1A smd       rect (at ${2.54 * -1.5} ${padDirection}2.2 ${p.rot}) (size 1.7 0.4) (layers F.Cu F.Paste F.Mask) (clearance 0.1905) ${p[p.order[0]].str})
        (pad 1B smd       rect (at ${2.54 * -1.5} ${padDirection}2.2 ${p.rot}) (size 1.7 0.4) (layers B.Cu B.Paste B.Mask) (clearance 0.1905) ${p[p.order[3]].str})

        (pad 2M thru_hole rect (at ${2.54 * -0.5} ${padDirection}0.0 ${p.rot}) (size 1.7 1.7) (layers *.Cu *.Mask)         (drill 1.0)        ${p.local_net("2").str})
        (pad 2J thru_hole rect (at ${2.54 * -0.5} ${padDirection}1.6 ${p.rot}) (size 1.7 0.4) (layers *.Cu *.Paste *.Mask) (drill 0.2)        ${p.local_net("2").str})
        (pad 2A smd       rect (at ${2.54 * -0.5} ${padDirection}2.2 ${p.rot}) (size 1.7 0.4) (layers F.Cu F.Paste F.Mask) (clearance 0.1905) ${p[p.order[1]].str})
        (pad 2B smd       rect (at ${2.54 * -0.5} ${padDirection}2.2 ${p.rot}) (size 1.7 0.4) (layers B.Cu B.Paste B.Mask) (clearance 0.1905) ${p[p.order[2]].str})

        (pad 3M thru_hole rect (at ${2.54 * 0.5} ${padDirection}0.0 ${p.rot}) (size 1.7 1.7) (layers *.Cu *.Mask)         (drill 1.0)        ${p.local_net("3").str})
        (pad 3J thru_hole rect (at ${2.54 * 0.5} ${padDirection}1.6 ${p.rot}) (size 1.7 0.4) (layers *.Cu *.Paste *.Mask) (drill 0.2)        ${p.local_net("3").str})
        (pad 3A smd       rect (at ${2.54 * 0.5} ${padDirection}2.2 ${p.rot}) (size 1.7 0.4) (layers F.Cu F.Paste F.Mask) (clearance 0.1905) ${p[p.order[2]].str})
        (pad 3B smd       rect (at ${2.54 * 0.5} ${padDirection}2.2 ${p.rot}) (size 1.7 0.4) (layers B.Cu B.Paste B.Mask) (clearance 0.1905) ${p[p.order[1]].str})

        (pad 4M thru_hole rect (at ${2.54 * 1.5} ${padDirection}0.0 ${p.rot}) (size 1.7 1.7) (layers *.Cu *.Mask)         (drill 1.0)        ${p.local_net("4").str})
        (pad 4J thru_hole rect (at ${2.54 * 1.5} ${padDirection}1.6 ${p.rot}) (size 1.7 0.4) (layers *.Cu *.Paste *.Mask) (drill 0.2)        ${p.local_net("4").str})
        (pad 4A smd       rect (at ${2.54 * 1.5} ${padDirection}2.2 ${p.rot}) (size 1.7 0.4) (layers F.Cu F.Paste F.Mask) (clearance 0.1905) ${p[p.order[3]].str})
        (pad 4B smd       rect (at ${2.54 * 1.5} ${padDirection}2.2 ${p.rot}) (size 1.7 0.4) (layers B.Cu B.Paste B.Mask) (clearance 0.1905) ${p[p.order[0]].str})
      )`;

  padDirection = p.pads === "top" ? -1 : 1;
  const traces = `
      (segment (start ${p.xy(2.54 * -1.5, padDirection * 0)}) (end ${p.xy(2.54 * -1.5, padDirection * 1.6)}) (width 0.25) (layer F.Cu))
      (segment (start ${p.xy(2.54 * -1.5, padDirection * 0)}) (end ${p.xy(2.54 * -1.5, padDirection * 1.6)}) (width 0.25) (layer B.Cu))
      (segment (start ${p.xy(2.54 * -0.5, padDirection * 0)}) (end ${p.xy(2.54 * -0.5, padDirection * 1.6)}) (width 0.25) (layer F.Cu))
      (segment (start ${p.xy(2.54 * -0.5, padDirection * 0)}) (end ${p.xy(2.54 * -0.5, padDirection * 1.6)}) (width 0.25) (layer B.Cu))
      (segment (start ${p.xy(2.54 * 0.5, padDirection * 0)}) (end ${p.xy(2.54 * 0.5, padDirection * 1.6)}) (width 0.25) (layer F.Cu))
      (segment (start ${p.xy(2.54 * 0.5, padDirection * 0)}) (end ${p.xy(2.54 * 0.5, padDirection * 1.6)}) (width 0.25) (layer B.Cu))
      (segment (start ${p.xy(2.54 * 1.5, padDirection * 0)}) (end ${p.xy(2.54 * 1.5, padDirection * 1.6)}) (width 0.25) (layer F.Cu))
      (segment (start ${p.xy(2.54 * 1.5, padDirection * 0)}) (end ${p.xy(2.54 * 1.5, padDirection * 1.6)}) (width 0.25) (layer B.Cu))
    `;

  return `
      ${module}
      ${traces}
    `;
}

module.exports = {
  params,
  body,
};
