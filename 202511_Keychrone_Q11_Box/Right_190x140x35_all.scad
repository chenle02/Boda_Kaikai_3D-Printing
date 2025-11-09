//
// Parametric enclosure with outer (overlap) lid — 190 x 140 x 35 inner
// Author: ChatGPT
//
// Use: set part = "bottom" or "lid", Render (F6), then File -> Export -> STL.
//
// ---------------- Parameters ----------------
part = "bottom"; // "bottom" or "lid"

inner_x = 195;
inner_y = 140;
inner_z = 35;

side_wall = 5;       // side wall thickness (bottom & lid skirt)
top_bottom_thick = 8; // top/bottom plate thickness
clearance = 0.3;       // per side clearance for lid fit
lid_overlap = 12;   // skirt depth

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
    difference(){
        cube([outer_x, outer_y, outer_z], center=false);
        translate([side_wall, side_wall, top_bottom_thick])
            cube([inner_x, inner_y, inner_z], center=false);
    }
}

module lid_outer(){
    difference(){
        cube([lid_outer_x, lid_outer_y, lid_outer_z], center=false);
        translate([side_wall, side_wall, 0])
            cube([lid_inner_x, lid_inner_y, lid_inner_z], center=false);
    }
}

// ---------------- Output ----------------
if (part == "bottom"){
    bottom_box();
} else if (part == "lid"){
    lid_outer();
} else {
    bottom_box();
    translate([0, outer_y + 10, 0]) lid_outer();
}
