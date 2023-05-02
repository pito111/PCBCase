// Screw M3.5 countersunk
if(!hulled)
rotate([0,90,0],$fn=24)
{
	if(!hulled)
	{
		translate([0,0,-10])cylinder(d=7,h=10);
		cylinder(d1=7,d2=3.5,h=3.5);
	}
	cylinder(d=3.5,h=100);
}

