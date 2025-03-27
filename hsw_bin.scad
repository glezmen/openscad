width = 100;
back_height = 20;
front_height = 15;
depth = 30;

sections = 3;
wall_thickness = 2;
separator_thickness = 1;

//-----------------
/* [HSW connector] */ 

// inner distance between corners
hexagon_size = 15.47;
connector_depth = 10;
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
    polygon(points = hexagon(hexagon_size / 2));
}

module connectors() {
    count = max(1, round(width / (hexagon_distance + hexagon_size / 2)));
    dist = (width - (count-1) * hexagon_distance) / 2;
    h = (hexagon_size/2 - tolerance)*sqrt(3)/2;
    
    translate([dist, connector_depth, h])
    for (i = [1 : count]) {
        translate([(i-1) * hexagon_distance, 0, 0])
        hsw_connector();    
    }
    
    cube([width, wall_thickness, back_height], center = false);
}

module side(thickness = wall_thickness) {
    rotate([0, 90, 0])
    linear_extrude(thickness)
    polygon([[0, 0], [0, -depth], [-front_height, -depth], [-back_height, 0]]);
}

module tray() {
    // bottom
    translate([0, -depth, 0])
    cube([width, depth, wall_thickness], center = false);

    // front
    translate([0, -depth, 0])
    cube([width, wall_thickness, front_height], center = false);
    
    // sides
    side();
    
    translate([width - wall_thickness, 0, 0])
    side();
}

module separators() {
    section_count = max(1, sections);
    count = max(section_count - 1, 1);
    for (i = [1 : count]) {
        translate([i * width / (count + 1), 0, 0])
        side(separator_thickness);
    }
}

/* MAIN */
connectors();
tray();
if (sections > 1) {
    separators();
}
