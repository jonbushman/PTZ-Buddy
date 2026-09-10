# PTZ Buddy bracket (3D-printable)

Five parts, parametric in `ptz_bracket.scad` (OpenSCAD, free): `base_plate`,
`pan_platform`, `tilt_wall`, `idler_wall`, `camera_plate`. STLs are in `stl/`,
preview renders in `renders/` (`assembly.png` shows how they go together -
it's a rough visualization only, not how the parts are oriented for
printing; each part is already modeled flat-on-the-bed for its own STL).

## Before you print anything

The dimensions in the `MEASURE ME` block at the top of `ptz_bracket.scad`
are typical for a DS3218-style 20kg standard-size digital servo and a 608
skate bearing, but real parts vary by +/-0.5mm between brands. Measure your
actual servos with calipers (case length/width/height, and how high the
output shaft sits above the case bottom - `shaft_z_offset`) and update the
constants before committing to a full print. Print just `base_plate` first
(smallest, fastest) and test-fit your servo in its cradle before printing
the rest.

To change a value and re-export, edit the constant and run, e.g.:

```
openscad -D 'part="tilt_wall"' -o stl/tilt_wall.stl ptz_bracket.scad
```

## How it goes together

- **base_plate**: sits on your tripod's quick-release plate. The QR
  plate's own screw threads up into a trapped 1/4"-20 hex nut underneath.
  The pan servo sits in a shallow locating fence on top (shaft pointing
  up) and is held down with two zip-ties routed through the slots on
  either side, over the servo's flange - this is deliberately tolerant of
  exact flange-hole spacing, which varies between servo brands.
- **pan_platform**: a disc that bolts to the pan servo's own round horn
  (through the horn's existing screw holes - `horn_bcd`/`horn_hole_count`
  need to match yours). It carries `tilt_wall` and `idler_wall`, bolted
  down near its edge with M3 self-tapping screws into the pilot holes,
  `axle_span` apart.
- **tilt_wall**: cradles the tilt servo the same way the base plate
  cradles the pan servo (snug pocket + zip-ties over the top), with the
  output shaft poking through a hole partway up, aimed at `camera_plate`.
- **idler_wall**: a passive support directly opposite the tilt servo. A
  608 bearing press-fits into its pocket; don't skip this side - a
  camcorder cantilevered off the servo shaft alone will sag and wobble
  over a multi-hour stream.
- **camera_plate**: the cradle that actually holds the camera. One end
  bolts to a horn on the tilt servo's shaft; the other end bolts to an M8
  bolt that passes through the idler bearing's inner race (the bearing's
  outer race stays pressed into `idler_wall`). The deck has a counterbored
  hole for a standard tripod mounting screw, which threads up into the
  camcorder's own threaded socket.

## Hardware you'll need per rig

- 2x 20kg standard-size digital servo (you already have these) + their
  stock round horns
- 1x 608 bearing (skateboard bearing, ~$2)
- 1x M8x20mm bolt + nut (idler axle)
- Small M3 self-tapping screws (mounting the walls to the pan platform)
- Small M2/M2.5 self-tapping screws (bolting the horns to pan_platform /
  camera_plate through the horn's own arm holes)
- 2-4 small zip ties
- 1x 1/4"-20 hex nut (base plate)
- A standard tripod quick-release plate (its screw becomes the base
  plate's mounting screw) and a standard 1/4"-20 tripod mounting screw
  for the camera_plate deck

## Print settings

- Material: PETG or ASA, not PLA - `tilt_wall`/`idler_wall`/`camera_plate`
  carry a cantilevered load for hours at a time and PLA creeps under
  sustained stress.
- Infill: 30-40% for `tilt_wall`, `idler_wall`, `camera_plate`; 20% is
  fine for `base_plate` and `pan_platform`.
- Orientation: all five parts are already modeled to print flat on the bed
  with no supports needed (open pockets/cavities face up).
- Test-fit `base_plate`'s servo cradle and the 1/4"-20 nut trap before
  printing everything else - if your nut or servo don't match the
  defaults, it's a 5-minute reprint instead of finding out after printing
  all five parts.
