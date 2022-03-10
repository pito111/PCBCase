b(0,0,0,10.1,10.1,0.8);
b(0,0,0,8.5,8.5,5.5);
if(!pushed&&!hulled)translate([0,0,2.5])for(a=[[0,0,0],[90,0,0],[-90,0,0],[0,90,0]])rotate(a)for(x=[-1.6,1.6])for(y=[-1.6,1.6])translate([x,y,0])cylinder(d=2,h=10,$fn=8);
