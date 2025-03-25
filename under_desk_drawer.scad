// Parametric under desk drawer

// Width of plate (without rails) in mm
width = 200;

// Length of plate (without handle) in mm
length = 160;

// Height of drawer
height = 40;

// Front wall
front_wall = "handle"; // [handle:connector:none:wall]

// Back wall
back_wall = "wall"; // [end:connector:none]

// Left wall
left_wall = "rail"; // [rail:connector:none]

// Right wall
right_wall = "rail"; // [rail:connector:none]

// diameter in mm
hexagon_size = 10;
// mm
hexagon_spacing = 1; 
// mm
thickness = 2;

rail_thickness = 10;

handle_width = 60;

screw_size = 4;

screw_holes = 2;

// number of dove tails per side
connector_count = 3;

// mm
connector_gap = 0.15;

// label

$fn = 100;

//////////

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
                  
        translate([thickness, thickness])
        square([size_x - thickness * 2, size_y - thickness * 2]);
    }
}

module hex_panel(size_x, size_y, thickness, solid = false) {
    linear_extrude(thickness)
    hex_grid(size_x, size_y, solid);
}

module siderail(length, shrink = 0) {
    translate([0, 0, height])
    rotate([-90, 0, 0])
    linear_extrude(length)
    polygon([
        [0, 0], [-(rail_thickness - shrink), 0], [0, rail_thickness - shrink]
    ]);
}

module screw_hole() {
    translate([-rail_thickness / 2, 0, rail_thickness - height/2])
    cylinder(height, d = screw_size, center = true);
    
    translate([-rail_thickness / 2, 0,  rail_thickness / 2 - thickness])
    cube([rail_thickness, rail_thickness, rail_thickness], center = true);
}

module screw_holes() {
    step = length / (2 * screw_holes);
    for (i = [1 : screw_holes]) {
        translate([0, (i - 1) * 2 * step + step, 0])
        screw_hole();
    }
}

module rail() {
    difference() {
        union() {
            difference() {
                union() {
                    translate([0, 0, rail_thickness - height])
                    siderail(length);
                    
                    cube([rail_thickness, length, rail_thickness], center = false);
                }
                
                translate([rail_thickness, 0, - height + rail_thickness])
                siderail(length);
            }
        };
        
        screw_holes();
    }
}

module dove_tail(up = false, shrink = 0) {
    translate([0, 0, up ? thickness / 2 : 0])
    linear_extrude(thickness / 2)
    polygon([[-(3-shrink), 0], [(3-shrink), 0], [(5-shrink), -(5-shrink)], [-(5-shrink), -(5-shrink)]]);
}

module connector(length, shrink = 0) {
    step = length / (2 * connector_count);
    for (i = [1 : connector_count]) {
        translate([(i - 1) * 2 * step + step, 0, 0])
        dove_tail(i % 2 == 0, shrink);
    }
}

translate([-rail_thickness * 5, 0, 0])
rail();

translate([-rail_thickness * 2, 0, 0])
mirror([1, 0, 0])
rail();

module invert_connectors() {
    if (left_wall == "connector") {
        rotate([0, 0, 90])
        connector(length, -connector_gap);
    }

    if (back_wall == "connector") {
    translate([0, length, 0])
        connector(width, -connector_gap);
    }
}

// bottom
difference() {
    union() {
        hex_panel(width, length, thickness);
        
        if (left_wall == "connector") {
            cube([5, length, thickness], center = false);
        }
        if (back_wall == "connector") {
            translate([0, length - 5, 0])
            cube([width, 5, thickness], center = false);
        }

    }

    color("red")    
    invert_connectors();
}

// left
if (left_wall == "rail") {
    siderail(length, 1);
    
    translate([thickness, 0, 0])
    rotate([0, 270, 0])
    hex_panel(height, length, thickness);
}

// right
if (right_wall == "rail") {
    translate([width, 0, 0])
    mirror([1, 0, 0])
    siderail(length, 1);
    
    translate([width, 0, 0])
    rotate([0, -90, 0])
    hex_panel(height, length, thickness);
} else if (right_wall == "connector") {
    color("red")
    translate([width, 0, 0])
    rotate([0, 0, 90])
    connector(length);
}

// back
if (back_wall == "wall") {
    translate([0, length, 0])
    rotate([90, 0, 0])
    hex_panel(width, height, thickness);
}

// front
if (front_wall == "handle") {
    translate([0, thickness, 0])
    union() {
        difference() {
            translate([(width + handle_width) / 2, 0, 0])
            rotate([0, 0, 90])
            siderail(handle_width);
            
            translate([(width + handle_width) / 2 - thickness, - thickness, thickness * 2])
            rotate([0, 0, 90])
            siderail(handle_width - thickness * 2);        
        }

        rotate([90, 0, 0])
        hex_panel(width, height, thickness);
    }
} else if (front_wall == "connector") {
    connector(width);
} else if (front_wall == "wall") {
    rotate([90, 0, 0])
    hex_panel(width, height, thickness);
}