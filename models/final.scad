height=casebase+pcbthickness+casetop;

module boardf()
{ // This is the board, but stretched up to make a push out in from the front
	render()
	{
		intersection()
		{
			translate([-casewall-1,-casewall-1,-casebase])
			cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,height+1]);
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
			translate([-casewall-1,-casewall-1,-casebase])
			cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,height+1]);
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
 polyhedron(points=[[0,0,0],[-height,-height,height],[-height,height,height],[height,height,height],[height,-height,height]],faces=[[0,1,2],[0,2,3],[0,3,4],[0,4,0],[4,3,2,1]]);
}

module boardpf()
{ // the push up but pyramid
	render()
		minkowski()
		{
			boardf();
			pyramid();
		}
}

module boardpb()
{ // the push down but pyramid
	render()
		minkowski()
		{
			boardb();
			scale([1,1,-1])pyramid();
		}
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
	render()
	difference()
	{
		boardpf();
		translate([-0.001,-0.001,-casebase])
		cube([pcbwidth+0.002,pcblength+0.002,height+101]);
		translate([-casewall-1,-casewall-1,1])
		cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,casetop+pcbthickness+1]);
		boardm();
	}
}

module cutb()
{ // The cut down from top in the wall
	render()
	difference()
	{
		boardpb();
		translate([-margin/2,-margin/2,-casebase])
		cube([pcbwidth+margin,pcblength+margin,height+101]);
		translate([-casewall-1,-casewall-1,-casebase-1])
		cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,casebase+1]);
		boardm();
	}
}

module case()
{ // The basic case
	hull()
	{
		translate([casewall,0,casewall])
		cube([pcbwidth+casewall*2-casewall*2,pcblength+casewall*2,height-casewall*2]);
		translate([0,casewall,casewall])
		cube([pcbwidth+casewall*2,pcblength+casewall*2-casewall*2,height-casewall*2]);
		translate([casewall,casewall,0])
		cube([pcbwidth+casewall*2-casewall*2,pcblength+casewall*2-casewall*2,height]);
	}
}

module base()
{ // The base
	render()
	{
		difference()
		{
			case();
			translate([-1,-1,casebase+pcbthickness])cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,casetop+1]);
			translate([casewall,casewall,casebase])cube([pcbwidth,pcblength,casetop+pcbthickness+1]);
			translate([casewall,casewall,casebase])boardf();
			translate([casewall,casewall,casebase])cutf();
		}
		translate([casewall,casewall,casebase])cutb();
	}
}

module top()
{
	translate([0,pcblength+casewall*2,height])rotate([180,0,0])
	{
		difference()
		{
			case();
			translate([casewall,casewall,casebase])boardb();
			minkowski()
			{
				base();
				cube([fit,fit,0.001],center=true);
			}
		}
	}
}

module test()
{
	board();
	translate([pcbwidth+casewall+10,0,0])boardf();
	translate([2*(pcbwidth+casewall+10),0,0])boardb();
	translate([3*(pcbwidth+casewall+10),0,0])boardpf();
	translate([4*(pcbwidth+casewall+10),0,0])boardpb();
	translate([4*(pcbwidth+casewall+10),0,0])cutf();
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

test();
//parts();
