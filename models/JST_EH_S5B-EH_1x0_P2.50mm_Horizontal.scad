b(2.5*(n/2)-1.25,5+3.6,0,2.5*n+2.5,6+10,4);
b(2.5*(n/2)-1.25,0,0,2.5*n+2.5,3.2,1.5);
if(!hulled)for(a=[0:1:n-1])translate([2.5*a,0,-3])cylinder(d1=0.5,d2=2,h=2.01,$fn=12);
