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

module boardpf()
{ // the push up but pyramid
	render()
		intersection()
		{
			translate([-casewall,-casewall,-casebase])cube([pcbwidth+casewall*2,pcblength+casewall*2,height]);
			minkowski()
			{
				pyramid();
				boardf();
			}
		}
}

module boardpb()
{ // the push down but pyramid
	render()
		intersection()
		{
			translate([-casewall,-casewall,-casebase])cube([pcbwidth+casewall*2,pcblength+casewall*2,height]);
			minkowski()
			{
				scale([1,1,-1])pyramid();
				boardb();
			}
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
	intersection()
	{
		boardpf();
		difference()
		{
			translate([-casewall,-casewall,-casebase])case();
			translate([-0.01,-0.01,-casebase-1])cube([pcbwidth+0.02,pcblength+0.02,height+2]);
			boardb();
		}
	}
}

module cutb()
{ // The cut down from top in the wall
	render()
	intersection()
	{
		boardpb();
		difference()
		{
			translate([-casewall,-casewall,-casebase])case();
			translate([-0.01,-0.01,-casebase-1])cube([pcbwidth+0.02,pcblength+0.02,height+2]);
			boardf();
		}
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
	difference()
	{
		case();
		translate([-1,-1,casebase+pcbthickness])cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,casetop+1]);
		translate([casewall/2,casewall/2,casebase])cube([pcbwidth+casewall,pcblength+casewall,casetop+pcbthickness+1]);
		translate([casewall,casewall,casebase-fit])boardf();
		translate([casewall,casewall,casebase])cutf();
	}
	difference()
	{
		translate([casewall,casewall,casebase])cutb();
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
			translate([casewall,casewall,casebase])cutb();
		}
		difference()
		{
			translate([casewall,casewall,casebase])cutf();
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
	translate([3*(pcbwidth+casewall+10),0,0])boardpf();
	translate([4*(pcbwidth+casewall+10),0,0])boardpb();
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

//test();
parts();
