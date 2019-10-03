// Functions for parts attached to PCB
// Copyright (c) 2019 Adrian Kennard, Andrews & Arnold Limited, see LICENSE file (GPL)

// Origins are top left of PCB, so typically translated -1,-1,1.6 from pcb() to allow for 1 mm margin on SVGs

module posn(x,y,w,h,r)
{ // Positioning for 90 degree angles as bottom left still
	s=sin(r);
	c=cos(r);
	translate([x+(s>0?h*s:0)+(c<0?-w*c:0),y+(c<0?-h*c:0)+(s<0?-w*s:0),0])
	rotate([0,0,r])
	children();
}

module pads(x,y,d=1.2,h=2.5,nx=1,ny=1,dx=2.54,dy=2.54)
{ // PCB pad, x/y are centre of pin
	for(px=[0:1:nx-1])
	for(py=[0:1:ny-1])
	translate([x+px*dx,y+py*dy,0])
	cylinder(d1=3,d2=d,h=h);
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

module screw5mm(x,y,r,n=2)
{
	posn(x,y,8.1,5*n,r)
	{
		pads(4.05,2.5,1.2,2.5,1,n,5,5);
	}
}
