// Screw 6mm
rotate([0,-90,0],$fn=100)
{
	translate([0,0,-100])cylinder(d=12,h=100);
	cylinder(d1=12,d2=6,h=3);
	cylinder(d=6,h=100);
}

