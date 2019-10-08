// 3D case for simple ESP32 device
// Copyright (c) 2019 Adrian Kennard, Andrews & Arnold Limited, see LICENSE file (GPL)

// PCBCase is normally a submodule so needs the directoy
//use <PCBCase/case.scad>
//For this example the files are in the same directory
use <case.scad>

width=20;
height=31;

// Box thickness reference to component cube
base=6;
top=5;

$fn=48;

module pcb(s=0)
{
    translate([-1,-1,0])
    { // 1mm ref edge of PCB vs SVG design
        esp32(s,2,13.354);
        spox(s,13.150,1,90,4);
        usbc(s,2.905,0.51);
        d24v5f3(s,1.665,9.554);
    }
}

case(width,height,base,top){pcb(0);pcb(-1);pcb(1);};
