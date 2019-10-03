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

module case(width=20,length=20,height=20,base=2.5,top=2.5,clear=0.5,side=2.5,sidet=0.1)
{
	// Base
	intersection()
	{
		casebox(width,length,height,base,top,clear,side)children(0);
		casecut(width,length,height,base,top,clear,side,-sidet/2)
		{
			if($children>1)children(1);
			if($children>2)children(2);
		}
	}
	// Lid
	translate([width+side*3,length/2+side,(base+height+top)/2])
	rotate([180,0,0])
	translate([0,-length/2-side,-(base+height+top)/2])
	difference()
	{
		casebox(width,length,height,base,top,clear,side)children(0);
		casecut(width,length,height,base,top,clear,side,sidet/2)
		{
			if($children>1)children(1);
			if($children>2)children(2);
		}
	}
}

module casegrow(clear)
{
	minkowski()
	{
		children();
		if(clear)cube(clear,center=true);
	}
}


module casebox(width,length,height,base,top,clear,side)
{ // The box
	difference()
	{
		hull()
		{
			translate([side/2,side/2,0])
			cube([side+width,side+length,height+base+top]); // Case
			translate([0,0,side/2])
			cube([side*2+width,side*2+length,height+base+top-side]); // Case
		}
		translate([side,side,base])
		casegrow(clear)
		{
			cube([width,length,height]);
			children();
		}
	}
}

module casecut(width,length,height,base,top,clear,side,sidet)
{ // The base cut
	difference()
	{
		union()
		{
			translate([-1,-1,-1])
			cube([side*2+width+2,side*2+length+2,base+1+height/2-side/2]);
			translate([side/2-sidet/2,side/2-sidet/2,base+height/2-1.001-side/2])
			cube([width+side+sidet,length+side+sidet,side/2+1.001]);
			if($children>0)translate([side,side,base])children(0);
		}
		if($children>1)translate([side,side,base])children(1);
		if(sidet<0)translate([side-clear/2,side-clear/2,base])cube([width+clear,length+clear,height+top+1]);
	}
	if(sidet>0)translate([side-clear/2,side-clear/2,-1])cube([width+clear,length+clear,height+base+1]);
}
