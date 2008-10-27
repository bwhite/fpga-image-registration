% Takes in a 3x3 matrix of pixel values from a neighborhood, and computes
% the spatial derivatives (Ix,Iy) and temporal derivative (It).  x is from
% the image after the J 'neighborhood' in the same spatial location as J(2,2)

% This is written in an anti-Matlab style to make it easier to port to
% VHDL.

% TODO investigate smoothing, and effects of using a 3x3 convolution vs 5x5
% (test with real data)
function [Ix,Iy,It]=fp_derivative_computation_3x3(J,x,mask_smooth,output_word,output_whole)

if ~exist('mask_smooth')
    % Method 1 - 3x3 and 3x3 derivative mask [-1 0 1] with gaussian
    % smoothing
    mask_smooth=fspecial('gaussian',[3,1],1);
end

mask_der=[-1 0 1];%.*fspecial('gaussian',[3,1],1)';

% Temporal Derivative Computation Methods
% Method 1 - Simple difference of middle pixel values
It=x-J(2,2);

% Compute J, smoothed in X and Y directions
J_smooth_y=[J(1,:)+J(2,:)+J(3,:)*mask_smooth(1)];
J_smooth_x=[J(:,1)+J(:,2)+J(:,3)*mask_smooth(1)];

% Compute derivative in opposing direction
Ix_presum=J_smooth_y.*mask_der;
Iy_presum=J_smooth_x.*mask_der';
%Ix_presum=fi(J_smooth_y.*mask_der,1,output_word,output_word-output_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024);
%Iy_presum=fi(J_smooth_x.*mask_der',1,output_word,output_word-output_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024);
Ix=sum(Ix_presum);
Iy=sum(Iy_presum);
