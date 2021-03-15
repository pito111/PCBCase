{
	translate([0,0,6])cube([44.4999,37,1.5999]);
	translate([5.25,0,6])cube([34,37,3.2]);
	translate([2.5,2.5,0])cylinder(d=5,h=6,$fn=7);
	translate([2.5,37-2.5,0])cylinder(d=5,h=6,$fn=7);
	translate([44.5-2.5,2.5,0])cylinder(d=5,h=6,$fn=7);
	translate([44.5-2.5,37-2.5,0])cylinder(d=5,h=6,$fn=7);
	translate([2.5,2.5,7])cylinder(d=4.99,h=1.6,$fn=24); // screws
	translate([2.5,37-2.5,7])cylinder(d=4.99,h=1.6,$fn=24);
	translate([44.5-2.5,2.5,7])cylinder(d=4.99,h=1.6,$fn=24);
	translate([44.5-2.5,37-2.5,7])cylinder(d=4.99,h=1.6,$fn=24); 
	translate([2.5,2.5,-2.6])cylinder(d=4.99,h=1.6,$fn=24); // screws
	translate([2.5,37-2.5,-2.6])cylinder(d=4.99,h=1.6,$fn=24);
	translate([44.5-2.5,2.5,-2.6])cylinder(d=4.99,h=1.6,$fn=24);
	translate([44.5-2.5,37-2.5,-2.6])cylinder(d=4.99,h=1.6,$fn=24); 
	translate([40.73,9.61,7.5])cube([2.54,7*2.54,1.5]); // pins
	translate([7.75,1.75,7.5])cube([29,29,20]); // Display view
}
