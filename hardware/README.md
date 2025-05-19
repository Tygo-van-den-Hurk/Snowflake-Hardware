> This submodule is for generating the hardware of my keyboard.

[< Back to the main README](../README.md)

# Hardware

- [Hardware](#hardware)
  - [Overview](#overview)
  - [Ergogen](#ergogen)
    - [Points](#points)
    - [Adding custom footprints](#adding-custom-footprints)
  - [External Resources](#external-resources)
  - [Components](#components)

## Overview

For the generating the files we need for the hardware we'll be using [ergogen](https://github.com/ergogen/ergogen). [Ergogen](https://github.com/ergogen/ergogen) is a program that allows you to build keyboards from a YAML config file.

## Ergogen

We use ergogen to build the PCBs, outlines, cases, and points for us. I made a nix wrapper to build the results from ergogen see [the contributing guide](../CONTRIBUTING.md) as ergogen does not generate STL files

### Points

So there is one thing I discovered with Ergogen, to have an exact location that is the same on the outlines, cases, and PCBs, it needs to be a point. Points are originally used for key switches, but they work fine for other things. For this reason I added the following points:

```YAML
points:
  zones:
    ...

    # Microcontroller
    microcontroller:
      ...

    # mounting holes
    mounting_hole_top_right:
      ...
    mounting_hole_bottom_right:
      ...
    mounting_hole_bottom_middle:
      ...
    mounting_hole_top_left:
      ...
    mounting_hole_bottom_left:
      ...

    # Nix logo
    nix_logo:
      ...
```

The next step is to create an outline

### Adding custom footprints

There is just one problem: Ergogen does not natively support the pro micro I want to use for my keyboard. So to solve this we have to use footprints. Footprints is a way to extend ergogen's functionality beyond it's native capabilities.

To use footprints we have to use the following structure: there has to be a directory called `footprints` and a file called `config.yaml`. The `config.yaml` is where we'll describe our keyboard to ergogen, and in the `footprints` folder we'll put our missing footprints. Thanks to [@Narkoleptika](https://github.com/Narkoleptika)'s hard work (or who ever he got it from) there is a footprint for the pro micro.

If you need any footprint that this repository is missing, you can find it's JavaScript file, and add it to the `./src/footprints/` directory. There are a lot of footprints you can use. Just make sure it's well tested, because a bad footprint could technically destroy your microcontroller.

## External Resources

- [The ergogen docs](https://docs.ergogen.xyz/) for any questions about how ergogen works.
- [Web-based deployments](https://ergogen.ceoloide.com/) for getting a visual impression of what the keys look like.
- [The ergogen v4 guid I used](https://flatfootfox.com/ergogen-introduction/) for a step by step tutorial.
- [A website that converts JS CAD to STL](https://neorama.de/). This is nice as a JS CAD file isn't useful on its own. Though the flake does provide the openJScad package to convert them manually.

## Components

Here are the components I used for my keyboard:

- Choc key switches;
- a `pro micro` microcontroller;
- my self made PCB;
- diodes.
