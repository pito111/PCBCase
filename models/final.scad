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
		boardm();
	}
}

// Make the case

// For now this is just plotting the board
boardf();
translate([pcbwidth+casewall+10,0,0])boardb();
translate([2*(pcbwidth+casewall+10),0,0])cutf();
translate([3*(pcbwidth+casewall+10),0,0])cutb();

