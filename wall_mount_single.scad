height_back = 42;
height_front = 15;
inner_depth = 15;
width = 12;
hole = 4;
thickness = 2;
strut = true;

$fn = 100;
fillet = thickness/2;

module corner() {
    rotate([0, 90, 0])    
    cylinder(h = width, r = fillet);
}

module back() {
    difference() {
        hull() {
            translate([0, 0, strut ? -inner_depth/2 - fillet : 0])
            corner();
            
            translate([0, 0, height_back - fillet * 2])
            corner();
        }
        
        for ( i = [0 : height_back / hole / 2 / 2 - 1]) {
            translate([width/2, -fillet, height_back - fillet - hole - hole/2 - hole * 2 * 2 * i])
            rotate([-90, 0, 0])
            union() {
                cylinder(h=hole, r1=hole, r2=1);
                
                translate([0, 0, fillet])
                cylinder(h=fillet * 2, r1=hole/2, r2=hole/2);
            }
        }
    }

    if (strut) {
        hull() {
            translate([0, -inner_depth/2 - fillet, 0])
            corner();        

            translate([0, 0, strut ? -inner_depth/2 - fillet : 0])
            corner();
        }
    }
}

module bottom() {
    hull() {
        corner();

        translate([0, -(inner_depth + fillet * 2), 0])
        corner();
    }
}

module front() {
    translate([0, -(inner_depth + fillet * 2), 0])
    hull() {
        corner();
        
        translate([0, 0, height_front - fillet * 2])
        corner();
    }
}

rotate([0, -90, 0])
union() {
    back();
    bottom();
    front();
}