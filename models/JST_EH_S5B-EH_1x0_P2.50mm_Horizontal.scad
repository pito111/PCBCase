b(2.5*(n/2)-1.25,5+3.6,0,2.5*n+2.5,6+10,4);
b(2.5*(n/2)-1.25,0,0,2.5*n+2.5,3.2,1.5);
if(!hulled)for(a=[0:1:n-1])translate([2.5*a,0,-3.2])cylinder(d1=1,d2=2,h=2.21,$fn=8);
