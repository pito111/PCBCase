translate([3.5,-2.25,0])
{
	b(0,0,0,6,6,4);
	cylinder(d=4,h=100);
	for(x=[-3.25,3.25])for(y=[-2.25,2.25])translate([x,y,-2])cylinder(d=2,h=4);
}
