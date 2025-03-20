// number of tubes
tube_count = 4;
inner_diameter = 55;
// thickness of tube wall
wall_thickness = 2;
// total tube lenght in mm
height = 180;
// hole size in mm
square_size = 8;
// grid thickness in mm
grid_thickness = 2;
// screw hole diameter in mm
screw_size = 5;
// width of screwing strip in mm
strip_width = 20;

// Close end of tubes
close_end = false;

// move strips if necessary for the screw holes to be aligned
align_holes = true;
strip_top = false;
strip_center = false;
strip_bottom = true;
strip_left = true;
strip_right = true;

inner_radius = inner_diameter/2;
outer_radius = inner_radius + wall_thickness;

hole_step = (inner_diameter + wall_thickness) / 2;
aligning_pos = hole_step * round((height - strip_width) / hole_step - 0.5);
top_strip_pos = align_holes ? aligning_pos : height - strip_width;

$fn = 100;

module diamond_tube() {
    square_diagonal = sqrt(square_size * square_size * 2);
    spacing = square_diagonal + grid_thickness;
    outer_circumference = outer_radius * 2 * PI;
    steps = round(outer_circumference / spacing);
    angle_step = 360 / steps;
    
    difference() {
        cylinder(h = height, r = outer_radius);

        cylinder(h = height + 1, r = inner_radius);

        // Square pattern
        union() {
        for (pattern = [0 : 1]) {
            for (z = [0 : square_diagonal + grid_thickness : height]) {
                for (angle = [angle_step/2 * pattern : angle_step : 360]) {
                    rotate([0, 0, angle])
                    translate([inner_radius + (outer_radius - inner_radius) / 2, 0, z + spacing /2 * pattern])
                    rotate([0, 90])
                    rotate([0, 0, 45])
                    linear_extrude(height=wall_thickness*3, center=true)
                    square([square_size, square_size], center = true);
                }
            }
        }
        }
    }

    difference() {
        union() {
            translate([0, 0, height - grid_thickness])
            cylinder(h = grid_thickness, r = outer_radius);

            cylinder(h = grid_thickness, r = outer_radius);
        }
        
        translate([0,0, -1])
        cylinder(h = height + 2, r = inner_radius);
    }    
}

module screw_strip(extend=true) {
    translate([-screw_size * 2, 0, 0])
    cube([outer_radius * 2 * (tube_count - 1) + screw_size * (extend ? 2 : 0) + grid_thickness * 2,
        wall_thickness,
        strip_width]);
}

module screw_holes(hole_size, density=1) {
    translate([0, -wall_thickness, 0])
    for (i = [1 : tube_count * density]) {
        translate([(i-1)/density * (inner_diameter + wall_thickness), -(inner_radius - wall_thickness * 2), strip_width / 2])
        rotate([90, 0, 0])
        cylinder(h = wall_thickness * 3, r = hole_size / 2, center = false);
    }
}

module deep_screw(hole_size, density=1) {
    screw_holes(hole_size, density);

    translate([0, wall_thickness * 1.5, 0])
    screw_holes(hole_size * 2, density);
}

module screw_strip_vertical() {
    translate([0, wall_thickness/2, height/2])
    cube([strip_width,
        wall_thickness,
        height], center=true);
}

difference()
{
    union() {
        for (i = [1 : tube_count]) {
            translate([(i-1) * (inner_diameter + wall_thickness), 0, 0])
            diamond_tube();
        }

        translate([0, -outer_radius]) {
            if (strip_bottom) {
                screw_strip();
            }

            if (strip_top) {
                translate([0, 0, top_strip_pos])
                screw_strip();
            }

            if (strip_center) {
                translate([0, 0, height/2 - strip_width/2])
                screw_strip();
            }

            if (strip_left) {
                screw_strip_vertical();
            }

            if (strip_right) {
                translate([(tube_count-1) * (inner_diameter + wall_thickness), 0, 0])
                screw_strip_vertical();
            }
        }
    }

    if (strip_bottom) {
        deep_screw(screw_size, 2);
    }

    if (strip_top) {
        translate([0, 0, top_strip_pos])
        deep_screw(screw_size, 2);
    }

    if (strip_center) {
        translate([0, 0, height/2 - strip_width/2])
        deep_screw(screw_size, 2);
    }

    if (strip_left) {
        translate([strip_width/2, 0, strip_width/2])
        rotate([0, -90, 0])
        deep_screw(screw_size, 2);
    }

    if (strip_right) {
        translate([(tube_count-1) * (inner_diameter + wall_thickness), 0, 0])
        translate([strip_width/2, 0, strip_width/2])
        rotate([0, -90, 0])
        deep_screw(screw_size, 2);
    }
}

module end_stop() {
    count = round(inner_diameter / (square_size + grid_thickness));

    difference() {
        cylinder(h = grid_thickness, r = outer_radius);

        union () {
            rotate([0, 0, 45])
            linear_extrude(height=grid_thickness, center=false)
            for (x = [0 : count]) {
                for (y = [0 : count]) {
                    translate([-inner_radius + x * (square_size + grid_thickness),
                    -inner_radius + y * (square_size + grid_thickness), 0])
                    square([square_size, square_size], center = true);
                }
            }
        }
    }
}

if (close_end) {
    for (i = [1 : tube_count]) {
        translate([(i-1) * (inner_diameter + wall_thickness), 0, 0])
        end_stop();
    }
}
