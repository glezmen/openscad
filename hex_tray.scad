/*
 Parametric hexagon tray
 Designer by Norbert Bokor (glezmen@gmail.com)
*/

outer_width = 180;
outer_length = 180;
inner_height = 44;
solid_bottom = true;
hexagon_size = 10;
hexagon_spacing = 1;
wall_thickness = 2;
bottom_thickness = 2;
front_cutout_width = 120;
front_cutout_height = 30;
front_cutout_fillet = 10;

hex_radius = hexagon_size / 2;
hex_width = sqrt(3) * hex_radius;
raster_spacing = hex_width + hexagon_spacing;
x_size = outer_width;
y_size = outer_length;

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
    corner([x_size, 0], [x_size, 2 * size], [x_size - 2 * size, 0], height);
    corner([0, y_size], [0, y_size - 2 * size], [2 * size, y_size], height);
    corner([x_size, y_size], [x_size, y_size - 2 * size], [x_size - 2 * size, y_size], height);
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
            x_size / 2 - width / 2  + radius,
            biw - height + radius,
            -wall_thickness / 2])
        cylinder(h = wall_thickness, r = radius, center = true, $fn = 100);

        translate([
            x_size / 2 + width / 2 - radius,
            biw - height + radius,
            -wall_thickness / 2])
        cylinder(h = wall_thickness, r = radius, center = true, $fn = 100);
        
        translate([
            x_size / 2,
            biw - w1h / 2,
            -wall_thickness / 2])
        cube([
            width,
            w1h ,
            wall_thickness],
            center = true);

        translate([
            x_size / 2,
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

module hex_box() {
    difference() {
        union() {
            hex_panel(x_size, y_size, bottom_thickness, solid_bottom);

            translate([0, wall_thickness, bottom_thickness])
            rotate([90, 0, 0])
            hex_panel(x_size, inner_height, wall_thickness);

            translate([0, y_size, bottom_thickness])    
            rotate([90, 0, 0])
            hex_panel(x_size, inner_height, wall_thickness);

            translate([wall_thickness, 0, bottom_thickness])
            rotate([0, -90, 0])
            hex_panel(inner_height, y_size, wall_thickness);

            translate([x_size, 0, bottom_thickness])
            rotate([0, -90, 0])
            hex_panel(inner_height, y_size, wall_thickness);

            linear_extrude(bottom_thickness)
            difference() {
                square([x_size, y_size]);
                
                translate([wall_thickness * 2, wall_thickness * 2])
                square([x_size - wall_thickness * 4, y_size - wall_thickness * 4]);
            }
        }

        union() {
            sp(wall_thickness);

            translate([x_size, 0, 0])
            sp(wall_thickness);

            translate([0, y_size, 0])
            sp(wall_thickness);

            translate([x_size, y_size, 0])
            sp(wall_thickness);            
        }
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
            translate([x_size - w, w, top + w])
            cube(wall_thickness, center = true);

            translate([x_size, 0, top])
            sp(wall_thickness - gap);
        }

        intersection() {
            translate([w, y_size - w, top + w])
            cube(wall_thickness, center = true);

            translate([0, y_size, top])
            sp(wall_thickness - gap);
        }

        intersection() {
            translate([x_size - w, y_size - w, top + w])
            cube(wall_thickness, center = true);

            translate([x_size, y_size, top])
            sp(wall_thickness - gap);
        }
    }
}

translate([-x_size / 2, -y_size / 2, 0]) {
    difference() {
        hex_box();
        
        front_cutout();
    }
    
    difference() {
        front_cutout();
        
        front_cutout(wall_thickness);
    }
}
