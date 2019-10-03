// Functions for parts attached to PCB
// Copyright (c) 2019 Adrian Kennard, Andrews & Arnold Limited, see LICENSE file (GPL)

// Origins are top left of PCB, so typically translated -1,-1,1.6 from pcb() to allow for 1 mm margin on SVGs
// The stage parameter is used to allow these functions to be called for pcb(), and cut()
// Stage=0 is the PCB part
// Stage=1 adds to box base
// Stage=-1 cuts in to box base
// Only parts that expect to "stick out" from the case do anything for the cut stages

module posn(x,y,w,h,r)
{ // Positioning for 90 degree angles as bottom left still
	s=sin(r);
	c=cos(r);
	translate([x+(s>0?h*s:0)+(c<0?-w*c:0),y+(c<0?-h*c:0)+(s<0?-w*s:0),0])
	rotate([0,0,r])
	children();
}

module pads(x,y,d=1.2,h=2.5,nx=1,dx=2.54,ny=1,dy=2.54)
{ // PCB pad, x/y are centre of pin
	for(px=[0:1:nx-1])
	for(py=[0:1:ny-1])
	translate([x+px*dx,y+py*dy,-0.001])
	cylinder(d1=3,d2=d,h=h+0.001,$fn=8);
}

module esp32(stage,x,y,r=0)
{ // Corner of main board of ESP32 18mm by 25.5mm
	posn(x,y,18,25.5,r)
	{
		if(!stage)
		{
			cube([18,25.5,1]);	// Base PCB
    			translate([1,1,0])
    			cube([16,18,3]);		// Can
    			translate([-1,1,0])
    			cube([20,18,2]); // Solder
		}else{ // Cut
			translate([-0.2,15.5,0])
			hull()
			{
				translate([0,0,stage/2])
				cube([18.4,10,1]);	// Base PCB
				translate([-10,0,stage*20])
				cube([18.4+20,10,1]);
			}
		}
	}
}

module screw(stage,x,y,r,n=2,d,w,h,yp,ys,s=3,pcb=1.6)
{ // Corner of outline
	posn(x,y,d*n,w,r)
	{
		if(!stage)
		{
			pads(d/2,yp?yp:w/2,1.2,3.5-pcb,n,d);
			// Body
			translate([0,0,-pcb-h])
			cube([d*n,w,h+0.001]);
			// Screws
			for(px=[0:1:n-1])
			translate([d/2+d*px,ys?ys:w/2,-pcb-20-h])
			cylinder(d=s,h=20.001);
			// Wires
			for(px=[0:1:n-1])
			translate([d/2+d*px-(d-1)/2,-20,-pcb-1-(d-1)])
			cube([d-1,20.001,d-1]);
		}else{ // Cut
			translate([0,-20,-pcb-1-(d-1)/2-0.5])
			hull()
			{
				translate([0,0,stage/2])
				cube([d*n,20,1]);
				translate([0,0,stage*20])
				cube([d*n,20,1]);
			}
		}
	}
}

module screw5mm(stage,x,y,r,n=2)
{ // 8.1mm wide, 10mm high, 5mm spacing, low profile screw terminals, e.g. RS 897-0843
	screw(stage,x,y,r,n,5,8.1,10);
}

module screw3mm5a(stage,x,y,r,n=2)
{ // 7mm wide, 8.5mm high, 3.5mm spacing, low profile screw terminals, e.g. RS 144-4314
	screw(stage,x,y,r,n,3.5,7,8.5);
}

module screw3mm5(stage,x,y,r,n=2)
{ // 7.2mm wide, 8.75mm high, 3.5mm spacing, low profile screw terminals, e.g. RS 790-1149
	screw(stage,x,y,r,n,3.5,7.2,8.75,3.7,3.2);
}


module d24v5f3(x,y,r=0,pcb=1.6)
{ // Pololu regulator using only 3 pins
	posn(x,y,25.4*0.4,25.4*0.5,r)
	{
		translate([0,0,-pcb-2.8])
		cube([25.4*0.4,25.4*0.5,2.8]);
		pads(25.4*0.05,25.4*0.05,1.2,3,3);

	}
}

module milligrid(x,y,r=0,n=2,pcb=1.6)
{
	posn(x,y,2.6+n*2,6.4,r)
	{
		translate([0,0,-pcb-6.3])
		cube([2.6+n*2,6.4,6.3001]);
		// Wires
		translate([0.5,0.5,-pcb-6.3-20])
		cube([pcb+n*2,5.4,20.001]);
		// pads
		pads(2.3,2.2,1,1,n,2,2,2);
	}
}

module smd1206(x,y,r=0)
{
	posn(x,y,3.2,1.6,r)
	{
		cube([3.2,1.6,1]);
		translate([-0.5,-0.5,0])
		cube([3.2+1,1.6+1,0.5]); // Solder
	}
}

module smdrelay(x,y,r=0)
{
	posn(x,y,4.4,3.9,r)
	{
		cube([4.4,3.9,3]);
		translate([-1.5,0,0])
		cube([4.4+3,3.9,1]);	// Solder
	}
}

module spox(x,y,r=0,n=2)
{
	posn(x,y,(n-1)*2.5+4.9,4.9,r)
	{
    		cube([(n-1)*2.5+4.9,4.9,4.9]);
    		cube([(n-1)*2.5+4.9,5.9,3.9]);
    		hull()
    		{
        		cube([(n-1)*2.5+4.9,7.9,0.5]);
        		cube([(n-1)*2.5+4.9,7.4,1]);
    		}
    		translate([4.9/2-0.3,0,0])
    		cube([(n-1)*2.5+0.6,6.6+0.3,2.38+0.3]);
    		translate([0,-20,0])
    		cube([(n-1)*2.5+4.9,20,4.9]);
	}
}
