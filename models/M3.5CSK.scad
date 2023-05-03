// Screw M3.5 countersunk
if(!hulled)
rotate([0,90,0],$fn=24)
{
	if(!pushed)
	{
		translate([0,0,-10])cylinder(d=6.5,h=10);
		cylinder(d1=6.5,d2=3.5,h=2);
	}
	cylinder(d=3.5,h=100);
}

