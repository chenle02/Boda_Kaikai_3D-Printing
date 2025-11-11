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

// Engraved text settings (concave when flipped)
lid_text = "";                 // legacy single-line (centered) text; empty disables
lid_text_depth = 1.2;          // mm depth of engraving (<= top_bottom_thick)
lid_text_size = 18;            // legacy single-line size
lid_text_font = "Liberation Sans:style=Bold"; // installed font name
lid_text_offset = [0, 0];      // XY offset for legacy single-line (mm)

// Centered title (first line)
center_title_text = "Keychron Q11 (Left)";
center_title_size = 12;        // slightly smaller than previous 18
center_title_offset = [0, 0];  // XY offset from lid center (mm)

// Bottom-right info (last two lines)
corner_info_lines = ["chenle02@gmail.com", "2025-11"];
corner_info_size = 6;          // much smaller
corner_info_margin = [5, 5];   // [x,y] margin from bottom-right edges (mm)
corner_info_line_spacing = 1.1; // spacing multiplier between lines

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
        // Optional engraved text on the outer top surface
        lid_text_cut();
    }
}

// 3D volume to subtract for engraving text on the lid's top
module lid_text_cut(){
    depth = lid_text_depth > top_bottom_thick ? top_bottom_thick : lid_text_depth;

    // 1) Centered title
    if (center_title_text != ""){
        translate([ lid_outer_x/2 + center_title_offset[0],
                    lid_outer_y/2 + center_title_offset[1],
                    lid_outer_z - depth + 0.01 ])
            linear_extrude(height = depth + 0.02)
                text(center_title_text, size=center_title_size, font=lid_text_font,
                     halign="center", valign="center");
    }

    // 2) Bottom-right info lines (stack upward; last line closest to corner)
    if (len(corner_info_lines) > 0){
        for (i = [0 : len(corner_info_lines)-1]){
            line_index_from_bottom = len(corner_info_lines)-1 - i;
            yoff = corner_info_margin[1] + line_index_from_bottom * corner_info_size * corner_info_line_spacing;
            translate([ lid_outer_x - corner_info_margin[0], yoff, lid_outer_z - depth + 0.01 ])
                linear_extrude(height = depth + 0.02)
                    text(corner_info_lines[i], size=corner_info_size, font=lid_text_font,
                         halign="right", valign="bottom");
        }
    }

    // 3) Fallback: legacy single-line centered text
    if (center_title_text == "" && len(corner_info_lines) == 0 && lid_text != ""){
        translate([ lid_outer_x/2 + lid_text_offset[0],
                    lid_outer_y/2 + lid_text_offset[1],
                    lid_outer_z - depth + 0.01 ])
            linear_extrude(height = depth + 0.02)
                text(lid_text, size=lid_text_size, font=lid_text_font,
                     halign="center", valign="center");
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
