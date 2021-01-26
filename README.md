# Catstagram

The purpose of this training is to practice The Elm Architecture (TEA) with [ocaml-vdom](https://github.com/LexiFi/ocaml-vdom)

> 📌 This training is incremental, each exercise is a step to the solution. You only need to push the result of the last exercice (or the latest you succeed to do). It will be part of your evaluation.

This training is using js_of_ocaml to compile OCaml to Javascript. The generated asset is simply loaded by [./public/index.html](./public/index.html).

To run the project:
- `esy install`
- `esy build`
- `esy start` _(no hotreload setup so don't forget to refresh after each compilation)_
- open the javascript console

This training have two parts:
1. [Meet TEA](./doc/part1.md)
2. [Create your catstagram](./doc/part2.md)