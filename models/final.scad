module boardf()
{
	render()
	{
		intersection()
		{
			minkowski()
			{
				board();
				cylinder(h=casetop+pcbthickness+casebase+100,d=margin,$fn=6);
			}
			translate([-casewall-1,-casewall-1,-casebase])
			cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,casebase+casetop+pcbthickness+1]);
		}
	}
}

module boardb()
{
	render()
	{
		intersection()
		{
			minkowski()
			{
				board();
				h=casetop+pcbthickness+casebase+100;
				translate([0,0,-h])
				cylinder(h=h,d=margin,$fn=6);

			}
			translate([-casewall-1,-casewall-1,-casebase])
			cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,casebase+casetop+pcbthickness+1]);
		}
	}
}

module boardm()
{
	render()
		minkowski()
		{
			board();
			sphere(d=margin,$fn=6);
		}
}

module cutf()
{
	difference()
	{
		boardf();
		translate([-margin/2,-margin/2,-casebase])
		cube([pcbwidth+margin,pcblength+margin,casebase+casetop+pcbthickness+101]);
		translate([-casewall-1,-casewall-1,1])
		cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,casetop+pcbthickness+1]);
		boardm();
	}
}

module cutb()
{
	difference()
	{
		boardb();
		translate([-margin/2,-margin/2,-casebase])
		cube([pcbwidth+margin,pcblength+margin,casebase+casetop+pcbthickness+101]);
		translate([-casewall-1,-casewall-1,-casebase-1])
		cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,casebase+1]);
		boardm();
	}
}

module case()
{
	hull()
	{
		translate([casewall,0,casewall])
		cube([pcbwidth+casewall*2-casewall*2,pcblength+casewall*2,casebase+pcbthickness+casetop-casewall*2]);
		translate([0,casewall,casewall])
		cube([pcbwidth+casewall*2,pcblength+casewall*2-casewall*2,casebase+pcbthickness+casetop-casewall*2]);
		translate([casewall,casewall,0])
		cube([pcbwidth+casewall*2-casewall*2,pcblength+casewall*2-casewall*2,casebase+pcbthickness+casetop]);
	}
}

module base()
{
	difference()
	{
		case();
		translate([-1,-1,casebase+pcbthickness/2])cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,casetop+pcbthickness]);
		translate([casewall,casewall,casebase])boardf();
	}
	translate([casewall,casewall,casebase])cutb();
}

module top()
{
	translate([0,pcblength+casewall*2,casebase+casetop+pcbthickness])rotate([180,0,0])
	{
		difference()
		{
			case();
			translate([-1,-1,-1])cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,casebase+pcbthickness]);
			translate([casewall,casewall,casebase])boardb();
		}
		translate([casewall,casewall,casebase])cutf();
	}
}

module test()
{
	board();
	translate([pcbwidth+casewall+10,0,0])boardf();
	translate([2*(pcbwidth+casewall+10),0,0])boardb();
	translate([3*(pcbwidth+casewall+10),0,0])cutf();
	translate([4*(pcbwidth+casewall+10),0,0])cutb();
	translate([5*(pcbwidth+casewall+10),0,0])case();
	translate([6*(pcbwidth+casewall+10),0,0])base();
	translate([7*(pcbwidth+casewall+10),0,0])top();
}

module parts()
{
	base();
	translate([pcbwidth+casewall+10,0,0])top();
}

//test();
parts();
