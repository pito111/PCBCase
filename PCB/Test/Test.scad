// Generated case design for PCB/Test/Test.kicad_pcb
// By https://github.com/revk/PCBCase
// Generated 2023-01-10 15:55:42
//

// Globals
margin=0.500000;
overlap=2.000000;
lip=0.000000;
casebase=5.000000;
casetop=5.000000;
casewall=3.000000;
fit=0.000000;
edge=1.000000;
pcbthickness=1.600000;
nohull=false;
hullcap=1.000000;
hulledge=1.000000;
useredge=false;

module pcb(h=pcbthickness,r=0){linear_extrude(height=h)offset(r=r)polygon(points=[[50.000000,0.000000],[50.000000,50.000000],[0.000000,50.000000],[0.000000,0.000000]],paths=[[0,1,2,3]]);}

module outline(h=pcbthickness,r=0){linear_extrude(height=h)offset(r=r)polygon(points=[[50.000000,0.000000],[50.000000,50.000000],[0.000000,50.000000],[0.000000,0.000000]],paths=[[0,1,2,3]]);}
spacing=66.000000;
pcbwidth=50.000000;
pcblength=50.000000;
// Populated PCB
module board(pushed=false,hulled=false){
translate([5.000000,25.000000,1.600000])rotate([0,0,90.000000])translate([0.000000,2.700000,0.000000])rotate([-90.000000,0.000000,0.000000])m0(pushed,hulled); // RevK:ESP32-PICO-MINI-02 ESP32-PICO-MINI-02 (back)
translate([25.000000,45.000000,1.600000])translate([0.000000,2.700000,0.000000])rotate([-90.000000,0.000000,0.000000])m0(pushed,hulled); // RevK:ESP32-PICO-MINI-02 ESP32-PICO-MINI-02 (back)
translate([50.000000,10.000000,1.600000])rotate([0,0,90.000000])translate([0.000000,3.385000,0.000000])rotate([-90.000000,0.000000,0.000000])m1(pushed,hulled); // RevK:USC16-TR-Round CSP-USC16-TR (back)
translate([10.500000,0.000000,1.600000])translate([0.000000,3.385000,0.000000])rotate([-90.000000,0.000000,0.000000])m1(pushed,hulled); // RevK:USC16-TR-Round CSP-USC16-TR (back)
translate([0.000000,40.000000,1.600000])rotate([0,0,-90.000000])translate([0.000000,3.385000,0.000000])rotate([-90.000000,0.000000,0.000000])m1(pushed,hulled); // RevK:USC16-TR-Round CSP-USC16-TR (back)
translate([25.000000,5.000000,1.600000])rotate([0,0,180.000000])translate([0.000000,2.700000,0.000000])rotate([-90.000000,0.000000,0.000000])m0(pushed,hulled); // RevK:ESP32-PICO-MINI-02 ESP32-PICO-MINI-02 (back)
translate([40.800000,50.500000,1.600000])rotate([0,0,180.000000])translate([0.000000,3.385000,0.000000])rotate([-90.000000,0.000000,0.000000])m1(pushed,hulled); // RevK:USC16-TR-Round CSP-USC16-TR (back)
translate([45.000000,25.000000,1.600000])rotate([0,0,-90.000000])translate([0.000000,2.700000,0.000000])rotate([-90.000000,0.000000,0.000000])m0(pushed,hulled); // RevK:ESP32-PICO-MINI-02 ESP32-PICO-MINI-02 (back)
translate([40.800000,50.500000,0.000000])rotate([180,0,0])translate([0.000000,3.385000,0.000000])rotate([-90.000000,0.000000,0.000000])m1(pushed,hulled); // RevK:USC16-TR-Round CSP-USC16-TR
translate([0.000000,40.000000,0.000000])rotate([0,0,90.000000])rotate([180,0,0])translate([0.000000,3.385000,0.000000])rotate([-90.000000,0.000000,0.000000])m1(pushed,hulled); // RevK:USC16-TR-Round CSP-USC16-TR
translate([25.000000,5.000000,0.000000])rotate([180,0,0])translate([0.000000,2.700000,0.000000])rotate([-90.000000,0.000000,0.000000])m0(pushed,hulled); // RevK:ESP32-PICO-MINI-02 ESP32-PICO-MINI-02
translate([10.500000,0.000000,0.000000])rotate([0,0,180.000000])rotate([180,0,0])translate([0.000000,3.385000,0.000000])rotate([-90.000000,0.000000,0.000000])m1(pushed,hulled); // RevK:USC16-TR-Round CSP-USC16-TR
translate([5.000000,25.000000,0.000000])rotate([0,0,-90.000000])rotate([180,0,0])translate([0.000000,2.700000,0.000000])rotate([-90.000000,0.000000,0.000000])m0(pushed,hulled); // RevK:ESP32-PICO-MINI-02 ESP32-PICO-MINI-02
translate([25.000000,45.000000,0.000000])rotate([0,0,180.000000])rotate([180,0,0])translate([0.000000,2.700000,0.000000])rotate([-90.000000,0.000000,0.000000])m0(pushed,hulled); // RevK:ESP32-PICO-MINI-02 ESP32-PICO-MINI-02
translate([50.000000,10.000000,0.000000])rotate([0,0,-90.000000])rotate([180,0,0])translate([0.000000,3.385000,0.000000])rotate([-90.000000,0.000000,0.000000])m1(pushed,hulled); // RevK:USC16-TR-Round CSP-USC16-TR
translate([45.000000,25.000000,0.000000])rotate([0,0,90.000000])rotate([180,0,0])translate([0.000000,2.700000,0.000000])rotate([-90.000000,0.000000,0.000000])m0(pushed,hulled); // RevK:ESP32-PICO-MINI-02 ESP32-PICO-MINI-02
}

module b(cx,cy,z,w,l,h){translate([cx-w/2,cy-l/2,z])cube([w,l,h]);}
module m0(pushed=false,hulled=false)
{ // RevK:ESP32-PICO-MINI-02 ESP32-PICO-MINI-02
rotate([90,0,0])
translate([-13.2/2,-16.6/2,0])
{
	if(!hulled)cube([13.2,16.6,0.8]);
	cube([13.2,11.2,2.4]);
}
}

module m1(pushed=false,hulled=false)
{ // RevK:USC16-TR-Round CSP-USC16-TR
rotate([-90,0,0])translate([-4.47,-3.84,0])
{
	translate([1.63,0,1.63])
	rotate([-90,0,0])
	hull()
	{
		cylinder(d=3.26,h=7.75,$fn=24);
		translate([5.68,0,0])
		cylinder(d=3.26,h=7.75,$fn=24);
	}
	translate([0,6.65,0])cube([8.94,1.1,1.63]);
	translate([0,2.2,0])cube([8.94,1.6,1.63]);
	if(!hulled)
	{
		// Plug
		translate([1.63,-20,1.63])
		rotate([-90,0,0])
		hull()
		{
			cylinder(d=2.5,h=21,$fn=24);
			translate([5.68,0,0])
			cylinder(d=2.5,h=21,$fn=24);
		}
		translate([1.63,-22.5,1.63])
		rotate([-90,0,0])
		hull()
		{
			cylinder(d=7,h=21,$fn=24);
			translate([5.68,0,0])
			cylinder(d=7,h=21,$fn=24);
		}
	}
}

}

height=casebase+pcbthickness+casetop;
$fn=48;

module boardh(pushed=false)
{ // Board with hulled parts
	union()
	{
		if(!nohull)intersection()
		{
			translate([0,0,hullcap-casebase])outline(casebase+pcbthickness+casetop-hullcap*2,-hulledge);
			hull()board(pushed,true);
		}
		board(pushed,false);
		pcb();
	}
}

module boardf()
{ // This is the board, but stretched up to make a push out in from the front
	render()
	{
		intersection()
		{
			translate([-casewall-1,-casewall-1,-casebase-1]) cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,height+2]);
			union()
			{
				minkowski()
				{
					boardh(true);
					cylinder(h=height+100,d=margin,$fn=8);
				}
				board(false,false);
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
			union()
			{
				minkowski()
				{
					boardh(true);
					translate([0,0,-height-100])
					cylinder(h=height+100,d=margin,$fn=8);
				}
				board(false,false);
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
			translate([0,0,-margin/2])cylinder(d=margin,h=margin,$fn=8);
 			boardh(false);
		}
		//intersection()
    		//{
        		//translate([0,0,-(casebase-hullcap)])pcb(pcbthickness+(casebase-hullcap)+(casetop-hullcap));
        		//translate([0,0,-(casebase-hullcap)])outline(pcbthickness+(casebase-hullcap)+(casetop-hullcap));
			boardh(false);
    		//}
 	}
}

module pcbh(h=pcbthickness,r=0)
{ // PCB shape for case
	if(useredge)outline(h,r);
	else hull()outline(h,r);
}

module pyramid()
{ // A pyramid
 polyhedron(points=[[0,0,0],[-height,-height,height],[-height,height,height],[height,height,height],[height,-height,height]],faces=[[0,1,2],[0,2,3],[0,3,4],[0,4,1],[4,3,2,1]]);
}

module wall(d=0)
{ // The case wall
    	translate([0,0,-casebase-d])pcbh(height+d*2,margin/2+d);
}

module cutf()
{ // This cut up from base in the wall
	intersection()
	{
		boardf();
		difference()
		{
			translate([-casewall+0.01,-casewall+0.01,-casebase+0.01])cube([pcbwidth+casewall*2-0.02,pcblength+casewall*2-0.02,casebase+overlap+lip]);
			wall();
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
			wall();
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
			translate([-casewall-0.01,-casewall-0.01,-casebase-0.01])cube([pcbwidth+casewall*2+0.02,pcblength+casewall*2+0.02,casebase+overlap+lip+0.02]);
			wall();
			boardh(true);
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
			wall();
			boardh(true);
		}
		translate([-casewall,-casewall,-casebase])case();
	}
}

module case()
{ // The basic case
	hull()
	{
		translate([casewall,casewall,0])pcbh(height,casewall-edge);
		translate([casewall,casewall,edge])pcbh(height-edge*2,casewall);
	}
}

module cut(d=0)
{ // The cut point in the wall
	translate([casewall,casewall,casebase+lip])pcbh(casetop+pcbthickness-lip+1,casewall/2+d/2+margin/4);
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
				translate([-1,-1,casebase+overlap+lip])cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,casetop+1]);
				cut(fit);
			}
		}
		translate([casewall,casewall,casebase])boardf();
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
				translate([-1,-1,-1])cube([pcbwidth+casewall*2+2,pcblength+casewall*2+2,casebase+overlap+lip-margin+1]);
				cut(-fit);
			}
			translate([casewall,casewall,casebase])boardb();
			translate([casewall,casewall,casebase])boardm();
			translate([casewall,casewall,casebase])cutpb();
		}
		translate([casewall,casewall,casebase])cutpf();
	}
}

module test()
{
	translate([0*spacing,0,0])base();
	translate([1*spacing,0,0])top();
	translate([2*spacing,0,0])pcb();
	translate([3*spacing,0,0])outline();
	translate([4*spacing,0,0])wall();
	translate([5*spacing,0,0])board();
	translate([6*spacing,0,0])board(false,true);
	translate([7*spacing,0,0])board(true);
	translate([8*spacing,0,0])boardh();
	translate([9*spacing,0,0])boardf();
	translate([10*spacing,0,0])boardb();
	translate([11*spacing,0,0])cutpf();
	translate([12*spacing,0,0])cutpb();
	translate([13*spacing,0,0])cutf();
	translate([14*spacing,0,0])cutb();
	translate([15*spacing,0,0])case();
}

module parts()
{
	base();
	translate([spacing,0,0])top();
}
test();
