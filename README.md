> This repository will be used for making the hardware of my first custom keyboard: _Snowflake_

<br>
<div align="center">
  <!--~ Tools ~-->
  <a href="https://nixos.org">
    <img src="https://img.shields.io/badge/Built_With-Nix-5277C3.svg?style=flat&logo=nixos&labelColor=73C3D5" alt="Built with Nix"/>
  </a>
  <a href="https://containers.dev/">
    <img src="https://img.shields.io/badge/devcontainer-provided-green?style=flat" alt="devcontainer provided"/>
  </a>
  <!--~ CI/CD ~-->
  <a href="https://github.com/Tygo-van-den-Hurk/keyboard/actions/workflows/nix-github-actions.yml">
    <img src="https://github.com/Tygo-van-den-Hurk/keyboard/workflows/Nix%20Flake%20Checks/badge.svg?style=flat" alt="GitHub tests status" />
  </a>
  <a href="https://github.com/Tygo-van-den-Hurk/keyboard/actions/workflows/deploy-github-pages.yml">
    <img src="https://github.com/Tygo-van-den-Hurk/keyboard/workflows/Deploy%20GitHub%20Pages/badge.svg?style=flat" alt="GitHub deployment status" />
  </a>
  <!--~ Repository Statistics ~-->
  <a href="https://github.com/Tygo-van-den-Hurk/keyboard/graphs/contributors">
    <img src="https://img.shields.io/github/contributors/Tygo-van-den-Hurk/keyboard?style=flat" alt="Contributors"/>
  </a>
  <a href="https://github.com/Tygo-van-den-Hurk/keyboard/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/Tygo-van-den-Hurk/keyboard?style=flat" alt="The Eclipse Public License v2.0 badge" />
  </a>
  <a href="https://github.com/Tygo-van-den-Hurk/keyboard/commit">
    <img src="https://badgen.net/github/commits/Tygo-van-den-Hurk/keyboard?style=flat" alt="GitHub commits" />
  </a>
  <a href="https://github.com/Tygo-van-den-Hurk/keyboard/commit">
    <img src="https://badgen.net/github/last-commit/Tygo-van-den-Hurk/keyboard?style=flat" alt="GitHub latest commit" />
  </a>
  <a href="https://github.com/Tygo-van-den-Hurk/keyboard/pulse">
    <img src="https://img.shields.io/github/created-at/Tygo-van-den-Hurk/keyboard?style=flat" alt="created at badge" />
  </a>
  <a href="https://github.com/Tygo-van-den-Hurk/keyboard/releases">
    <img src="https://img.shields.io/github/release/Tygo-van-den-Hurk/keyboard?style=flat&display_name=release" alt="newest release" />
  </a>
  <a href="https://github.com/Tygo-van-den-Hurk/keyboard/">
    <img src="https://img.shields.io/github/languages/count/Tygo-van-den-Hurk/keyboard?style=flat" alt="amount of languages in the repository" />
  </a>    
  <a href="https://github.com/Tygo-van-den-Hurk/keyboard/">
    <img src="https://img.shields.io/github/repo-size/Tygo-van-den-Hurk/keyboard?style=flat" alt="the size of the repository" />
  </a>   
  <br><br>
  <img src="./images/svg/snowflake.svg">
</div>
<br>

# Snowflake (hardware)

- [Snowflake (hardware)](#snowflake-hardware)
  - [Overview](#overview)
  - [Documentation](#documentation)
  - [Credits](#credits)
  - [External Resources](#external-resources)
  - [Licence](#licence)

## Overview

So this repository is for the journey of me making my first keyboard: _Snowflake_. I wanted a keyboard that works for me, I wanted something that I could take with me anywhere and would work the way I designed it to do. This also was a good excuse to learn about keyboards which is something I've wanted to do for a while now.

## Documentation

There are two parts to this journey: hardware and software. This repository is used for generating the hardware side of things. Since different iterations of the hardware have different pinouts or other physical workings each iteration has its own firmware repository. See `github.com/Tygo-van-den-Hurk/Snowflake-V*-Firmware` for your firmware. Where `*` is the major version you have. There will be documentation on how to build or flash the respective firmware.

As for the hardware part, see the [`/docs`](./docs/README.md) for more.

## Credits

This code is written by, or using the help of:

- [@Narkoleptika](https://github.com/Narkoleptika) for providing the pro micro footprint and setting me up with a template.
- [@RajuBuddharaju](https://github.com/RajuBuddharaju) for helping me realise every part of this keyboard.
- [@Tygo-van-den-Hurk](https://github.com/Tygo-van-den-Hurk)

To see how to start or develop see [CONTRIBUTING.md](./CONTRIBUTING.md).

## External Resources

- [The ergogen docs](https://docs.ergogen.xyz/) for any questions about how ergogen works.
- [Web-based deployments](https://ergogen.ceoloide.com/) for getting a visual impression of what the keys look like.
- [The ergogen v4 guid I used](https://flatfootfox.com/ergogen-introduction/) for a step by step tutorial.
- [A website that converts JS CAD to STL](https://neorama.de/) if you saw this but can't use nix.

## Licence

All files within this repository fall under a licence. See [LICENCE](./LICENSE) for more information.
