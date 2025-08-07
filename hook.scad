/* [Plate] */ 

plate_width = 35;
plate_height = 20;
plate_thickness = 2;
plate_fillet = 4;

/* [Hook] */ 

hook_length = 30;
hook_base = 12;
hook_top = 6;
hook_angle = 40;
hook_sides = 6;

/* [Extend] */ 

hook_extend = 10;
hook_extend_angle = 20;

/* [Hole] */ 

hole_diameter = 4;
hole_count = 4;

module plate() {
    dx = plate_width / 2 - plate_fillet;
    dy = plate_height / 2 - plate_fillet;
    translate([0, 0, plate_height/2])
    hull() {
        rotate([90, 0, 0])
        union() {
            for(x = [-1 : 2 : 1]) {
                for(y = [-1 : 2 : 1]) {
                    translate([x * dx, y * dy])
                    cylinder(h = plate_thickness, r = plate_fillet, center = true);
                }
            }
        }
    }
}

module hook() {
    hull() {
        $fn = hook_sides;
        translate([0, 0, hook_base/2])
        rotate([90 - hook_angle, 0, 0])
        cylinder(h = hook_length, r1 = hook_base/2, r2 = hook_top/2);
        
        translate([0, 0, hook_base/4])
        cube([hook_base/2, hook_base/2, hook_base/2], true);
    }
}

module ext(length) {
    $fn = hook_sides;
    translate([0, -hook_extend + length, hook_base/2])
    rotate([90, 90, 0])
    cylinder(h = length, r = hook_base/2);
}

module hole() {
    rotate([90, 0, 0])
    union() {
        cylinder(h = plate_thickness, r = hole_diameter / 2, center = true);
        translate([0, 0, plate_thickness/2])
        cylinder(h = plate_thickness, r1 = hole_diameter / 2, r2 = hole_diameter, center = true);                
    }
}

module holes() {
    $fn = 100;

    if (hole_count % 2 == 1) {
        translate([0, 0, plate_height - hole_diameter * 1.5])
        hole();
    }
    step = hole_count == 1 ? hole_diameter : plate_height / floor(hole_count/2);
    for (x = [0 : 1]) {
        for(i = [0 : hole_count/2 - 1]) {
            translate([(x * 2 - 1) * (plate_width / 2 - hole_diameter * 1.5), 0, plate_height - step * (i + 0.5)])
            hole();
        }
    }
}

$fn = 100;
difference() {
    union() {
        plate();
        rotate([-hook_extend_angle, 0, 0])
        union() {
            if (hook_length > 0) {
                hull() {
                    translate([0, -hook_extend, 0])
                    hook();

                    ext(2);
                }
            }
            ext(hook_extend);
        }
    }
    
    holes();
    
    translate([0, hook_base/2 + plate_thickness/2, plate_height/2])
    cube([plate_width, hook_base, plate_height], true);
    
    translate([0, 0, -plate_width/2])
    cube([plate_width, plate_width, plate_width], center = true);
}