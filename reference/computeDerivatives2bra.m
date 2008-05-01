function [fx,fy,ft] = computeDerivatives2bra(im1,im2)

% im1 and im2 are images
%
% [fx,fy,ft] are images, derivatives of the input images
filter = [0.03504 0.24878 0.43234 0.24878 0.03504];
dfilter = [0.10689 0.28461 0.0  -0.28461  -0.10689];

dx1 = conv2sep(im1,dfilter,filter,'valid');
dy1 = conv2sep(im1,filter,dfilter,'valid');
blur1 = conv2sep(im1,filter,filter,'valid');
blur2 = conv2sep(im2,filter,filter,'valid');

fx=dx1;
fy=dy1;
ft=blur2-blur1;