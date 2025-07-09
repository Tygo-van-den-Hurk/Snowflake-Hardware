> This page is for documentation relating ergogen.

[< Back to the main documentation page](../README.md)

# Ergogen

- [Ergogen](#ergogen)
  - [Overview](#overview)
  - [Points](#points)
  - [Outlines](#outlines)
  - [Cases](#cases)
  - [PCBs](#pcbs)
  - [Adding custom footprints](#adding-custom-footprints)

## Overview

For the generating the files we need for the hardware we'll be using [Ergogen](https://github.com/ergogen/ergogen) as a base. [Ergogen](https://github.com/ergogen/ergogen) is a program that allows you to build keyboards from a YAML config file. We then use [nix](https://nixos.org) to build it, and expand [Ergogen'](https://github.com/ergogen/ergogen) default outputs, by for example adding multiple types of 3D object files, or by checking it's output for mistakes.

## Points

So there is one thing I discovered with Ergogen, to have an exact location that is the same on the outlines, cases, and PCBs, it needs to be a reference. The easiest way to do that is by adding it as a point. Points are originally used for key switches, but they work fine for other things. For this reason I added points for e.g. the microcontroller, the mounting holes, the nix logo, etc.

> [!TIP]
> Ergogen allows for nesting properties using the dot (.) operator. For example:
>
> ```Yaml
> example.object: abc
> ```
>
> Is identical to:
>
> ```Yaml
> example:
>   object: abc
> ```

So if we wanted to create a point where the microcontroller should be we do so as follows:

```Yaml
points.zones.microcontroller:
  columns.x.rows.y.bind: [0, 0]
  anchor:
    ref: matrix_index_top
    shift: [x, y]
```

The next step is to create an outline around that microcontroller.

## Outlines

These are the outlines of components or anything you want really. We build on top of the points we just wrote to make outlines for them. For example:

```Yaml
outlines._microcontroller.body:
  what: rectangle
  size: [width, height]
  where:
    ref: microcontroller_x_y
    shift: [x, y]
```

We use `_` to show that this is a 'private' output. So my nix derivation will not output this at the end. This outline can be used for other outlines.

## Cases

We use the outlines we just made to create cases. Cases are outlines with depth. We can very easily convert an existing outline into a case by specifying that depth:

```Yaml
cases._microcontroller.body:
  what: outline
  name: _microcontroller
  extrude: depth
```

We now generated a "case" the width, height, and depth of a microcontroller.

## PCBs

PCBs are also dependent on outlines. They consist out of 2 components: outlines, and footprints. Building on top of our previously created outlines:

```Yaml
pcbs.snowflake:
  outlines.microcontroller:
    outline: _microcontroller
    layer: Eco1.User
  footprints.microcontroller:
    what: microcontrollers/example
    where.ref: microcontroller_x_y
```

This will create an outline on the PCB at the same place that the outline on the case or SVG will be. That is the power of a reference.

## Adding custom footprints

There is just one problem: Ergogen does not natively have all footprints that you might need. This is where custom footprints come in. To use custom footprints (which we are) use the footprints folder. This folder has to be next to the config file.

```Txt
src
├── footprints
│   ├── buttons
│   ├── connectors
│   ├── controllers
│   ├── decoration
│   ├── diodes
│   ├── jumpers
│   ├── leds
│   ├── mounting-holes
│   ├── routing
│   ├── switches
│   └── ...
└── config.yaml
```

If you need any footprint that this repository is missing, you can find it's JavaScript file, and add it to the `./src/footprints/` directory. There are a lot of footprints you can use. Just make sure it's well tested, because a bad footprint could technically destroy your microcontroller or other components. 

Adding your own is not as hard. Within 2 hours I had my own custom footprint I needed. All you need is to reverse engineer the existing components.
