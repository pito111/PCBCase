// Functions to make a 3D module case
// Copyright (c) 2019 Adrian Kennard, Andrews & Arnold Limited, see LICENSE file (GPL)

// The concept is that we make a module of the PCB with attached parts, which is then used to cut out the design in a simple cuboid case
// To this end, this file has a set of functions to create the outline for different types of parts

// The case module expects one or two children, and creates the two parts of the case that clip together
// child(0) is the PCB, a cube of width, length, and height with bits attached / sticking out from that
// Typically use parts.scad for various well known parts on a PCV
// If child(1) exists it is the extra parts for cut adding to the base
// If child(2) exists it is the extra parts for cut removing from the base and adding to the top
// Origin for all items is bottom left of PCB, box sticks out around it

module case(width=20,length=20,height=20,base=2.5,top=2.5,clear=0.5,side=2.5,sidet=0.1)
{
	intersection()
	{
		casebox(width,length,height,base,top,clear,side)children(0);
		translate([0,0,base])
		{
			difference()
			{
				union()
				{
					casecut(width,length,height,base,top,side,-sidet);
					if($children>1)children(1);
				}
				if($children>2)children(2);
			}
		}
	}
	translate([width+side*3,length/2+side,(base+height+top)/2])
	rotate([180,0,0])
	translate([0,-length/2+side,-(base+height+top)/2])
	difference()
	{
		casebox(width,length,height,base,top,clear,side)children(0);
		translate([0,0,base])
		{
			difference()
			{
				union()
				{
					casecut(width,length,height,base,top,side,sidet);
					if($children>1)children(1);
				}
				if($children>2)children(2);
			}
		}
	}
}


module casebox(width,length,height,base,top,clear,side)
{
	difference()
	{
		translate([-side,-side,0])
		cube([side*2+width,side*2+length,height+base+top]); // Case
		translate([0,0,base])
		minkowski()
		{
			children(0); // PCB
			cube(clear,center=true);
		}
	}
}

module casecut(width,length,height,base,top,side,sidet)
{
	translate([-side-1,-side-1,-1-base])
	cube([side*2+width+2,side*2+length+2,base+1+height/2]);
	translate([-side/2-sidet,-side/2-sidet,height/2-1])
	cube([width+side+sidet*2,length+side+sidet*2,side/2+1]);
}
