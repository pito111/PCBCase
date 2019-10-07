* PCB Case

OpenSCAD modules to make a simple box/case for a rectangular PCB with components.

Example.svg has milling/drilling for a simple PCB with an ESP32 module, 4 pin min SPOX connector and USB-C connector as well as a small regulator. The svg is as viewed from solder side of single sided PCB. Opening Example.svg in inkscape you can select each part and see the X/Y co-ordinates which are the left/bottom in mm. These have then been used in the pcb() module in Example.scad to position each part. Note that that as there is a 1mm cut around the design the X/Y is 1mm too high hence the parts being enclosed in a translate([-1,-1,0]).

The case() module has the width and height of the PCB and the width for top/bottom/side, and then includes pcb(0); pcb(-1); pcb(1); The value 0/-1/1 is a "stage" parameter used in the parts to identify if drawing the part itself (0) or an area cut away from the base box (-1) or added to the base box(1). This is simply passed to the parts to do the right thing.

The parts are drawn to cover the part itself and any solder, and pins through the board. The part is actually slightly enlarged to allow for manual placement errors, depending on the part (i.e. much less for parts with alignment holes in PCB).
