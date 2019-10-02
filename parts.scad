// Functions for parts attached to PCB
// Copyright (c) 2019 Adrian Kennard, Andrews & Arnold Limited, see LICENSE file (GPL)

// Origins are top left of PCB, so typically translated -1,-1,1.6 from pcb() to allow for 1 mm margin on SVGs

module posn(x,y,w,h,r)
{ // Positioning for 90 degree angles as bottom left still
	translate([x+(r==90?h:0)+(r==180?w:0),y+(r==-90?w:0)+(r==180?w:0),0])
	rotate([0,0,r])
	children();
}

module pad(x,y,d=1.2)
{ // PCB pad, x/y are corner of pin
	translate([x+d/2,y+d/2,0])
	cylinder(d1=3,d2=d,h=3);
}

module esp32(x,y,r)
{ // Corner of main board
	posn(x,y,18,25.5,r)
	{
		cube([18,25.5,1]);	// Base PCB
    		translate([1,1,0])
    		cube([16,18,3]);		// Can
    		translate([-1,1,0])
    		cube([20,18,2]); // Solder
	}
}

module screw5mmx2(x,y,r)
{
	posn(x,y,8,10,r)
	{
		pad(3.4,1.9,1.2);
		pad(3.4,1.9+5,1.2);
		translate([0,0,-1.6])
		{
		}
	}
}
