rotate([-90,0,0])
rotate([0,0,-90])
translate([-11.5,-17.5,-5.5])
{
	translate([0,0,4])cube([23,35,1.6]);
	translate([0.1,1.5,0])cube([22.8,33.4,7]);
	// Hole for air
	if(!pushed)translate([14.5,34.9,4.8])rotate([-90,0,0])cylinder(h=100,d=2,$fn=24);
}

