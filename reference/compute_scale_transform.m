% NOTE This is a very special kind of scaling (it was originally the standard origin centered with average distance of sqrt(2), but now this has a different effect)
function [T,Sx,Sy]=compute_scale_transform(height,width)
x_bar=[width/2;height/2];
Sx=2^-round(log2(height/4));
Sy=2^-round(log2(height/4));
% Method 2 for computing scale, maximum of all X/Y coordinates (forcing
% them to vary between 1 and 0)

T=[1 0 -x_bar(1);0 1 -x_bar(2); 0 0 1];
