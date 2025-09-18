/* [Box dimensions] */
// mm
width_internal = 206;
// mm
length_internal = 206;
// mm
height_internal = 67;

/*
    Eryone: 206x206x67
*/

/* [Bottom] */
// mm
bottom_thickness = 1;
fill_percent = 50;

/* [Sections] */
sections_x = 2;
sections_y = 3;
cutout_x = true;
cutout_y = true;

// mm
cutout_width = 30;
// mm
cutout_depth = 20;

// mm
separator_thickness = 1;
outer_frame = true;

/* [Cover] */
hole_cover_position = "none"; // [none:left:right:front:back]
// mm
hole_cover_width = 60;
// mm
hole_cover_height = 50;

// LOCALS
/////////

r = separator_thickness / 2;
wi = width_internal - (outer_frame ? 2 * separator_thickness : 0);
dx = wi / sections_x;
li = length_internal - (outer_frame ? 2 * separator_thickness : 0);
dy = li / sections_y;
st = outer_frame ? separator_thickness : 0;

$fn = 100;

// MODULES
//////////

module separators() {
    for (x = [1:1:sections_x-1]) {
        translate([st + x * dx - r, 0, 0])
        cube([separator_thickness, length_internal, height_internal]);
    }
    
    for (y = [1:1:sections_y-1]) {
        translate([0, st + y * dy - r, 0])
        cube([width_internal, separator_thickness, height_internal]);
    }
}

// create peg at center position x:y
module peg(x, y, h = height_internal) {
    translate([x, y, 0])
    cylinder(h, r = r);
}

module frame(h = height_internal) {
    hull() {
        peg(r, length_internal - r, h);
        peg(width_internal - r, length_internal - r, h);
    }
    hull() {
        peg(r, r, h);
        peg(width_internal - r, r, h);
    }
    hull() {
        peg(r, r, h);
        peg(r, length_internal - r, h);
    }
    hull() {
        peg(width_internal - r, length_internal - r, h);
        peg(width_internal - r, r, h);
    }
}

module bottom() {
    hx = dx * (100 - fill_percent) / 100;
    hy = dy * (100 - fill_percent) / 100;
    wx = (dx - hx) / 2 + r;
    wy = (dy - hy) / 2 + r;

    difference() {
        union() {
            translate([r, r, 0])
            cube([width_internal - 2 * r, length_internal - 2 * r, bottom_thickness]);
            frame(bottom_thickness);
        }
        
        
        for (x = [0:1:sections_x-1]) {
            for (y = [0:1:sections_y-1]) {
                if (fill_percent < 100) {
                    translate([st/2 + x * dx, st/2 + y * dy, 0])
                    hull() {
                        peg(wx, wy);
                        peg(wx, dy - wy);
                        peg(dx - wx, dy - wy);
                        peg(dx - wx, wy);
                    }
                }
            }
        }
    }
}

module notch(size) {
    cr = 10;
    cw = cutout_width - cr * 2;
    chamfer = cutout_width;
    d = height_internal - cutout_depth;
    
    rotate([-90, 0, 0])
    hull() {
        translate([-cw / 2, -d-cr, 0])
        cylinder(size, r = cr);
        
        translate([cw / 2, -d-cr, 0])        
        cylinder(size, r = cr);

        translate([cw / 2, -(height_internal + cr), 0])        
        cylinder(size, r = cr);

        translate([-cw / 2, -(height_internal + cr), 0])        
        cylinder(size, r = cr);
    }

    translate([0, size/2, height_internal])
    rotate([0, 45, 0])
    cube([chamfer, size, chamfer], center = true);
}

module notches() {
    if (cutout_x) {
        for (x = [0:1:sections_x-1]) {
            translate([st + dx / 2 + x * dx, 0, 0])
            notch(length_internal);
        }
    }
    
    if (cutout_y) {
        translate([width_internal, 0, 0])
        rotate([0, 0, 90])
        for (y = [0:1:sections_y-1]) {
            translate([st + dy / 2 + y * dy, 0, 0])
            notch(width_internal);
        }
    }
}

module cover() {
    cr = 5;
    translate([0, separator_thickness, 0])
    union() {
        hull() {
            translate([0, 0, hole_cover_height - cr * 2])
            rotate([90, 0, 0])
            union() {
                translate([-hole_cover_width/2 + cr, cr, 0])
                cylinder(separator_thickness, r = cr);

                translate([hole_cover_width/2 - cr, cr, 0])
                cylinder(separator_thickness, r = cr);
            }
            
            h = hole_cover_height - cr * 2;
            translate([0, -separator_thickness / 2, h/2])
            cube([hole_cover_width, separator_thickness, h], center = true);
            
        }

        tab = 10;
        rotate([90, 0, 0])
        linear_extrude(separator_thickness)
        polygon([
            [-hole_cover_width/2 - tab, 0],
            [-hole_cover_width/2, tab],
            [hole_cover_width/2, tab],
            [hole_cover_width/2 + tab, 0]
        ]);
    }
}

module hole_cover() {
    if (hole_cover_position == "back") {
        translate([width_internal / 2, length_internal - separator_thickness, 0])
        cover();
    }
    if (hole_cover_position == "front") {
        translate([width_internal / 2, 0, 0])
        cover();
    }
    if (hole_cover_position == "left") {
        translate([separator_thickness, length_internal / 2, 0])
        rotate([0, 0, 90])
        cover();
    }
    if (hole_cover_position == "right") {
        translate([width_internal, length_internal / 2, 0])
        rotate([0, 0, 90])
        cover();
    }
}

// MAIN
///////

translate([-width_internal/2, -length_internal/2, 0])
union() {
    difference() {
        union() {
            separators();
            if (outer_frame) {
                frame();
            }
        }
        notches();
    }


    if (bottom_thickness > 0) {
        bottom();
    }

    hole_cover();
}