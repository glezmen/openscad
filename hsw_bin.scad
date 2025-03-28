width = 100;
back_height = 20;
front_height = 15;
depth = 30;

sections = 3;
wall_thickness = 2;
separator_thickness = 1;

front_wall_honeycomb = false;
back_wall_honeycomb = false;
sides_honeycomb = false;
separators_honeycomb = true;
bottom_honeycomb = false;

//-----------------
/* [Honeycomb pattern] */ 

// diameter in mm
hexagon_size = 10;
// mm
hexagon_spacing = 1;

hex_radius = hexagon_size / 2;
hex_width = sqrt(3) * hex_radius;
raster_spacing = hex_width + hexagon_spacing;


//-----------------
/* [HSW connector] */ 

// inner distance between corners
connector_size = 15.47;
connector_depth = 13;
tolerance = 0.1;
hexagon_distance = 40.88;

/* functions*/
function hexagon(radius) = [
    for (i = [0:5])
        [radius * cos(i * 60), radius * sin(i * 60)]
];

module hsw_connector() {
    rotate([90, 0, 0])
    linear_extrude(height = connector_depth)
    offset(r = -tolerance)
    polygon(points = hexagon(connector_size / 2));
}

module connectors() {
    count = max(1, round(width / (hexagon_distance + connector_size / 2)));
    dist = (width - (count-1) * hexagon_distance) / 2;
    h = (connector_size/2 - tolerance)*sqrt(3)/2;
    
    translate([dist, connector_depth - wall_thickness, h])
    for (i = [1 : count]) {
        translate([(i-1) * hexagon_distance, 0, 0])
        hsw_connector();    
    }
    
    rotate([90, 0, 0])
    hex_panel(width, back_height, wall_thickness, !back_wall_honeycomb, true);
}

module hexagon_cutout() {
    circle(hex_radius, $fn=6);
}
 
module hex_grid(size_x, size_y, solid = false, frame = false) {
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
    
    if (frame) {
        difference() {
            square([size_x, size_y]);
            
            translate([wall_thickness, wall_thickness])
            square([size_x - wall_thickness * 2, size_y - wall_thickness * 2]);
        }
    }
}

module hex_panel(size_x, size_y, thickness, solid = false, frame = false) {
    linear_extrude(thickness)
    hex_grid(size_x, size_y, solid, frame);
}

module hex_side(thickness = wall_thickness, solid = false) {
    linear_extrude(thickness)
    hex_grid(depth, back_height, solid);
}

module side(thickness = wall_thickness, solid = false) {
    intersection() {
        translate([wall_thickness, wall_thickness, 0])
        rotate([90, 0, -90])
        hex_side(thickness, solid);
        
        rotate([0, 90, 0])
        linear_extrude(wall_thickness)
        polygon([[0, 0], [0, -depth], [-front_height, -depth], [-back_height, 0]]);
    }

    translate([wall_thickness-thickness, 0, 0])
    rotate([0,90,0])
    linear_extrude(thickness)
    difference() {
        polygon([[0, 0], [0, -depth], [-front_height, -depth], [-back_height, 0]]);

        offset(-wall_thickness)
        polygon([[0, 0], [0, -depth], [-front_height, -depth], [-back_height, 0]]);
    }
}


module tray() {
    // bottom
    translate([0, -depth, 0])
    hex_panel(width, depth, wall_thickness, !bottom_honeycomb, true);

    // front
    translate([0, wall_thickness - depth, 0])
    rotate([90, 0, 0])
    hex_panel(width, front_height, wall_thickness, !front_wall_honeycomb, true);
    
    // sides
    side(wall_thickness, !sides_honeycomb);
    
    translate([width - wall_thickness, 0, 0])
    side(wall_thickness, !sides_honeycomb);
}

module separators() {
    section_count = max(1, sections);
    count = max(section_count - 1, 1);
    for (i = [1 : count]) {
        translate([i * width / (count + 1), 0, 0])
        side(separator_thickness, !separators_honeycomb);
    }
}

/* MAIN */
connectors();
tray();
if (sections > 1) {
    separators();
}
