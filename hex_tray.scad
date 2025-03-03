/*
 Parametric hexagon tray
 Designer by Norbert Bokor (glezmen@gmail.com)
*/

outer_width = 180;
outer_length = 180;
inner_height = 44;

solid_bottom = true;
lid = true;

hexagon_size = 10;
hexagon_spacing = 1;

wall_thickness = 2;
bottom_thickness = 2;

front_cutout_width = 60;
front_cutout_height = 30;
front_cutout_fillet = 10;

sign_plate_right_side = false;
sign_plate_width = 50;
sign_plate_height = 30;

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

module sign_plate() {
    cposx =
        sign_plate_right_side
        ? outer_width - (outer_width - front_cutout_width) / 4
        : (outer_width - front_cutout_width) / 4;

    cposy = bottom_thickness + inner_height - sign_plate_height / 2;

    rotate([90, 0, 0])
    translate([cposx - sign_plate_width / 2 , cposy - sign_plate_height / 2, -wall_thickness])
    hex_panel(sign_plate_width, sign_plate_height, wall_thickness, true);
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

    if (lid) {
        translate([outer_width + 10, 0, 0])
        difference() {
            hex_panel(outer_width, outer_length, bottom_thickness, solid_bottom);

            hold_pins();
        }
    }

    sign_plate();
}
