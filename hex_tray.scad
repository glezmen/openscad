/*
 Parametric hexagon tray
 Designer by Norbert Bokor (glezmen@gmail.com)
*/

// mm
outer_width = 180;
// mm
outer_length = 180;
// mm, without bottom
inner_height = 44;

// solid, not grid
solid_bottom = false;
// matches style of bottom
generate_lid = false;

// diameter in mm
hexagon_size = 10;
// mm
hexagon_spacing = 1;

// mm
wall_thickness = 2;
// mm
bottom_thickness = 2;

//-----------------
/* [Front cutout] */ 

// mm
front_cutout_width = 60;
// mm
front_cutout_height = 30;
// fillet radius in mm
front_cutout_fillet = 10;

//-----------------
/* [Label] */ 

label_position = "top left"; // [top left: top right:bottom left:bottom right:bottom center:center:under cutout]
// mm
label_width = 50;
// mm
label_height = 30;
// use | as line separator, || for empty line
label_text = "Sample|multiline text||here";
// letter height in mm
label_text_size = 4;

include <BOSL2/std.scad>

hex_radius = hexagon_size / 2;
hex_width = sqrt(3) * hex_radius;
raster_spacing = hex_width + hexagon_spacing;

module hexagon_cutout() {
        circle(hex_radius, $fn=6);
}
 
module hex_grid(size_x, size_y, solid = false) {
    difference(){
        square([size_x, size_y]);
        
        if (!solid) {
            for (x = [-hex_radius : raster_spacing - 1 : size_x + hex_radius]) {
                for (y = [-hex_radius : raster_spacing : size_y + hex_radius]) {
                    translate(
                        [x,
                        y + (((x / raster_spacing) % 2) * raster_spacing / 2)])
                        hexagon_cutout();
                }
            }
        }
    }
    
    difference() {
        square([size_x, size_y]);
        
        translate([wall_thickness, wall_thickness])
        square([size_x - wall_thickness * 2, size_y - wall_thickness * 2]);
    }
}

module hex_panel(size_x, size_y, thickness, solid = false) {
    linear_extrude(thickness)
    hex_grid(size_x, size_y, solid);
}

module corner(p1, p2, p3, height) {
    linear_extrude(height)
    polygon([
        p1, p2, p3, p1
    ]);
}

module corners(size, height) {
    corner([0, 0], [0, 2 * size], [2 * size, 0], height);
    corner([outer_width, 0], [outer_width, 2 * size], [outer_width - 2 * size, 0], height);
    corner([0, outer_length], [0, outer_length - 2 * size], [2 * size, outer_length], height);
    corner([outer_width, outer_length], [outer_width, outer_length - 2 * size], [outer_width - 2 * size, outer_length], height);
}

module front_cutout(shrink = 0) {
    biw = bottom_thickness + inner_height;
    radius = front_cutout_fillet - shrink;
    height = front_cutout_height - shrink;
    width = front_cutout_width - shrink * 2;

    w1h = height - radius;
    w2h = height;
    
    rotate([90, 0, 0]) {
        translate([
            outer_width / 2 - width / 2  + radius,
            biw - height + radius,
            -wall_thickness / 2])
        cylinder(h = wall_thickness, r = radius, center = true, $fn = 100);

        translate([
            outer_width / 2 + width / 2 - radius,
            biw - height + radius,
            -wall_thickness / 2])
        cylinder(h = wall_thickness, r = radius, center = true, $fn = 100);
        
        translate([
            outer_width / 2,
            biw - w1h / 2,
            -wall_thickness / 2])
        cube([
            width,
            w1h ,
            wall_thickness],
            center = true);

        translate([
            outer_width / 2,
            biw - w2h / 2,
            -wall_thickness / 2])
        cube([
            width - 2 * radius,
            w2h,
            wall_thickness],
            center = true);

    }
}

module sp(r) {
    sphere(r, $fn = 100);
}

module hold_pins() {
    union() {
    sp(wall_thickness);

    translate([outer_width, 0, 0])
    sp(wall_thickness);

    translate([0, outer_length, 0])
    sp(wall_thickness);

    translate([outer_width, outer_length, 0])
    sp(wall_thickness); 
    }
}

module hex_box() {
    difference() {
        union() {
            hex_panel(outer_width, outer_length, bottom_thickness, solid_bottom);

            translate([0, wall_thickness, bottom_thickness])
            rotate([90, 0, 0])
            hex_panel(outer_width, inner_height, wall_thickness);

            translate([0, outer_length, bottom_thickness])    
            rotate([90, 0, 0])
            hex_panel(outer_width, inner_height, wall_thickness);

            translate([wall_thickness, 0, bottom_thickness])
            rotate([0, -90, 0])
            hex_panel(inner_height, outer_length, wall_thickness);

            translate([outer_width, 0, bottom_thickness])
            rotate([0, -90, 0])
            hex_panel(inner_height, outer_length, wall_thickness);

            linear_extrude(bottom_thickness)
            difference() {
                square([outer_width, outer_length]);
                
                translate([wall_thickness * 2, wall_thickness * 2])
                square([outer_width - wall_thickness * 4, outer_length - wall_thickness * 4]);
            }
        }

        hold_pins();
    }

    top = inner_height + bottom_thickness;
    w = wall_thickness / 2;
    gap = 0.2;
    
    union() {
        intersection() {
            translate([w, w, top + w])
            cube(wall_thickness, center = true);

            translate([0, 0, top])
            sp(wall_thickness - gap);
        }

        intersection() {
            translate([outer_width - w, w, top + w])
            cube(wall_thickness, center = true);

            translate([outer_width, 0, top])
            sp(wall_thickness - gap);
        }

        intersection() {
            translate([w, outer_length - w, top + w])
            cube(wall_thickness, center = true);

            translate([0, outer_length, top])
            sp(wall_thickness - gap);
        }

        intersection() {
            translate([outer_width - w, outer_length - w, top + w])
            cube(wall_thickness, center = true);

            translate([outer_width, outer_length, top])
            sp(wall_thickness - gap);
        }
    }
}

module label() {
    xl = (outer_width - front_cutout_width) / 4;
    xr = outer_width - (outer_width - front_cutout_width) / 4;
    yt = bottom_thickness + inner_height - label_height / 2;
    yb = bottom_thickness + label_height / 2 + wall_thickness;

    pos = [
        ["top left", xl, yt],
        ["top right", xr, yt],    
        ["bottom left", xl, yb],
        ["bottom right", xr, yb],
        ["bottom center", (xl + xr) / 2, yb],
        ["center", (xl + xr) / 2, bottom_thickness + (inner_height - front_cutout_height) / 2],
        ["under cutout",
            (xl + xr) / 2,
            bottom_thickness + inner_height + wall_thickness - front_cutout_height - label_height / 2],
    ];

    idx = search([label_position], pos)[0];
    cposx = pos[idx][1];
    cposy = pos[idx][2];

    rotate([90, 0, 0])
    translate([cposx - label_width / 2 , cposy - label_height / 2, -wall_thickness]) {
        hex_panel(label_width, label_height, wall_thickness, true);

        result = [];
        lines = str_split(label_text, "|");
        for (i = [0 : len(lines)-1]) {
            color("red")
            translate([label_text_size, label_height - (i+1) * label_text_size * 1.5, wall_thickness / 2])
            linear_extrude(wall_thickness * 0.75)
            text(lines[i], size=label_text_size, font="DejaVu Sans");   
        }
    }
}

translate([-outer_width / 2, -outer_length / 2, 0]) {
    difference() {
        hex_box();
        
        front_cutout();
    }
    
    difference() {
        front_cutout();
        
        front_cutout(wall_thickness);
    }

    if (generate_lid) {
        translate([outer_width + 10, 0, 0])
        difference() {
            hex_panel(outer_width, outer_length, bottom_thickness, solid_bottom);

            hold_pins();
        }
    }

    label();
}

