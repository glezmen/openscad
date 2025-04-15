// number of tubes
tube_count = 4;
inner_diameter = 50;
// thickness of tube wall
wall_thickness = 2;
// total tube lenght in mm
height = 80;

// hole size in mm, set to 0 for solid walls
square_size = 8;
// grid thickness in mm
grid_thickness = 3;

// bottom plate
bottom_plate = true;

// additional connector for stronger connection
wider_connection = false;

// taller back wall
taller_connection = false;

inner_radius = inner_diameter/2;
outer_radius = inner_radius + wall_thickness;


//-----------------
/* [HSW connector] */ 

// inner distance between corners
connector_size = 15.47;
connector_depth = 13;
tolerance = 0.1;
hexagon_distance = 40.88;

$fn = 100;

/* functions*/
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

	if (bottom_plate) {
		cylinder(h = wall_thickness, r = outer_radius);
	}
}

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
    tubes_width = tube_count * (inner_diameter + wall_thickness) + wall_thickness;

    count = max(1, round((wider_connection ? 1 : 0) + tubes_width / (hexagon_distance + connector_size / 2)));
    strip_width = (count - 0.5) * hexagon_distance;

    real_width = strip_width;
    
    dist = (real_width - (count-1) * hexagon_distance) / 2;
    h = (connector_size/2 - tolerance)*sqrt(3)/2;    
    diff = (tubes_width - strip_width) / 2;
    
    translate([-outer_radius + diff, 0, 0])
    union() {
        translate([dist, connector_depth, h])
        for (i = [1 : count]) {
            translate([(i-1) * hexagon_distance, 0, 0])
            hsw_connector();    
        }

        cube([real_width, wall_thickness, connector_size * (taller_connection ? 2 : 1)], center = false);
    }
}

/* MAIN */
connectors();
for (i = [1 : tube_count]) {
//    translate([(i-1) * (outer_radius * 2), wall_thickness-outer_radius, 0])
    translate([(i-1) * (inner_radius * 2 + wall_thickness), wall_thickness-outer_radius, 0])
    diamond_tube();
}
