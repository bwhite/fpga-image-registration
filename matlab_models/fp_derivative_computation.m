% Takes in a 3x3 matrix of pixel values from a neighborhood, and computes
% the spatial derivatives (Ix,Iy) and temporal derivative (It).

% TODO investigate smoothing, and effects of using a 3x3 convolution vs 5x5
% (test with real data)
function [Ix,Iy,It]=fp_derivative_computation_3x3(J,x)
It=J(2,2);
