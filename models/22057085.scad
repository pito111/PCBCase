// 8 way SPOX right angle
translate([-2.5,-6.6,0])
{
	cube([22.4,4.9,4.9]);
	cube([22.4,5.9,3.9]);
	hull()
	{
		cube([22.4,7.4,1]);
		cube([22.4,7.9,0.5]);
	}
	translate([1,6,-3.5])cube([20.4,1.2,6]);
}

