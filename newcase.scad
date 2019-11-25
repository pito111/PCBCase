// Functions to make a 3D module case
// Copyright (c) 2019 Adrian Kennard, Andrews & Arnold Limited, see LICENSE file (GPL)

// The concept is that we make a module of the PCB with attached parts, which is then used to cut out the design in a simple cuboid case
// To this end, this file has a set of functions to create the outline for different types of parts

module case(	width=20,	// Inner width
		length=20,	// Inner height
		base=2.5,	// Base thickness
		top=2.5,	// Top thickness
		side=3,		// Side thickness
		sidet=0.2,	// Side tolerance
		margin=0.4,	// Inner parts tolerance
		pcb=1.6,        // PCB thickness
                cutoffset=0,    // Adjust level at which case is cut in half
		baseedge=1,	// Edge on base
		topedge=1,	// Edge on top
		sideedge=1	// Edge on side
	   )
{
	*translate([width+10,0,0])
	{ // Debug
		translate([side,side,base+pcb])
		children();
	}
	difference()
	{ // Base
		casebox(width,length,base,top,side,pcb,baseedge,topedge,sideedge);
		difference()
		{
			caseedge(width,length,base,top,side,margin,pcb);
			casecut(width,length,base,top,side,sidet/2,margin,pcb,cutoffset)children();
		}
		minkowski()
		{
			translate([side,side,base+pcb])
			children();
			translate([-margin/2,-margin/2,0])
			cube([margin,margin,base+pcb+top]);
		}
	}
	translate([width>length?0:width+side*3,(width>length?length+side*3:0)+length/2+side,(base+pcb+top)/2])
	rotate([180,0,0])
	translate([0,-length/2-side,-(base+pcb+top)/2])
	difference()
	{ // Lid
		casebox(width,length,base,top,side,pcb,baseedge,topedge,sideedge);
		casecut(width,length,base,top,side,-sidet/2,margin,pcb,cutoffset)children();
		minkowski()
		{
			translate([side,side,base+pcb])
			children();
			translate([-margin/2,-margin/2,-base-pcb-top])
			cube([margin,margin,base+pcb+top]);
		}
	}
}

// General functions

module grow(x,y,z)
{ // Simple grow
	if(x>0||y>0||z>0)
	{
		minkowski()
		{
			children();
			cube([x>0?x:0.0001,y>0?y:0.0001,z>0?z:0.0001],center=true);
		}
	}else children();
}

module vcut(margin,dir=1)
{ // Calculate cut
	minkowski()
	{
		difference()
		{
			translate([0,0,dir*0.0001])
			children();
			children();
		}
		hull()
		{
			translate([-margin/2,-margin/2,1+dir/2])
			cube([margin,margin,1]);
			translate([-margin/2-15,-margin/2-15,100*dir])
			cube([margin+30,margin+30,1]);
		}
	}
}

module casebox(width,length,base,top,side,pcb,baseedge,topedge,sideedge)
{ // The box
	hull()
	{	// Case
		translate([baseedge/2+sideedge,baseedge/2,0])
		cube([side*2+width-baseedge-sideedge*2,side*2+length-baseedge,baseedge]);
		translate([baseedge/2,baseedge/2+sideedge,0])
		cube([side*2+width-baseedge,side*2+length-baseedge-sideedge*2,baseedge]);
		translate([sideedge,0,baseedge])
		cube([side*2+width-sideedge*2,side*2+length,pcb+base+top-baseedge-topedge]);
		translate([0,sideedge,baseedge])
		cube([side*2+width,side*2+length-sideedge*2,pcb+base+top-baseedge-topedge]);
		translate([topedge/2+sideedge,topedge/2,pcb+base+top-topedge])
		cube([side*2+width-topedge-sideedge*2,side*2+length-topedge,topedge]);
		translate([topedge/2,topedge/2+sideedge,pcb+base+top-topedge])
		cube([side*2+width-topedge,side*2+length-topedge-sideedge*2,topedge]);
	}
}

module casecut(width,length,base,top,side,sidet,margin,pcb,cutoffset)
{ // Cutting the case
	cut=base+pcb/2-side/2+cutoffset;
	s=(side-margin/2)/4;
	intersection()
	{
		caseedge(width,length,base,top,side,margin,pcb);
		union()
		{
			cube([width+side*2,length+side*2,cut]);
			hull()
			{
				translate([s*3+sidet/2,s*3+sidet/2,0])
				cube([width+margin+2*s-sidet,length+margin+2*s-sidet,cut+side]);
				translate([s*2+sidet/2,s*2+sidet/2,0])
				cube([width+margin+4*s-sidet,length+margin+4*s-sidet,cut+side-s]);
			}
			hull()
			{
				translate([s*1+sidet/2,s*1+sidet/2,cut-1])
				cube([width+margin+6*s-sidet,length+margin+6*s-sidet,1]);
				translate([s*2+sidet/2,s*2+sidet/2,0])
				cube([width+margin+4*s-sidet,length+margin+4*s-sidet,cut+s]);
			}
		}
	}
}

module caseedge(width,length,base,top,side,margin,pcb)
{ // Case edge
	difference()
	{
		cube([width+side*2,length+side*2,base+pcb+top]);
		translate([side-margin/2,side-margin/2,-1])
		cube([width+margin,length+margin,base+pcb+top+2]);
	}
}

// Functions for parts attached to PCB

// Origins are top left of PCB, so typically translated -1,-1,1.6 from pcb() to allow for 1 mm margin on SVGs

module posn(x,y,w,h,r=0,vx=0.2,vy=0.2,vz=0,smd=0)
{ // Positioning and rotation and growing for placement errors
	s=sin(r);
	c=cos(r);
	translate([x+(s>0?h*s:0)+(c<0?-w*c:0),y+(c<0?-h*c:0)+(s<0?-w*s:0),0])
	rotate([0,0,r])
	translate([smd?w:0,0,-smd])
	rotate([0,smd?180:0,0])
	grow(vx,vy,vz)
	children();
}

module pads(x,y,d=1.2,h=2.5,nx=1,dx=2.54,ny=1,dy=2.54)
{ // PCB pad, x/y are centre of pin
	for(px=[0:1:nx-1])
	for(py=[0:1:ny-1])
	translate([x+px*dx,y+py*dy,0])
	cylinder(d1=4,d2=d,h=h,$fn=8);
}

module esp32(x,y,r=0)
{ // Corner of main board of ESP32 18mm by 25.5mm
	posn(x,y,18,25.5,r,1,0.5,0) // Note left/right margin for placement
	{
		cube([18,25.5,1]);	// Base PCB
    		translate([1,1,0])
    		cube([16,18,3]);		// Can
    		translate([-0.5,1,0])
    		cube([19,18,2]); // Solder
	}
}

module screw(x,y,r=0,n=2,d,w,h,yp,ys,s=3,pcb=1.6)
{ // Corner of outline
	posn(x,y,d*n,w,r)
	{
		pads(d/2,yp?yp:w/2,1.2,3.5-pcb,n,d);
		// Body
		translate([0,0,-pcb-h])
		cube([d*n,w,h]);
		// Screws
		for(px=[0:1:n-1])
		translate([d/2+d*px,ys?ys:w/2,-pcb-20-h])
		cylinder(d=s,h=20);
		// Wires
		for(px=[0:1:n-1])
		translate([d/2+d*px-(d-1)/2,-20,-pcb-1-(d-1)])
		cube([d-1,20,d-1]);
	}
}

module screw5mm(x,y,r,n=2)
{ // 8.1mm wide, 10mm high, 5mm spacing, low profile screw terminals, e.g. RS 897-0843
	screw(x,y,r,n,5,8.1,10);
}

module screw3mm5a(x,y,r,n=2)
{ // 7mm wide, 8.5mm high, 3.5mm spacing, low profile screw terminals, e.g. RS 144-4314
	screw(x,y,r,n,3.5,7,8.5);
}

module screw3mm5(x,y,r,n=2)
{ // 7.2mm wide, 8.75mm high, 3.5mm spacing, low profile screw terminals, e.g. RS 790-1149
	screw(x,y,r,n,3.5,7.2,8.75,3.7,3);
}


module d24v5f3(x,y,r=0,pcb=1.6,smd=0)
{ // Pololu regulator using only 3 pins
	posn(x,y,25.4*0.4,25.4*0.5,r,smd=smd?pcb:0)
	{
		translate([0,0,-pcb-2.8])
		cube([25.4*0.4,25.4*0.5,2.8]);
		if(!smd)pads(25.4*0.05,25.4*0.05,1.2,3,3);
	}
}

module milligrid(x,y,r=0,n=2,pcb=1.6)
{ // eg RS part 6700927
	posn(x,y,2.6+n*2,6.4,r,0.4,0.4)
	{
		translate([0,0,-pcb-6.3])
		cube([2.6+n*2,6.4,6.3]);
		// Wires
		translate([0.5,0.5,-pcb-6.3-20])
		cube([pcb+n*2,5.4,20]);
		// pads
		pads(2.3,2.2,1,1,n,2,2,2);
	}
}


module molex(x,y,r=0,nx=1,ny=1,pcb=1.6)
{ // Simple molex pins
	posn(x,y,2.54*nx,2.54*ny,r)
	{
		translate([0,0,-pcb-2.54])
		cube([nx*2.54,ny*2.54,2.5401]);
		for(px=[0:1:nx-1])
		for(py=[0:1:ny-1])
		translate([px*nx+2.54/2-0.5,py*ny+2.54/2-0.5,-9])
		cube([1,1,9]);
		pads(2.54/2,2.54/2,1,3.5-1.6,nx,2.54,ny,2.54);
	}
}

module smd1206(x,y,r=0)
{ // Simple 1206, e.g RS part 866-2729
	posn(x,y,3.2,1.6,r,0.6,0.6)
	{
		cube([3.2,1.6,1]);
		translate([-0.5,-0.5,0])
		cube([3.2+1,1.6+1,0.5]); // Solder
	}
}

module smdrelay(x,y,r=0)
{ // Solid state relay RS part 6839012
	posn(x,y,4.4,3.9,r,0.6,0.6)
	{
		cube([4.4,3.9,3]);
		translate([-1.5,0,0])
		cube([4.4+3,3.9,2]);	// Solder and tags
	}
}

module spox(x,y,r=0,n=2,pcb=1.6,hidden=false,smd=0)
{
	w=(n-1)*2.5+4.9;
	posn(x,y,w,7.9,r,smd=smd?pcb:0)
	{
		if(!smd)pads(2.45,7.5,1.2,2.5,n,2.5);
		translate([0,0,-pcb-4.9])
		cube([w,4.9,4.9]);
		translate([0,0,-pcb-3.9])
    		cube([w,5.9,3.9]);
    		hull()
    		{
			translate([0,0,-pcb-0.5])
        		cube([w,7.9,0.5]);
			translate([0,0,-pcb-1])
        		cube([w,7.4,1]);
    		}
		translate([4.9/2-0.3,0,-pcb-2.38-0.3])
    		cube([w-4.9+0.6,6.6+0.3,2.38+0.3]);
		if(!hidden)
		{
			hull()
			{ // Plug to cable
				translate([0,-5,-pcb-4.9])
    				cube([w,5,4.9]);
				translate([w/2,0,-2.45-pcb])
				rotate([90,0,0])
				cylinder(d=4.9,h=15,$fn=12);
			}
			translate([w/2,0,-2.45-pcb])
			rotate([90,0,0])
			cylinder(d=4.9,h=50,$fn=12); // Cable
		}
	}
}

module usbc(x,y,r=0)
{ // https://www.toby.co.uk/signal-to-board-connectors/usb-connectors/csp-usc16-tr/
	posn(x,y,8.94,7.35,r)
	{
		cube([8.94,7.35,3.26/2]);
		cube([8.94,8,0.5]);	// Solder
		hull()
		{
			translate([-1,1.88-1,0])
			cube([8.94+2,1.4+2,0.5]); // Solder
			translate([-0.4,1.88-0.4,0])
			cube([8.94+0.8,1.4+0.8,1.5]); // Solder
		}
		hull()
		{
			translate([-1,5.91-1,0])
			cube([8.94+2,1.7+2,0.5]); // Solder
			translate([-0.4,5.91-0.4,0])
			cube([8.94+0.8,1.7+0.8,1.5]); // Solder
		}
		// Posts
		for(px=[-0.155,8.495])
		{
			translate([px,1.88,-1])
			cube([0.9,1.4,1]);
			translate([px,5.91,-1])
			cube([0.9,1.7,1]);
		}
		for(px=[1.28+.3,7.06+0.3])
		translate([px,5.98+.3,-1])
		cylinder(d=0.6,h=1);
		// lead and body
		translate([3.26/2,-2,3.26/2])
		rotate([-90,0,0])
		{
			hull()
			{
				cylinder(d=3.26,h=2+7.35);
				translate([8.94-3.26,0,0])
				cylinder(d=3.26,h=2+7.35);
			}
			// Body of plug
			translate([0,0,-20])
			hull()
			{
				cylinder(d=7,h=20.5);
				translate([8.94-3.26,0,0])
				cylinder(d=7,h=20.5);
			}
		}
	}
}

module oled(x=0,y=0,r=0,d=5,h=6,pcb=1.6,nopads=false,screw=2,smd=0)
{ // OLED module e.g. https://www.amazon.co.uk/gp/product/B07BDMG2DK
	// d / h are the pillars
	posn(x,y,45,37,r,0.5,0.5,smd=smd?pcb:0)
	{
		if(!nopads&&!smd)
		{
			pads(2.75,9.61,0.9,2,ny=2);
			pads(2.75,9.61+3*2.54,0.9,2,ny=2);
		}
		translate([0,0,-pcb-h-1.6])
		mirror([0,0,1])
		{
			pads(2.75,9.61,0.9,2,ny=2);
			pads(2.75,9.61+3*2.54,0.9,2,ny=2);
		}
		translate([0,0,-pcb-h-1.6])
		cube([45,37,h+1.6]); // Main board
		for(px=[2.75,42.25])
           		for(py=[2.5,34.5])
           		translate([px,py,-h-pcb])
		{
           			if(d>5)cylinder(d=d,h=h); // Pillar
			if(screw)
			translate([0,0,-1.6-screw])
			cylinder(d=4.99,h=screw+pcb+h+1.6+screw); // Screws (smaller to avoid silly in OpenSCAD clashing with cube)
		}
		g=1.6;
	        translate([5,0,-pcb-h-1.6-g])
       		cube([35,37,g]); // Glass
		translate([4,35,-pcb-h-1.6-g-0.2])
		cube([37,3,h+pcb+1.6+g+0.2]);	// The bit that breaks far too easily
		translate([4,30,-pcb-h-1.6-g-0.2])
		cube([2,8,h+pcb+1.6+g+0.2]);	// The bit that breaks far too easily
		translate([39,30,-pcb-h-1.6-g-0.2])
		cube([2,8,h+pcb+1.6+g+0.2]);	// The bit that breaks far too easily
		// Window for view
		hull()
		{
           			translate([7.5,1.5,-pcb-h-1.6-g-1])
           			cube([30,28,1]);
           			translate([7.5-5,2-5,-h-pcb-1.6-g-1-20])
           			cube([30+10,28+10,1]);
		}
	}
}

module co2(x,y,r=0,pcb=1.6)
{ // E.g. RS part 172-0552
	posn(x,y,23,35,r)
	{
		translate([0,0,-pcb-7])
                cube([23,35,7]); // Main CO2
		pads(1.27,1.27,ny=4);
		// Hole
		translate([12,-20,-pcb-5.6])
                cube([3,20,1]); // Air hole
	}
}

module switch66(x,y,r=0,pcb=1.6,height=5,nohole=false,smd=0)
{
	posn(x,y,6,6,r,smd=smd?pcb:0)
	{
		if(smd)
		{
			translate([0,0,-5-pcb])
			{
				cube([6,6,5]);
				translate([-2,0,0])
				cube([10,6,4]);	// Leads
				if(!nohole)
				translate([3,3,0])
				cylinder(d=4,h=20);	// Poke hole
			}
		}else
		{
				cube([6,6,4]); // Body
				translate([-2,0,0])
				cube([10,6,2]);	// Leads
				translate([3,3,0])
				cylinder(d=4,h=height); // Button
				if(!nohole)
				translate([3,3,0])
				cylinder(d=2,h=20);	// Poke hole
		}
	}
}

module l96(x,y,r=0)
{ // L96 GPS
	posn(x,y,9.6,14,r,1,1)
	{
		cube([9.6,14,2]);
	}
}

module l80(x,y,r=0)
{ // L80 GPS (RS 908-4085)
	posn(x,y,16,16,r,1,1)
	{
		cube([16,16,2.3]);
		translate([0.5,0.5,0])
		cube([15,15,7]);
	}
}

module l86(x,y,r=0)
{ // L86 GPS (RS 908-4114)
	posn(x,y,18.4,18.4,r,1,1)
	{
		cube([18.4,18.4,7]);
	}
}

module bat1220(x,y,r=0)
{ // 1220 battery holder
	posn(x,y,13.2,12.5,r)
	{
		cube([13.2,12.5,4]);
		translate([-2,3,0])
		cube([13.2+4,9,2]); // Solder
	}
}
