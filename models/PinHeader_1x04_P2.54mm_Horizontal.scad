n=4;
translate([-0.25,-(n-0.5)*2.54,-2.5]) // Un-cropped pins
cube([0.5,n*2.54,3]);
translate([-1.27,-(n-0.5)*2.54,-1]) // Cropped pins
cube([2.54,n*2.54,3]);
translate([-1.27,-(n-0.5)*2.54-0.25,0])
cube([100,n*2.54+0.5,2.54]);

