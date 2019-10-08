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

module case(width=20,length=20,base=2.5,top=2.5,side=2.5,sidet=0.2,pcb=1.6)
{
	// Base
	intersection()
	{
		casebox(width,length,base,top,side,-sidet/2,pcb)children(0);
		casecut(width,length,base,top,side,-sidet/2,pcb)
		{
			if($children>1)children(1);
			if($children>2)children(2);
		}
	}
	// Lid
	translate([width+side*3,length/2+side,(base+pcb+top)/2])
	rotate([180,0,0])
	translate([0,-length/2-side,-(base+pcb+top)/2])
	difference()
	{
		casebox(width,length,base,top,side,sidet/2,pcb)children(0);
		casecut(width,length,base,top,side,sidet/2,pcb)
		{
			if($children>1)children(1);
			if($children>2)children(2);
		}
	}
}

module casebox(width,length,base,top,side,sidet,pcb)
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
			cube([width,length,pcb]); // PCB
			translate([0,0,pcb])
			children();
		}
	}
}

module casecut(width,length,base,top,side,sidet,pcb)
{ // The base cut
	difference()
	{
		offset=pcb/2+0.8;
		union()
		{
			translate([-1,-1,-1])
			cube([side*2+width+2,side*2+length+2,base+1+offset-side+(sidet>0?-sidet:0)]);
			hull()
			{
				translate([side/2-sidet/2,side/2-sidet/2,base+offset-0.001-side+(sidet>0?-sidet:0)])
				cube([width+side+sidet,length+side+sidet,0.001]);
				translate([side/2,side/2,base+offset-0.001])
				cube([width+side,length+side,0.001]);
			}
			if($children>0)translate([side,side,base+pcb])minkowski()
			{
				children(0);
				if(sidet>0)cube([sidet/2,sidet/2,0.01],center=true);
			}
		}
		if($children>1)translate([side,side,base+pcb])minkowski()
		{
			children(1);
			if(sidet<0)cube([-sidet/2,-sidet/2,0.001],center=true);
		}
		if(sidet<0)translate([side,side,base+sidet])cube([width,length,pcb+top+1]);
	}
	if(sidet>0)translate([side,side,-1])cube([width,length,pcb+base+1+sidet]);
}
