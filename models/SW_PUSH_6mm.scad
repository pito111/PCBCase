translate([-3,-3,0])
{
	b(0,0,0,6,6,4);
	cylinder(d=4,h=100);
	for(x=[-3,3])for(y=[-2,2])translate([x,y,-2])cylinder(d=2,h=4);
}
