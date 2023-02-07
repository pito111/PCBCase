n=5;
translate([-0.25,-(n-0.5)*2.54,-2.5]) // Un-cropped pins
cube([0.5,n*2.54,3]);
translate([-0.25,-(n-0.5)*2.54,-1]) // Cropped pins
cube([0.5,n*2.54,1.5]);
translate([-1.27,-(n-0.5)*2.54,0]) // Plug
cube([3,n*2.54,2.54]);
translate([1.27,-(n-0.5)*2.54-0.25,0]) // Plug
cube([10,n*2.54+0.5,2.54+0.5]);
