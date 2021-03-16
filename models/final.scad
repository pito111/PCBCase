height=casebase+pcbthickness+casetop;

module boardf()
{ // This is the board, but stretched up to make a push out in from the front
	render()
	{
		intersection()
		{
			translate([-casewall-1,-casewall-1,-casebase-1]) cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,height+2]);
			minkowski()
			{
				board(true);
				cylinder(h=height+100,d=margin,$fn=8);
			}
		}
	}
}

module boardb()
{ // This is the board, but stretched down to make a push out in from the back
	render()
	{
		intersection()
		{
			translate([-casewall-1,-casewall-1,-casebase-1]) cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,height+2]);
			minkowski()
			{
				board(true);
				translate([0,0,-height-100])
				cylinder(h=height+100,d=margin,$fn=8);
			}
		}
	}
}

module boardm()
{
	render()
	{
		minkowski()
		{
			sphere(d=margin,$fn=8);
			board(false);
		}
	}
}

module pyramid()
{ // A pyramid
 polyhedron(points=[[0,0,0],[-height,-height,height],[-height,height,height],[height,height,height],[height,-height,height]],faces=[[0,1,2],[0,2,3],[0,3,4],[0,4,1],[4,3,2,1]]);
}

module cutf()
{ // This cut up from base in the wall
	intersection()
	{
		boardf();
		difference()
		{
			translate([-casewall+0.01,-casewall+0.01,-casebase+0.01])cube([pcbwidth+casewall*2-0.02,pcblength+casewall*2-0.02,casebase+pcbthickness]);
			translate([-0.01-margin/2,-0.01-margin/2,-casebase-1])cube([pcbwidth+margin+0.02,pcblength+margin+0.02,height+2]);
			boardb();
		}
	}
}

module cutb()
{ // The cut down from top in the wall
	intersection()
	{
		boardb();
		difference()
		{
			translate([-casewall+0.01,-casewall+0.01,0.01])cube([pcbwidth+casewall*2-0.02,pcblength+casewall*2-0.02,casetop+pcbthickness]);
			translate([-0.01-margin/2,-0.01-margin/2,-casebase-1])cube([pcbwidth+margin+0.02,pcblength+margin+0.02,height+2]);
			boardf();
		}
	}
}

module cutpf()
{ // the push up but pyramid
	render()
	intersection()
	{
		minkowski()
		{
			pyramid();
			cutf();
		}
		difference()
		{
			translate([-casewall-0.01,-casewall-0.01,-casebase-0.01])cube([pcbwidth+casewall*2+0.02,pcblength+casewall*2+0.02,casebase+pcbthickness+0.02]);
			translate([0.01-margin/2,0.01-margin/2,-casebase-1])cube([pcbwidth+margin-0.02,pcblength+margin+0.02,height+2]);
			board(true);
		}
		translate([-casewall,-casewall,-casebase])case();
	}
}

module cutpb()
{ // the push down but pyramid
	render()
	intersection()
	{
		minkowski()
		{
			scale([1,1,-1])pyramid();
			cutb();
		}
		difference()
		{
			translate([-casewall-0.01,-casewall-0.01,-0.01])cube([pcbwidth+casewall*2+0.02,pcblength+casewall*2+0.02,casetop+pcbthickness+0.02]);
			translate([0.01-margin/2,0.01-margin/2,-casebase-1])cube([pcbwidth+margin-0.02,pcblength+margin+0.02,height+2]);
			board(true);
		}
		translate([-casewall,-casewall,-casebase])case();
	}
}


module case()
{ // The basic case
	hull()
	{
		translate([edge,0,edge])
		cube([pcbwidth+casewall*2-edge*2,pcblength+casewall*2,height-edge*2]);
		translate([0,edge,edge])
		cube([pcbwidth+casewall*2,pcblength+casewall*2-edge*2,height-edge*2]);
		translate([edge,edge,0])
		cube([pcbwidth+casewall*2-edge*2,pcblength+casewall*2-edge*2,height]);
	}
}

module cut(d=0)
{
	hull()
	{
		translate([casewall/2-d/2-margin/4+casewall/3,casewall/2-d/2-margin/4,casebase])
			cube([pcbwidth+casewall+d+margin/2-2*casewall/3,pcblength+casewall+d+margin/2,casetop+pcbthickness+1]);
		translate([casewall/2-d/2-margin/4,casewall/2-d/2-margin/4+casewall/3,casebase])
			cube([pcbwidth+casewall+d+margin/2,pcblength+casewall+d+margin/2-2*casewall/3,casetop+pcbthickness+1]);
	}
}

module base()
{ // The base
	difference()
	{
		case();
		difference()
		{
			union()
			{
				translate([-1,-1,casebase+pcbthickness])cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,casetop+1]);
				cut(fit);
			}
			translate([casewall,casewall,casebase])cube([pcbwidth,pcblength,pcbthickness+casetop]);
		}
		translate([casewall,casewall,casebase-fit/2])boardf();
		translate([casewall,casewall,casebase])boardm();
		translate([casewall,casewall,casebase])cutpf();
	}
	translate([casewall,casewall,casebase])cutpb();
}

module top()
{
	translate([0,pcblength+casewall*2,height])rotate([180,0,0])
	{
		difference()
		{
			case();
			difference()
			{
				translate([-1,-1,-1])cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,casebase+pcbthickness+1]);
				cut(-fit);
			}
			translate([casewall,casewall,casebase+fit/2])boardb();
			translate([casewall,casewall,casebase])boardm();
			translate([casewall,casewall,casebase])cutpb();
		}
		translate([casewall,casewall,casebase])cutpf();
	}
}

module test()
{
	translate([0*spacing,0,0])board();
	translate([1*spacing,0,0])board(true);
	translate([2*spacing,0,0])boardf();
	translate([3*spacing,0,0])boardb();
	translate([4*spacing,0,0])cutpf();
	translate([5*spacing,0,0])cutpb();
	translate([6*spacing,0,0])cutf();
	translate([7*spacing,0,0])cutb();
	translate([8*spacing,0,0])case();
	translate([9*spacing,0,0])base();
	translate([10*spacing,0,0])top();
}

module parts()
{
	base();
	translate([spacing,0,0])top();
}

if(debug)test();
else parts();
