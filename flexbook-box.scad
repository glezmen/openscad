outer_width = 100;
outer_height = 160;
inner_depth = 25;

// ring to put on the book to keep it closed tightly
closing_ring = true;
closing_ring_gap = 0.6;

// Text on cover, separate lines using "|"
title = "  FlexiBook|       by|  Glezmen";
text_size = 8;

//-----------------
/* [Walls] */ 

wall_thickness = 2;
cover_thickness = 1;

//-----------------
/* [Flex] */ 

flex_thickness = 0.6;
flex_slit = 0.6;

// number of slits along
slit_divider = 8;

//-----------------
/* [Lock] */ 
lock_type = "magnet"; // [magnet:slit:tongue:none]
tolerance = 0.1;
handle = true;
handle_size = 16;

magnet_diameter = 8;
magnet_depth = 3;
lock_width = magnet_diameter * 2;

//-----------------
/* [Sections] */ 

sections_x = 2;
sections_y = 3;
separator_thickness = 1;

$fn = 100;

fold_diameter = inner_depth + wall_thickness;

// fold circumference
c = fold_diameter * PI / 2;

// width of cover where flex is present instead of solid
flex_into_cover = cover_thickness + 2;

// magnet lock brick width
w = magnet_diameter * 1.5;

// magnet brick thickness
t = magnet_depth + tolerance + 1;

// slit length
l = outer_height / slit_divider;

include <BOSL2/std.scad>;
 
module book() {
    difference() {
        union() {
            cube([outer_width, outer_height, inner_depth + wall_thickness]);

            translate([0, 0, (inner_depth + wall_thickness) / 2])
            rotate([-90, 0, 0])
            cylinder(h = outer_height, d = fold_diameter);
        }
        
        union() {
            translate([-inner_depth + wall_thickness, wall_thickness, 0])
            cube([inner_depth - wall_thickness, outer_height - 2 * wall_thickness, inner_depth * 2]);
            
            translate([wall_thickness, wall_thickness, wall_thickness])
            cube([outer_width - 2 * wall_thickness, outer_height - 2 * wall_thickness, inner_depth + wall_thickness * 2]);
        }
    }
}

module slit(length, width = flex_slit, thickness = flex_thickness) {
    translate([0, flex_slit, 0])
    union() {
        cube([width, length - width, thickness * 2]);
        
        translate([width/2, 0, 0])
        cylinder(thickness * 2, d = width);

        translate([width/2, length - width, 0])
        cylinder(thickness * 2, d = width);
    }
}

module fold() {
    l = outer_height / slit_divider;
    fc = (fold_diameter + cover_thickness + tolerance * 2) * PI / 2 + flex_into_cover;
    
    difference() {
        translate([-fc, 0, 0])
        cube([fc, outer_height, flex_thickness]);
        
        for (i = [0 : fc / flex_slit / 2]) {
            for (j = [0 : slit_divider]) {
                translate([-i * flex_slit * 2, flex_slit + j * l + (i % 2 == 0 ? -l / 2 : 0), 0])
                slit(l - flex_slit * 2);
            }
        }
    }
}

module cover() {
    lines = str_split(title, "|");

    translate([-c - flex_into_cover, 0, cover_thickness])
    rotate([0, 180, 0])
    {
        difference() {
            cube([outer_width - flex_into_cover, outer_height, cover_thickness]);
            
            for (i = [0 : len(lines) - 1]) {
                translate([outer_width / 8, 2 * outer_height / 3 - i * text_size * 1.5, cover_thickness / 2])
                linear_extrude(cover_thickness / 2)
                text(lines[i], size = text_size, font = "DejaVu Sans", halign = "left");
            }
        }
    }
}
            
module sections() {
    if (sections_x > 1) {
        for (x = [1 : sections_x - 1]) {
            translate([x * (outer_width / sections_x), 0, 0])
            cube([separator_thickness, outer_height, inner_depth + wall_thickness]);
        }
    }
    
    if (sections_y > 1) {
        for (y = [1 : sections_y - 1]) {
            h = lock_type == "magnet" && (sections_y % 2 == 0) && y == sections_y / 2
                ? inner_depth + wall_thickness - t * 2 : inner_depth + wall_thickness;
            translate([0, y * (outer_height / sections_y), 0])
            cube([outer_width, separator_thickness, h]);
        }
    }
}

module magnet_socket() {
    difference() {
        cube([w, w, t]);

        translate([w/2, w/2, 1])
        cylinder(d = magnet_diameter + tolerance * 2, h = magnet_depth + tolerance * 2);
        
        translate([w/2, w/2, -t])
        cylinder(d = 2, h = t * 2);
    }
}

module magnet_lock() {
    dy = outer_height/2 - w / 2;

    // cover side
    translate([-c - outer_width, dy, 0])
    magnet_socket();
    
    // box side
    translate([outer_width - w, dy, inner_depth + wall_thickness - 2 * t + cover_thickness])
    union() {
        magnet_socket();
        
        rotate([-90, 0, 0])
        linear_extrude(w)
        polygon([[0, 0], [w, 0], [w, w]]);
    }
}

module slit_lock() {
    dy = outer_height/2 - l / 2;
    
    translate([-c - outer_width, dy, 0])
    slit(l, wall_thickness, wall_thickness);
}

difference () {
    union() {
        book();

        if (lock_type == "tongue") {
            tl = l + 2 * (wall_thickness + tolerance);
            
            translate([outer_width - wall_thickness, outer_height / 2 - tl / 2, inner_depth + wall_thickness])
            difference() {
                cube([wall_thickness, tl , 2 * (cover_thickness + tolerance)]);

                translate([0, wall_thickness, 0])
                cube([wall_thickness, l + tolerance * 2, cover_thickness + 2 * tolerance]);
            }
        }
    }
    
    if (lock_type == "magnet") {
        cw = w + 2 * tolerance;
        dy = outer_height/2 - cw / 2;

        translate([outer_width - cw, dy, inner_depth + wall_thickness - t])
        cube([cw, cw, t]);
    }
        
    if (lock_type == "slit") {
        dy = outer_height/2 - l / 2;
        translate([outer_width - wall_thickness, dy, inner_depth - wall_thickness])
        slit(l + tolerance * 2, wall_thickness, wall_thickness);
    }    
}

fold();

difference() {
    union() {
        cover();

        if (lock_type == "tongue") {
            translate([-c -outer_width - wall_thickness, outer_height/2 - l/2, 0])
            cube([wall_thickness, l, cover_thickness]);
        }
    }
        
    if (lock_type == "magnet") {
        dy = outer_height/2 - w / 2;

        translate([-c - flex_into_cover - outer_width, dy, 0])
        cube([w, w, t]);
    }

    if (lock_type == "tongue") {
        translate([-c - outer_width, outer_height/2 - l/2 -  wall_thickness - 2 * tolerance, 0])
        cube([wall_thickness, wall_thickness + tolerance * 2, cover_thickness]);

        translate([-c - outer_width, outer_height/2 + l/2, 0])
        cube([wall_thickness, wall_thickness + tolerance * 2, cover_thickness]);    
    }

}

if (handle) {
    hw = handle_size;
    translate([-c -outer_width - hw/2, outer_height/2 - hw/2, 0])
    cube([hw/2, hw, cover_thickness]);
}
    
difference() {
    sections();

    if (lock_type == "slit") {
        dy = outer_height/2 - l / 2;
        translate([outer_width - wall_thickness, dy, inner_depth - wall_thickness])
        slit(l + tolerance * 2, wall_thickness, wall_thickness);
    }  
}

if (lock_type == "magnet") {
    magnet_lock();
} else if (lock_type == "slit") {
    slit_lock();
}

color("red")
translate([outer_width + wall_thickness + 10, 0, 0])
if (closing_ring) {
    dx = inner_depth + wall_thickness + cover_thickness + closing_ring_gap;
    dy = outer_height + closing_ring_gap;
    d = wall_thickness;

    difference() {
        hull() {
            translate([0, dy, 0])
            cylinder(h = 20, r = d);

            translate([dx, dy, 0])
            cylinder(h = 20, r = d);

            translate([dx, 0, 0])
            cylinder(h = 20, r = d);

            cylinder(h = 20, r = d);
        }
        
        cube([dx, dy, 20]);
    }
}