// ============================================================
// PTZ Buddy - pan/tilt camera bracket (parametric OpenSCAD)
// ============================================================
// Five printed parts: base_plate, pan_platform, tilt_wall,
// idler_wall, camera_plate. See ../README.md for assembly,
// hardware (screws/bearing/servos), and print settings.
//
// *** MEASURE YOUR ACTUAL SERVOS AND BEARING WITH CALIPERS AND
// *** UPDATE THE "MEASURE ME" BLOCK BELOW BEFORE PRINTING.
// Defaults below are sized for a Deegoo-FPV MG995 (standard MG995/MG996R
// case footprint, 13kg-cm/6V) and a 608 skate bearing, but real parts
// vary by +/-0.5mm between brands - print a single wall or the base
// plate first and test-fit before committing a full print run.
// shaft_z_offset especially is an estimate (no verified dimensioned
// drawing was available) - measure yours before trusting it.

$fn = 48;

// ---------------- MEASURE ME ----------------
servo_body_l    = 40.7;  // servo case length, long axis (shaft end to back)
servo_body_w    = 19.7;  // servo case width
servo_body_h    = 42.9;  // servo case height (bottom of case to top, under horn)
shaft_z_offset  = 38.0;  // height of the output shaft centerline above the
                          // case bottom - estimated, not from a verified
                          // drawing. Most servos have it near the top, not
                          // centered - measure this one carefully.

horn_bcd        = 15.0;  // bolt circle diameter of the round horn's own screw holes.
                          // MG995 kits usually include a round horn with
                          // several concentric hole rings - measure the
                          // ring you plan to use and match its diameter here.
horn_hole_dia   = 2.4;   // diameter of those holes (for M2/M2.5 self-tap screws)
horn_hole_count = 4;
horn_boss_dia   = 9.0;   // clearance for the horn's center hub + screw head

bearing_od      = 22.0;  // 608 bearing outer diameter
bearing_id      = 8.0;   // 608 bearing bore -> also the idler axle bolt size (M8)
bearing_thick   = 7.0;

tripod_nut_af     = 11.4; // 1/4"-20 hex nut, across-flats + a bit of print clearance
tripod_nut_thick  = 6.5;
tripod_screw_dia  = 6.6;  // clearance for a 1/4" tripod screw shaft
tripod_head_dia   = 13.0; // typical tripod mounting screw head diameter
tripod_head_recess = 4.0;
// ---------------------------------------------

// ---------------- fit / build ----------------
clr        = 0.4;   // per-side clearance on body pockets
wall_t     = 3;     // shell thickness around a pocket
plate_t    = 6;     // flat structural plate thickness
base_t     = 9;     // base plate thickness (must clear tripod_nut_thick + roof)
zip_w      = 3.2;   // zip-tie slot width
axle_span  = 70;    // tilt-servo shaft to idler-shaft distance (world X)
yoke_h     = 45;    // height of the tilt/idler rotation axis above the
                     // pan-platform disc's top face
foot_l     = 22;    // wall bracket foot length (X)
foot_w     = servo_body_w + 2*clr + 2*wall_t + 6;  // foot width (Y)
pan_disc_d = axle_span + foot_l + 12;
pilot_dia  = 2.6;   // pilot hole for self-tapping M3 mounting screws
leg_h      = 26;    // camera_plate end-leg height (axis sits at leg_h/2)
leg_w      = horn_bcd + 14;
// ---------------------------------------------

part = "assembly"; // overridden from the command line for STL export:
                    // base_plate | pan_platform | tilt_wall | idler_wall | camera_plate

module horn_bolt_pattern(bcd, count) {
    for (i = [0:count-1])
        rotate([0,0, i*360/count])
            translate([bcd/2, 0, 0])
                children();
}

module hex_prism(af, h) {
    r = af / cos(30) / 2;
    cylinder(r = r, h = h, $fn = 6);
}

// Cut from a face at local z=0, growing in +z: hex pocket for a 1/4"-20
// nut, then a narrower clearance hole continuing up for the screw's tip.
module tripod_nut_trap() {
    translate([0,0,-0.01]) hex_prism(tripod_nut_af, tripod_nut_thick + 0.01);
    translate([0,0, tripod_nut_thick - 0.01]) cylinder(d = tripod_screw_dia, h = 50);
}

// Cut from the bottom face (local z=0) upward: a counterbore for a
// standard tripod mounting screw's head, then a narrower clearance hole
// continuing up so the screw's threads reach a threaded socket above.
// (Unlike tripod_nut_trap, we're not supplying the female thread here -
// whatever's on top already has one: a camcorder's own tripod socket,
// or - for an action cam with no socket of its own, like an Osmo Action -
// a cheap GoPro-mount-to-1/4"-20 adapter clipped to its quick-release mount.)
module tripod_screw_counterbore() {
    translate([0,0,-0.01]) cylinder(d = tripod_head_dia, h = tripod_head_recess + 0.01);
    translate([0,0, tripod_head_recess - 0.01]) cylinder(d = tripod_screw_dia, h = 50);
}

// A horn mount: center clearance hole + bolt-circle holes, cut through
// a plate of thickness h starting at local z=0.
module horn_mount_holes(h) {
    translate([0,0,-0.1]) cylinder(d = horn_boss_dia, h = h + 0.2);
    horn_bolt_pattern(horn_bcd, horn_hole_count)
        translate([0,0,-0.1]) cylinder(d = horn_hole_dia, h = h + 0.2);
}

// ---------------- base_plate ----------------
// Sits on the tripod's quick-release plate (its screw threads up into the
// trapped nut here). The pan servo sits on TOP of this plate (its shaft
// points straight up into the pan_platform's horn) inside a shallow
// locating fence, held down by two zip-ties routed through slots.
module base_plate() {
    sl = servo_body_l + 2*clr;
    sw = servo_body_w + 2*clr;
    plate_l = sl + 2*wall_t + 14;
    plate_w = sw + 2*wall_t + 28;
    tripod_x = plate_l/2 - tripod_nut_af/2 - 8;
    fence_h = 2.5;

    difference() {
        union() {
            cube([plate_l, plate_w, base_t], center = true);
            translate([0,0, base_t/2])
                difference() {
                    cube([sl + 2*wall_t, sw + 2*wall_t, fence_h], center = true);
                    translate([0,0,0.1]) cube([sl, sw, fence_h + 0.2], center = true);
                }
        }

        translate([tripod_x, 0, -base_t/2 - 0.01]) tripod_nut_trap();

        for (x = [-sl/2 - wall_t/2, sl/2 + wall_t/2])
            translate([x, 0, 0]) cube([zip_w, sw + 10, base_t + fence_h + 1], center = true);
    }
}

// ---------------- pan_platform ----------------
// Disc bolted to the pan servo's own round horn; carries the tilt_wall
// and idler_wall L-brackets bolted near its edge, axle_span apart.
module pan_platform() {
    difference() {
        cylinder(d = pan_disc_d, h = plate_t);
        horn_mount_holes(plate_t);
        for (side = [-1, 1])
            translate([side * axle_span/2, 0, 0])
                for (y = [-foot_w/2 + 5, foot_w/2 - 5])
                    translate([0, y, -0.1]) cylinder(d = pilot_dia, h = plate_t + 0.2);
    }
}

// ---------------- L-bracket foot (shared) ----------------
module l_bracket_foot() {
    difference() {
        cube([foot_l, foot_w, plate_t], center = true);
        for (y = [-foot_w/2 + 5, foot_w/2 - 5])
            translate([0, y, -0.1]) cylinder(d = pilot_dia, h = plate_t + 0.2);
    }
}

// ---------------- tilt_wall ----------------
// Foot at z=[-plate_t/2, plate_t/2] (bolts to pan_platform). A box rises
// above it cradling the tilt servo; the servo's shaft hole (and thus the
// tilt rotation axis) lands at world z = plate_t/2 + yoke_h, pointing
// along +Y toward where the camera_plate attaches.
module tilt_wall() {
    box_w = servo_body_w + 2*clr + 2*wall_t;
    box_l = servo_body_l + 2*clr + 2*wall_t;
    box_h = servo_body_h + 2*clr + wall_t;
    // z of the servo cavity's floor (world, foot top = plate_t/2)
    box_z0 = plate_t/2 + yoke_h - shaft_z_offset - wall_t/2;
    // one continuous solid from the foot top up through the cradle, so
    // there's no floating gap between the foot and the servo box
    solid_h = box_z0 + box_h - plate_t/2;

    union() {
        l_bracket_foot();
        translate([0,0, plate_t/2])
            difference() {
                translate([0,0, solid_h/2]) cube([box_l, box_w, solid_h], center = true);

                // servo body cavity, open top
                translate([0,0, (box_z0 - plate_t/2) + wall_t + (servo_body_h + 2*clr)/2])
                    cube([servo_body_l + 2*clr, servo_body_w + 2*clr, servo_body_h + 2*clr + 1], center = true);

                // shaft clearance, exits the +Y face toward the camera_plate
                translate([0, box_w/2 - wall_t - 0.1, (box_z0 - plate_t/2) + wall_t + shaft_z_offset])
                    rotate([-90,0,0]) cylinder(d = 10, h = wall_t + 0.3);

                // zip-tie slots across the open top, front-to-back
                for (x = [-box_l/2 + 7, box_l/2 - 7])
                    translate([x, 0, solid_h - 0.1]) cube([zip_w, box_w + 6, 4], center = true);
            }
    }
}

// ---------------- idler_wall ----------------
// Same footprint as tilt_wall but carries a 608 bearing instead of a
// servo. The bearing's bore axis lands at the same world z as the tilt
// servo's shaft, also pointing along +Y, so the two are coaxial.
module idler_wall() {
    boss_d = bearing_od + 2*wall_t;
    boss_l = bearing_thick + wall_t;
    axis_z = plate_t/2 + yoke_h; // world height of the bearing bore axis
    riser_h = axis_z - plate_t/2; // reaches to the axis, so it overlaps the
                                  // boss cylinder's lower half - a real join,
                                  // not just a touching edge

    union() {
        l_bracket_foot();
        translate([0,0, plate_t/2]) cylinder(d = boss_d, h = riser_h);
        translate([0, 0, axis_z])
            rotate([-90,0,0])
            difference() {
                translate([0,0, boss_l/2]) cylinder(d = boss_d, h = boss_l, center = true);
                // bearing press-fits in from the -Y (outer) face
                translate([0,0,-0.1]) cylinder(d = bearing_od + clr, h = bearing_thick + 0.1);
                // through-bore for the M8 axle bolt
                translate([0,0,-0.1]) cylinder(d = bearing_id + 4, h = boss_l + 0.2);
            }
    }
}

// ---------------- camera_plate ----------------
// A cradle: two vertical legs (bolt to the tilt horn / idler bearing
// along Y) joined by a horizontal deck. A standard tripod mounting screw
// passes up through the deck's counterbore into whatever's sitting on
// top - see tripod_screw_counterbore() above.
module camera_plate() {
    deck_w = leg_w;
    deck_l = axle_span + leg_w;
    axis_z = leg_h/2;

    union() {
        // deck
        translate([0, 0, leg_h])
            difference() {
                translate([0,0,plate_t/2]) cube([deck_l, deck_w, plate_t], center = true);
                translate([0, 0, -0.01]) tripod_screw_counterbore();
            }

        // tilt-horn leg
        translate([-axle_span/2, 0, 0])
            difference() {
                translate([0,0,leg_h/2]) cube([leg_w, plate_t, leg_h], center = true);
                translate([0, -plate_t/2 - 0.1, axis_z]) rotate([-90,0,0]) horn_mount_holes(plate_t + 0.2);
            }

        // idler leg
        translate([axle_span/2, 0, 0])
            difference() {
                translate([0,0,leg_h/2]) cube([leg_w, plate_t, leg_h], center = true);
                translate([0,0,axis_z]) rotate([-90,0,0]) {
                    translate([0,0,-0.1]) cylinder(d = bearing_id + 0.5, h = plate_t + 0.2);
                    translate([0,0, plate_t - 4]) cylinder(d = 14, h = 4.1);
                }
            }
    }
}

if (part == "base_plate") base_plate();
else if (part == "pan_platform") pan_platform();
else if (part == "tilt_wall") tilt_wall();
else if (part == "idler_wall") idler_wall();
else if (part == "camera_plate") camera_plate();
else {
    // Assembly preview only - approximate, NOT how parts are oriented
    // for printing (each part prints flat; see the per-part renders).
    color("SlateGray") translate([0,0,base_t/2]) base_plate();
    translate([0,0, base_t + plate_t/2]) {
        color("SteelBlue") pan_platform();
        translate([-axle_span/2, 0, plate_t/2]) color("IndianRed") tilt_wall();
        translate([axle_span/2, 0, plate_t/2]) color("IndianRed") idler_wall();
        translate([0, 0, yoke_h]) color("Goldenrod") camera_plate();
    }
}
