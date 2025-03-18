#import "@local/catppuccin:1.0.0": catppuccin, flavors
#import "@preview/touying:0.6.1": *
#import "@preview/cetz:0.3.4"
#import "@preview/fletcher:0.5.7"
#import themes.simple: *

#let cetz-canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)
#let fletcher-diagram = touying-reducer.with(
  reduce: fletcher.diagram,
  cover: fletcher.hide,
)

#show: simple-theme.with(aspect-ratio: "16-9", footer: [Ben C])
#show: catppuccin.with(flavors.mocha, code-block: true, code-syntax: true)

= Git From Scratch

_A bottom-up approach to learning Git_
