// Functions to make a 3D module case
// Copyright (c) 2019 Adrian Kennard, Andrews & Arnold Limited, see LICENSE file (GPL)

// The concept is that we make a module of the PCB with attached parts, which is then used to cut out the design in a simple cuboid case
// To this end, this file has a set of functions to create the outline for different types of parts

// The case module expects one or two children, and creates the two parts of the case that clip together
// child(0) is the PCB, a cube of width, length, and height with bits attached / sticking out from that
// Typically use parts.scad for various well known parts on a PCV
// If child(1) exists it is the extra parts for cut removed from base (e.g. parts stage -1)
// If child(2) exists it is the extra parts for cut added to base (e.g. parts stage 1)
// Origin for all items is bottom left of PCB, box sticks out around it

module case(width=20,length=20,base=2.5,top=2.5,side=3,sidet=0.25,margin=0.5,pcb=1.6,cutoffset=0)
{
	// Base
	intersection()
	{
		casebox(width,length,base,top,side,-sidet/2,margin,pcb)children(0);
		casecut(width,length,base,top,side,-sidet/2,margin,pcb,cutoffset)
		{
			if($children>1)children(1);
			if($children>2)children(2);
		}
	}
	// Lid
	translate([width>length?0:width+side*3,(width>length?length+side*3:0)+length/2+side,(base+pcb+top)/2])
	rotate([180,0,0])
	translate([0,-length/2-side,-(base+pcb+top)/2])
	difference()
	{
		casebox(width,length,base,top,side,sidet/2,margin,pcb)children(0);
		casecut(width,length,base,top,side,sidet/2,margin,pcb,cutoffset)
		{
			if($children>1)children(1);
			if($children>2)children(2);
		}
	}
}

module grow(x,y,z)
{ // Simple grow
	if(x>0||y>0||z>0)
	{
		minkowski()
		{
			children();
			cube([x>0?x:0.001,y>0?y:0.001,z>0?z:0.001],center=true);
		}
	}else children();
}

module casebox(width,length,base,top,side,sidet,margin,pcb)
{ // The box
	difference()
	{
		hull()
		{
			translate([side/2,side/2,0])
			cube([side+width,side+length,pcb+base+top]); // Case
			translate([0,0,side/2])
			cube([side*2+width,side*2+length,pcb+base+top-side]); // Case
		}
		translate([side,side,base+sidet])
		{
			translate([-margin,-margin,0])
			cube([width+margin*2,length+margin*2,pcb]); // PCB
			translate([0,0,pcb])
			children();
		}
	}
}

module casecut(width,length,base,top,side,sidet,margin,pcb,cutoffset)
{ // The base cut
	difference()
	{
		offset=pcb/2+0.8+cutoffset;
		union()
		{
			translate([-1,-1,-1])
			cube([side*2+width+2,side*2+length+2,base+1+offset-side]);
			difference()
			{
				union()
				{
					hull()
					{
						translate([side/2-margin/2-sidet/2,side/2-margin/2-sidet/2,base+offset-side])
						cube([width+side+margin+sidet,length+side+margin+sidet,side-side/4]);
						translate([side/2-margin/2-sidet/2+side/4,side/2-margin/2-sidet/2+side/4,base+offset-side])
						cube([width+side+margin+sidet-side/2,length+side+margin+sidet-side/2,side]);
					}
					hull()
					{
						translate([side/2-margin/2-sidet/2-side/4,side/2-margin/2-sidet/2-side/4,base+offset-side])
						cube([width+side+margin+sidet+side/2,length+side+margin+sidet+side/2,0.001]);
						translate([side/2-margin/2-sidet/2+side/4,side/2-margin/2-sidet/2+side/4,base+offset-side])
						cube([width+side+margin+sidet-side/2,length+side+margin+sidet-side/2,side/4]);
					}
				}
				translate([side+margin,side+margin,0])
				cube([width-margin*2,length-margin*2,base+pcb+top]);
			}
			if($children>0)translate([side,side,base+pcb])grow(margin,margin,0)children(0);
			if(sidet>0)translate([side-margin,side-margin,-1])cube([width+margin*2,length+margin*2,pcb+base+1]);
		}
		if($children>1)translate([side,side,base+pcb])grow(margin,margin,0)children(1);
		if(sidet<0)translate([side-margin,side-margin,base])cube([width+margin*2,length+margin*2,pcb+top+1]);
	}
}

// Functions for parts attached to PCB

// Origins are top left of PCB, so typically translated -1,-1,1.6 from pcb() to allow for 1 mm margin on SVGs
// The stage parameter is used to allow these functions to be called for pcb(), and cut()
// Stage=0 is the PCB part
// Stage=1 adds to box base
// Stage=-1 cuts in to box base
// Only parts that expect to "stick out" from the case do anything for the cut stages

module posn(x,y,w,h,r,vx=0.2,vy=0.2,vz=0,smd=0)
{ // Positioning and rotation and growing for placement errors
	s=sin(r);
	c=cos(r);
	translate([x+(s>0?h*s:0)+(c<0?-w*c:0),y+(c<0?-h*c:0)+(s<0?-w*s:0),0])
	rotate([0,0,r])
	translate([smd?w:0,0,-smd])
	rotate([0,smd?180:0,0])
	grow(vx,vy,vz)children();
}

module pads(x,y,d=1.2,h=2.5,nx=1,dx=2.54,ny=1,dy=2.54)
{ // PCB pad, x/y are centre of pin
	for(px=[0:1:nx-1])
	for(py=[0:1:ny-1])
	translate([x+px*dx,y+py*dy,-0.001])
	cylinder(d1=4,d2=d,h=h+0.001,$fn=8);
}

module esp32(stage,x,y,r=0)
{ // Corner of main board of ESP32 18mm by 25.5mm
	posn(x,y,18,25.5,r,1,0.5,0) // Note left/right margin for placement
	{
		if(!stage)
		{
			cube([18,25.5,1]);	// Base PCB
    			translate([1,1,0])
    			cube([16,18,3]);		// Can
    			translate([-0.5,1,0])
    			cube([19,18,2]); // Solder
		}else{ // Cut
			translate([0,15.5,0])
			hull()
			{
				translate([0,0,stage/4+0.5])
				cube([18,10,0.001]);	// Base PCB
				translate([-10,0,stage*20])
				cube([18+20,10,1]);
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
	screw(stage,x,y,r,n,3.5,7.2,8.75,3.7,3);
}


module d24v5f3(stage,x,y,r=0,pcb=1.6,smd=0)
{ // Pololu regulator using only 3 pins
	if(!stage)
	posn(x,y,25.4*0.4,25.4*0.5,r,smd=smd?pcb:0)
	{
		translate([0,0,-pcb-2.8])
		cube([25.4*0.4,25.4*0.5,2.8]);
		if(!smd)pads(25.4*0.05,25.4*0.05,1.2,3,3);
	}
}

module milligrid(stage,x,y,r=0,n=2,pcb=1.6)
{ // eg RS part 6700927
	if(!stage)
	posn(x,y,2.6+n*2,6.4,r,0.4,0.4)
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


module molex(stage,x,y,r=0,nx=1,ny=1,pcb=1.6)
{ // Simple molex pins
	if(!stage)
	posn(x,y,2.54*nx,2.54*ny,r)
	{
		translate([0,0,-pcb-2.54])
		cube([nx*2.54,ny*2.54,2.5401]);
		for(px=[0:1:nx-1])
		for(py=[0:1:ny-1])
		translate([px*nx+2.54/2-0.5,py*ny+2.54/2-0.5,-9])
		cube([1,1,9.001]);
		pads(2.54/2,2.54/2,1,3.5-1.6,nx,2.54,ny,2.54);
	}
}

module smd1206(stage,x,y,r=0)
{ // Simple 1206, e.g RS part 866-2729
	if(!stage)
	posn(x,y,3.2,1.6,r,0.6,0.6)
	{
		cube([3.2,1.6,1]);
		translate([-0.5,-0.5,0])
		cube([3.2+1,1.6+1,0.5]); // Solder
	}
}

module smdrelay(stage,x,y,r=0)
{ // Solid state relay RS part 6839012
	if(!stage)
	posn(x,y,4.4,3.9,r,0.6,0.6)
	{
		cube([4.4,3.9,3]);
		translate([-1.5,0,0])
		cube([4.4+3,3.9,2]);	// Solder and tags
	}
}

module spox(stage,x,y,r=0,n=2,pcb=1.6,hidden=false,smd=0)
{
	w=(n-1)*2.5+4.9;
	posn(x,y,w,7.9,r,smd=smd?pcb:0)
	{
		if(!stage)
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
				translate([0,-20,-pcb-4.9])
    				cube([w,20,4.9]);
			}
		}else if(!hidden)
		{ // Cut
			translate([0,-20,-pcb-2])
			hull()
			{
				translate([0,0,(smd?-1:1)*stage/2])
				cube([w,28,1]);
				translate([0,0,(smd?-1:1)*stage*20])
				cube([w,28,1]);
			}
		}
	}
}

module usbc(stage,x,y,r=0)
{ // https://www.toby.co.uk/signal-to-board-connectors/usb-connectors/csp-usc16-tr/
	posn(x,y,8.94,7.35,r)
	{
		if(!stage)
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
		}else{ // Cut
			translate([0,-20,3.26/2-0.5])
			hull()
			{
				translate([-1.5,0,stage/2])
				cube([8.94+3,20.49,1]);
				translate([-5,0,stage*20])
				cube([8.94+10,20.49,1]);
			}
		}
	}
}

module oled(stage,x=0,y=0,r=0,d=5,h=6,pcb=1.6,nopads=false,screw=2,smd=0)
{ // OLED module e.g. https://www.amazon.co.uk/gp/product/B07BDMG2DK
	// d / h are the pillars
	posn(x,y,45,37,r,smd=smd?pcb:0)
	{
		if(!stage)
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
			cube([45,37,h+1.6]);
			for(px=[2.75,42.25])
            		for(py=[2.5,34.5])
            		translate([px,py,-h-pcb])
			{
            			if(d>5)cylinder(d=d,h=h); // Pillar
				if(screw)
				translate([0,0,-1.6-screw])
				cylinder(d=4.99,h=screw+pcb+h+1.6+screw); // Screws (smaller to avoid silly in OpenSCAD clashing with cube)
			}
		        translate([5,0,-pcb-h-1.6-2])
        		cube([35,37,2.001]); // Glass
			// Window for view
			hull()
			{
            			translate([7.5,1.5,-pcb-h-1.6-2-1])
            			cube([30,28,1]);
            			translate([7.5-5,2-5,-h-pcb-1.6-2-1-20])
            			cube([30+10,28+10,1]);
			}
		}else{ // cut
			if(d>5)
			{ // Allow larger pillars to slide in!
				for(px=[2.75,42.25])
            			for(py=[2.5,34.5])
            			translate([px,py,-pcb-h/2-10+(10+h/2)*stage])
				cylinder(d=d+0.001,h=20); // 0.001 is to fix issue with OpenSCAD
			}
		}
	}
}

module co2(stage,x,y,r=0,pcb=1.6)
{ // E.g. RS part 172-0552
	if(!stage)
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

module switch66(stage,x,y,r,pcb=1.6,height=5,nohole=false,smd=0)
{
	if(!stage)
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
				translate([2,2,0])
				cylinder(d=4,h=20);	// Poke hole
			}
		}else
		{
				cube([6,6,4]); // Body
				translate([-2,0,0])
				cube([10,6,2]);	// Leads
				translate([2,2,0])
				cylinder(d=4,h=height); // Button
				if(!nohole)
				translate([3,3,0])
				cylinder(d=2,h=20);	// Poke hole
		}
	}
}

module l80(stage,x,y,r)
{ // L80 GPS (RS 908-4085)
	if(!stage)
	posn(x,y,16,16,r,0.5,0.5)
	{
		cube([16,16,2.3]);
		translate([0.5,0.5,0])
		cube([15,15,7]);
	}
}

module l86(stage,x,y,r)
{ // L86 GPS (RS 908-4114)
	if(!stage)
	posn(x,y,18.4,18.4,r,0.5,0.5)
	{
		cube([18.4,18.4,7]);
	}
}

module bat1220(stage,x,y,r)
{ // 1220 battery holder
	if(!stage)
	posn(x,y,13.5,13.5,r)
	{
		cube([13.5,13.5,4]);
		translate([-2,3,0])
		cube([13.5+4,9,2]); // Solder
	}
}
