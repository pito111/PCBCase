* PCB Case

This is a bit of a mixture of stuff.

There is some openscad code that allows manual set up of a PCB design for use when making milled designs. Example.scad shows how to use that.

There is also newer C code. This is designs to take an kicad_pcb file and produce an openscad file that is the case.
The problem is that you need 3D models for your parts for this to work sensibly, so the C code has a list of footprints as basic openscad outlines. This is not like the 3D models in KiCad which are accurate, it is simply boxes and shapes that allow for the 3D box to have a sensibly sized cut out for the part.
In many cases this means the model is just a cuboid. But in some cases it is slightly more important as it has the attached connector included.
Any parts of the design that would breach the case cause cut outs and supports in the case surround.
