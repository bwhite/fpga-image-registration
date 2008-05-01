function [fig1, fig2] = createPyramid(im1,im2, level)
%CREATEPYRAMID Creates two n-level pyramid.
%   [fig1, fig2] = createPyramid(im1,im2,level) creates two pyramid of 
%   depth defined by level. Returns two struct arrays. To access array
%   information use: fig1(1).im, fig1(2).im etc
%
%   See also IMRESIZE.
%   Copyright y@s  
%   Date: Tuesday, Oct 22nd, 2002

% Assign lowest level of pyramid
fig1(1).im = im1;
fig2(1).im = im2;

% Loop to create pyramid
for i=1: level-1
    fig1(1+i).im = imresize(fig1(i).im, [size(fig1(i).im,1)/2 size(fig1(i).im,2)/2], 'bilinear');
    fig2(1+i).im = imresize(fig2(i).im, [size(fig2(i).im,1)/2 size(fig2(i).im,2)/2], 'bilinear');
end