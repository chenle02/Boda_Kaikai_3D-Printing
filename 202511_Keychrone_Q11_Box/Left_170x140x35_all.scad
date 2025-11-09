//
// Parametric enclosure with outer (overlap) lid
// Author: ChatGPT
//
// How to use in OpenSCAD:
// 1) Set part = "bottom" or "lid" below.
// 2) Press F6 (Render) then File -> Export -> STL.
//
// Dimensions per user's spec:
// - Inner cavity (usable): 170 x 140 x 35 mm
// - Horizontal (top & bottom) walls: 8 mm
// - Side walls (both bottom and lid skirt): 5 mm
// - Lid style: outer slip-over cap
// - Clearance: 0.3 mm per side (total +0.6 mm in X and Y)
// - Lid overlap (skirt depth): 12 mm
//
// Derived (do not edit unless you know what you're doing):
// - Bottom outer: 180 x 150 x 43 mm
// - Lid inner: 180.6 x 150.6 x 12 mm
// - Lid outer: 190.6 x 160.6 x 20 mm
//

// ---------------- Parameters ----------------
part = "bottom"; // "bottom" or "lid"
orient_lid_for_print = true; // if true, flip lid so top faces bed

inner_x = 170;
inner_y = 140;
inner_z = 35;

side_wall = 5;                // side wall thickness (bottom & lid skirt)
top_bottom_thick = 8;         // thickness of top & bottom plates
clearance = 0.3;              // per side (total +0.6 in X/Y)
lid_overlap = 12;             // skirt depth

// ---------------- Derived sizes ----------------
outer_x = inner_x + 2*side_wall;
outer_y = inner_y + 2*side_wall;
outer_z = inner_z + top_bottom_thick;

// Lid internal size (to slide over bottom outer, with clearance each side)
lid_inner_x = outer_x + 2*clearance;
lid_inner_y = outer_y + 2*clearance;
lid_inner_z = lid_overlap;

// Lid external box
lid_outer_x = lid_inner_x + 2*side_wall;
lid_outer_y = lid_inner_y + 2*side_wall;
lid_outer_z = top_bottom_thick + lid_overlap;

// ---------------- Modules ----------------
module bottom_box(){
    // Outer solid
    difference(){
        cube([outer_x, outer_y, outer_z], center=false);
        // Inner cavity: inset by side_wall on X/Y and offset up by top_bottom_thick
        translate([side_wall, side_wall, top_bottom_thick])
            cube([inner_x, inner_y, inner_z], center=false);
    }
}

module lid_outer(){
    difference(){
        cube([lid_outer_x, lid_outer_y, lid_outer_z], center=false);
        // Inner cut for the skirt: leaves an 8 mm top, skirt depth = lid_overlap
        translate([side_wall, side_wall, 0])
            cube([lid_inner_x, lid_inner_y, lid_inner_z], center=false);
    }
}

// ---------------- Output ----------------
if (part == "bottom"){
    bottom_box();
} else if (part == "lid"){
    // Flip so the solid top faces the build plate to avoid supports
    if (orient_lid_for_print) {
        translate([0,0,lid_outer_z])
            rotate([180,0,0]) lid_outer();
    } else {
        lid_outer();
    }
} else {
    // Show both for preview (offset the lid for visibility)
    bottom_box();
    translate([0, outer_y + 10, 0]) lid_outer();
}
