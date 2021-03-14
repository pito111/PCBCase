height=casebase+pcbthickness+casetop;

module boardf()
{ // This is the board, but stretched up to make a push out in from the front
	render()
	{
		intersection()
		{
			translate([-casewall-1,-casewall-1,-casebase-1])
			cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,height+2]);
			minkowski()
			{
				board();
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
			translate([-casewall-1,-casewall-1,-casebase-1])
			cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,height+2]);
			minkowski()
			{
				board();
				translate([0,0,-height-100])
				cylinder(h=height+100,d=margin,$fn=8);
			}
		}
	}
}

module pyramid()
{ // A pyramid
 polyhedron(points=[[0,0,0],[-height,-height,height],[-height,height,height],[height,height,height],[height,-height,height]],faces=[[0,1,2],[0,2,3],[0,3,4],[0,4,1],[4,3,2,1]]);
}

module boardm()
{ // The board with margin all around
	render()
		minkowski()
		{
			board();
			sphere(d=margin,$fn=6);
		}
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
			translate([-0.01,-0.01,-casebase-1])cube([pcbwidth+0.02,pcblength+0.02,height+2]);
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
			translate([-0.01-margin/2,-0.01-margin/2,-casebase-1])cube([pcbwidth+margin+0.02,pcblength+margin+0.02,height+2]);
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
			translate([-0.01,-0.01,-casebase-1])cube([pcbwidth+0.02,pcblength+0.02,height+2]);
		}
		translate([-casewall,-casewall,-casebase])case();
	}
}


module case(d=0)
{ // The basic case
	hull()
	{
		translate([casewall-d,0,casewall-d])
		cube([pcbwidth+casewall*2-casewall*2+d*2,pcblength+casewall*2+d*2,height-casewall*2+d*2]);
		translate([0,casewall-d,casewall-d])
		cube([pcbwidth+casewall*2+d*2,pcblength+casewall*2-casewall*2+d*2,height-casewall*2+d*2]);
		translate([casewall-d,casewall-d,0])
		cube([pcbwidth+casewall*2-casewall*2+d*2,pcblength+casewall*2-casewall*2+d*2,height+d*2]);
	}
}

module base()
{ // The base
	difference()
	{
		case();
		translate([-1,-1,casebase+pcbthickness])cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,casetop+1]);
		translate([casewall/2,casewall/2,casebase])cube([pcbwidth+casewall,pcblength+casewall,casetop+pcbthickness+1]);
		translate([casewall,casewall,casebase-fit])boardf();
		translate([casewall,casewall,casebase])cutpf();
	}
	difference()
	{
		translate([casewall,casewall,casebase])cutpb();
		translate([casewall/2,casewall/2,casebase])cube([pcbwidth+casewall,pcblength+casewall,casetop+pcbthickness+1]);
	}
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
				translate([casewall/2+fit/2,casewall/2+fit/2,casebase])cube([pcbwidth+casewall-fit,pcblength+casewall-fit,casetop+pcbthickness+1]);
			}
			translate([casewall,casewall,casebase-fit])boardb();
			translate([casewall,casewall,casebase])cutpb();
		}
		difference()
		{
			translate([casewall,casewall,casebase])cutpf();
			difference()
			{
				translate([-1,-1,-1])cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,casebase+pcbthickness+1]);
				translate([casewall/2+fit/2,casewall/2+fit/2,casebase])cube([pcbwidth+casewall-fit,pcblength+casewall-fit,casetop+pcbthickness+1]);
			}
		}
	}
}

module test()
{
	board();
	translate([1*(pcbwidth+casewall+10),0,0])boardf();
	translate([2*(pcbwidth+casewall+10),0,0])boardb();
	translate([3*(pcbwidth+casewall+10),0,0])cutpf();
	translate([4*(pcbwidth+casewall+10),0,0])cutpb();
	translate([5*(pcbwidth+casewall+10),0,0])cutf();
	translate([6*(pcbwidth+casewall+10),0,0])cutb();
	translate([7*(pcbwidth+casewall+10),0,0])case();
	translate([8*(pcbwidth+casewall+10),0,0])base();
	translate([9*(pcbwidth+casewall+10),0,0])top();
}

module parts()
{
	base();
	translate([pcbwidth+casewall+10,0,0])top();
}

//cutpb();
parts();
