globals [means-total]
breed [sites site]
breed [quads quad]
breed [rquads rquad]
breed [squads squad]
patches-own [qt]
quads-own [artefacts]
rquads-own [artefacts]
squads-own [artefacts]
sites-own [xq xr xs]

to setup
  clear-all
  reset-ticks
  set-default-shape sites "circle"
  set-default-shape quads "square 3"
  set-default-shape rquads "square"
  set-default-shape squads "square"
  set means-total []
  ask patches [set pcolor 59]
  ask n-of 500 patches [set pcolor 49]
  ask n-of 500 patches [set pcolor 39]
  ask n-of 500 patches [set pcolor 29]
  ask n-of qt-sites patches [sprout-sites 1 [set color [0 0 0 0]]]
  ask sites [
    move-to one-of patches with [not any? other sites in-radius 5]
  ]
  ask patches [if any? sites-here [set qt random 10]]
  repeat ds-sites / 10 [scatter]
end

to scatter
  diffuse qt 0.5
end

to pit
  if mouse-down? [ask patch mouse-xcor mouse-ycor [ ifelse any? quads-here [] [ sprout-quads 1  [set color black]]]]
  dig
end

to dig
  ask quads [ set artefacts [qt] of patch-here ]
  ask patches [ if any? quads-here [set pcolor scale-color white qt 1 0]]
end

to extend
  if mouse-down? [
    ask patch mouse-xcor mouse-ycor [ if any? quads-here [ask neighbors [if not any? quads-here [ sprout-quads 1 [set color black]]]]]
    ask quads [ set color white ]
  ]
  dig
end

to reveal
  ask quads [set color white]
  ask rquads [set color blue]
  ask squads [set color green]
  ask patches [set pcolor [255 255 255]]
  ask patches with [qt > 0] [set pcolor scale-color white qt 1 0]
end

to compare
  ask rquads [die]
  let n count quads
  ask n-of n patches [sprout-rquads 1 [set color [0 0 0 0]]]
  ask rquads [set artefacts [qt] of patch-here ]
  squads-burn
  monitor-out
end

to squads-burn
  ask squads [die]
; get the intervals
  let h-int world-width / floor (sqrt count quads)
  let v-int world-height / floor (sqrt count quads)
; Get a range of horizontal and vertical coordinates, starting at half
; of the interval value from the minimum x coordinate
let h-vals ( range (min-pxcor + h-int / 2) max-pxcor h-int )
let v-vals ( range (min-pycor + v-int / 2) max-pycor v-int )
; Create an empty list to build into
let possible-coords []
; For each possible vertical value, map all horizontal values in order and
; combine these into an ordered list starting at the lowest px and py coords
foreach v-vals [
v ->
set possible-coords ( sentence possible-coords map [ i -> (list i v) ] h-vals )
]
  let use-coords sublist possible-coords 0 (floor (sqrt count quads) ^ 2)
foreach use-coords [
coords ->
create-squads 1 [
setxy item 0 coords item 1 coords
      set color [0 0 0 0]
]
]
  ask squads [set artefacts [qt] of patch-here]
end

to monitor-out
  ask sites [set xq 0]
  ask sites [set xr 0]
  ask sites [set xs 0]
  ask sites [if any? quads in-radius (ds-sites / 10) [set xq xq + 1]]
  ask sites [if any? rquads in-radius (ds-sites / 10) [set xr xr + 1]]
  ask sites [if any? squads in-radius (ds-sites / 10) [set xs xs + 1]]
end
@#$#@#$#@
GRAPHICS-WINDOW
212
10
753
552
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-20
20
-20
20
0
0
1
ticks
30.0

BUTTON
759
10
1135
43
Build the world
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
758
328
916
373
World total artefacts
sum [qt] of patches
2
1
11

MONITOR
758
375
916
420
% archaeologist
sum [artefacts] of quads / sum [qt] of patches * 100
2
1
11

MONITOR
920
422
1002
467
Quads
count rquads
1
1
11

MONITOR
920
470
1002
515
Quads
count squads
1
1
11

MONITOR
920
375
1002
420
Quads
count quads
1
1
11

BUTTON
758
519
1134
552
Reveal the map
reveal
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
759
48
931
81
qt-sites
qt-sites
1
20
20.0
1
1
NIL
HORIZONTAL

SLIDER
963
48
1135
81
ds-sites
ds-sites
0
100
30.0
10
1
%
HORIZONTAL

BUTTON
758
279
1134
324
Compare methods
compare
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
758
422
916
467
% random
sum [artefacts] of rquads / sum [qt] of patches * 100
2
1
11

MONITOR
758
470
916
515
% systematic
sum [artefacts] of squads / sum [qt] of patches * 100
2
1
11

MONITOR
920
328
1046
373
World density (%)
count patches with [qt > 0] / count patches * 100
2
1
11

MONITOR
1005
375
1094
420
Sites found
sum [xq] of sites
17
1
11

MONITOR
1005
422
1093
467
Sites found
sum [xr] of sites
17
1
11

MONITOR
1005
470
1093
515
Sites found
sum [xs] of sites
17
1
11

BUTTON
758
95
1135
156
Go excavate!
pit
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
766
176
1129
251
When going excavate, point-and-click locations you wish to excavate. You can keep your mouse down to create trenches and/or other shapes.\n\nWhen you're satisfied, look at the results below.
12
0.0
1

@#$#@#$#@
## WHAT IS IT?

Archaeology Sampling Methods is designed for students and people interested in archaeological field methods. It proposes to study basic field methods and behaviors and to illustrate how they impact on an excavation process.

## HOW IT WORKS

In this model, a number of sites is randomly created in an empty landscape. Each site then receives a random number of artefacts that are evenly scattered around. The archaeologist can then select two different methods to prospect the area: single pits and/or trenches. The result of the excavation can then be compared to other methods, ie random and systematic sampling.

## HOW TO USE IT

First, create a landscape by clicking Build the world: the number of sites and their density are defined by the two sliders (0% being highly concentrated and 100% fully dispersed). Note that the sites will remain hidden until you hit the Reveal the map button.

Second, Go excavate! To do so, point-and-click your mouse to a chosen location on the world. You can point-and-click multiple times at various location, or you can point-and-keep-the-mouse-down to create trenches and/or other shapes.

Finally, click Compare methods, and look at the results.

## THINGS TO NOTICE

Three different methods are compared. The monitors first show, for each method, the percentage of artefacts recovered. Second, they also show the number of individual sites found. Is any method more efficient than the others? In what respect?

Revealing the map will show the location of the tests: the one manually adopted by the archaeologist (red), random sampling, when pit locations are selected randomly (blue), and systematic sampling, when pit locations are grided (green).

## THINGS TO TRY

- How does the number of sites affect the result?
- How does the dispersion of artefacts affect the results? 
- For an example, how do trenches work on an area where sites are highly concentrated?
- Is it possible to find a high percentage of artefacts but low number of sites?

## EXTENDING THE MODEL

In the next version:
- two players.

## NETLOGO FEATURES

Nope

## RELATED MODELS

## CREDITS AND REFERENCES

https://github.com/gvanhavre/ArcheoBM
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 3
false
0
Rectangle -2674135 false false 30 30 270 270

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
