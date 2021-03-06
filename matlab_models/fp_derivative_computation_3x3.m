% Takes in a 3x3 matrix of pixel values from a neighborhood, and computes
% the spatial derivatives (Ix,Iy) and temporal derivative (It).  x is from
% the image after the J 'neighborhood' in the same spatial location as J(2,2)

% This is written in an anti-Matlab style to make it easier to port to
% VHDL.

% TODO investigate smoothing, and effects of using a 3x3 convolution vs 5x5
% (test with real data)
function [Ix,Iy,It]=fp_derivative_computation_3x3(J,x,output_word,output_whole)
mask_der=[-1 0 1];

% Temporal Derivative Computation Methods
% Method 1 - Simple difference of middle pixel values
It=x-J(2,2);

% Compute J, smoothed in X and Y directions
J_smooth_y=J(1,:)+J(2,:)+J(3,:);
J_smooth_x=J(:,1)+J(:,2)+J(:,3);

% Compute derivative in opposing direction
Ix_presum=J_smooth_y.*mask_der;
Iy_presum=J_smooth_x.*mask_der';
Ix=sum(Ix_presum);
Iy=sum(Iy_presum);
