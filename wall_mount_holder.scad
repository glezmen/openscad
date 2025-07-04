inner_width = 50;
inner_height = 50;
inner_depth = 25;

wall_thickness = 2;


hole_diameter = 5;

cutout_width = 20;
cutout_height = 70;

container_width = inner_width + wall_thickness * 2;
container_height = inner_height + wall_thickness;
container_depth = inner_depth + wall_thickness * 2;

chamfer_size = (container_width - cutout_width)/2;
        
$fn = 100;

module wall_mount_container() {
    difference() {
        // box
        cube([container_width, container_height, container_depth], center = true);
        
        translate([0, wall_thickness, 0])
            cube([container_width - 2*wall_thickness, container_height, container_depth - 2*wall_thickness], center = true);
            
        // holes
        for(i = [0 : 1]) {
            translate([0, (i*2 - 1) * container_height/4, -container_depth/2])
            union() {
                translate([0, 0, wall_thickness])
                cylinder(h = wall_thickness, d1 = hole_diameter, d2 = hole_diameter*2, center = true); 

                translate([0, 0, -wall_thickness/2])            
                cylinder(h = wall_thickness*2, d = hole_diameter, center = true);
            }
        }
        
        // front cutout
        translate([0, container_height/2 - cutout_height/2, container_depth/2])
        cube([cutout_width, cutout_height, wall_thickness * 2], center = true);
     
        // chamfer
        for(i = [0:1]) {
            translate([(i*2 - 1) * (container_width/2 - chamfer_size), container_height/2, container_depth/2 - wall_thickness/2])
            rotate([0, 0, 45])
            cube([chamfer_size, chamfer_size, wall_thickness], center = true);
        }
  
    }
}


        
translate([0, 0, container_height/2])
rotate([90, 0, 0])
wall_mount_container();