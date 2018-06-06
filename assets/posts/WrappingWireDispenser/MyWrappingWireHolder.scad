$fn=40;

// Spools external radius
spool_radius=35;
// Spool width
spool_width=35;
// Spool internal radius (hole)
spool_internal_radius=12.5;
//  How many spools per row
nb_cols=4;
// How many rows of spools
nb_rows=2;
// Floor width (table or wall side)
ground_width=5;
// External side width (needs to be more than 2mm)
side_width=5;
// Intermediate wall width (fillers used to avoir unrolling several spool at a time)
wall_width=3;
// Distance between back and spools to avoid friction
ground_distance = 1;
// Screw thread radius (if wall mounted)
screw_thread = 3;
// Screw head radius (if wall mounted)
screw_head = 4;

box_x=2*side_width+nb_cols*spool_width+(nb_cols-1)*wall_width;
box_y=nb_rows*2*spool_radius+(nb_rows-1)*wall_width;
box_z=ground_width+2*spool_radius+ground_distance;


intersection() { 
        difference (){
            // Box
            cube([box_x,box_y,box_z,]);
            //  Hollow top half of the box
            translate ([side_width,-5,ground_width+spool_radius+ground_distance])
                cube([box_x-2*side_width,box_y+10,box_z]);
            // Wall mount screw holes
            translate([spool_width/2,spool_radius/2,ground_width/2])            cylinder(ground_width,screw_head,screw_head);
            translate([spool_width/2,box_y-spool_radius/2,ground_width/2])            cylinder(ground_width,screw_head,screw_head);
            translate([box_x-spool_width/2,spool_radius/2,ground_width/2])            cylinder(ground_width,screw_head,screw_head);
            translate([box_x-spool_width/2,box_y-spool_radius/2,ground_width/2])            cylinder(ground_width,screw_head,screw_head);
            translate([spool_width/2,spool_radius/2,0])            cylinder(ground_width,screw_thread,screw_thread);
            translate([spool_width/2,box_y-spool_radius/2,0])            cylinder(ground_width,screw_thread,screw_thread);
            translate([box_x-spool_width/2,spool_radius/2,0])            cylinder(ground_width,screw_thread,screw_thread);
            translate([box_x-spool_width/2,box_y-spool_radius/2,0])            cylinder(ground_width,screw_thread,screw_thread);
            // Hollow spool columns
            for(col = [1:1:nb_cols])
                translate([side_width+(col-1)*spool_width+(col-1)*wall_width,-5,ground_width])
                    cube([spool_width,box_y+10,box_z]);
            //  Hollow Spool axis locations
            for(row = [1 :1 : nb_rows]) {
                translate([side_width/2,spool_radius+(row-1)*2*spool_radius+(row-1)*wall_width,ground_width+spool_radius+ground_distance])
                    rotate([0,90,0]) 
                        cylinder (box_x-side_width,spool_internal_radius,spool_internal_radius);
                translate([side_width/2,spool_radius+(row-1)*2*spool_radius+(row-1)*wall_width,ground_width+spool_radius+ground_distance])
                    rotate([0,90,0])
                        linear_extrude(box_x-side_width)
                            polygon([
                            [-2*spool_radius,-2*spool_internal_radius],[0,-0.9*spool_internal_radius],
                            [0,0.9*spool_internal_radius],[-2*spool_radius,2*spool_internal_radius]
                        ]);
            }
    };
    // Top  rounding shape
    union() {
        // Base box
        cube([box_x,box_y,box_z-spool_radius,]);
        // Base vertical stand on both ends
        cube([box_x,spool_radius,box_z]);
        translate ([0,box_y-spool_radius,0]) cube([box_x,spool_radius,box_z]);
        // Spool rows
        for(row = [1:1 : nb_rows])
            translate([-10,spool_radius+(row-1)*2*spool_radius+(row-1)*wall_width,ground_width+spool_radius+ground_distance])
                rotate([0,90,0]) 
                    cylinder (box_x+20,spool_radius,spool_radius);
    }
};

// Spool axis
for(row = [1 :1 : nb_rows]) {
    //translate([side_width/2,0,spool_radius*2]) rotate([0,90,0])
    translate([-10-spool_internal_radius,spool_radius+(row-1)*2*spool_radius+(row-1)*wall_width,0])
                cylinder (box_x-side_width,spool_internal_radius,spool_internal_radius);
};
