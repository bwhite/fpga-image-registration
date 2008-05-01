function [ssd_error, overlap_pct, homographies]=alignImagesDir(directory)


%% Initialize parameters
iterations = [75 30 5 2];
min_image_overlap=.3;

%% Load Images
%  im0 = imread('seq2-frame60to150-FOV60.jpg');
%  im1 = imread('Mosaic00115_Block2.bmp');

%im0 = imread('seq2-frame0to70-FOV60.jpg');
%im1 = imread('Mosaic00059_Block1.bmp');

%im0 = imread('seq2-frame0to70-FOV60.jpg');
%im1=imread('results_3/im1-diff1881.jpg');
%im0 = imread('im0_t.jpg');
%im1=imread('im1_0_minfit.jpg');

%path='/Users/brandynwhite/Documents/Data/homography_test_patterns/6/';
%im0=imread(sprintf('%s/0.pgm',path));
%file_name='1-0-0-0-1-0-3-3';
%im1=imread(sprintf('%s/%s.pgm',path,file_name));

%gt=5;
%im0 = imread(sprintf('homo_gt/%d/im0.jpg',gt));
%im1 = imread(sprintf('homo_gt/%d/im1.jpg',gt));
%im0 = imread('/Users/brandynwhite/Documents/Projects/VisionLab/SAIC/TelemetryVisualizationSAIC/DOQ_ROI_and_MiniMosaic/doq_roi_seq2_frame102-125-fov60_crop.jpg');
%im1 =
%imread('/Users/brandynwhite/Documents/Projects/VisionLab/SAIC/TelemetryVisualizationSAIC/DOQ_ROI_and_MiniMosaic/saic_vid2_mosaics/frame74-85/Aligned/GMosaic00012_crop.jpg');
cnum=15;
im0 = imread(sprintf('/Users/brandynwhite/Documents/Data/claire/claire%.4d.pgm',cnum));
im1 = imread(sprintf('/Users/brandynwhite/Documents/Data/claire/claire%.4d.pgm',cnum+1));

if(size(im0,3) > 2)
    im0 = rgb2gray(im0);
end

if(size(im1,3) > 2)
    im1 = rgb2gray(im1);
end
im0 = double(im0);
im1 = double(im1);
%im0 = imread('Photo13.jpg');
%im1 = imread('Photo14.jpg');

% im0 = imread('doq_crop.jpg');
% im1 = imread('img06.jpg');

%% Check bounds
levels=max([length(iterations) levels]);
assert(levels <= 11);

scale_factor=2^levels;
prev_y=size(im1,1);
prev_x=size(im1,2);

new_y=max([scale_factor size(im0,1) size(im1,1)]);
new_x=max([scale_factor size(im0,2) size(im1,2)]);

new_y=floor(new_y/scale_factor)*scale_factor;
new_x=floor(new_x/scale_factor)*scale_factor;

new_y=min([new_y 2^11]);
new_x=min([new_x 2^11]);
new_y=max([new_y scale_factor]);
new_x=max([new_x scale_factor]);


im0=imresize(im0,[new_y new_x]);
im1=imresize(im1,[new_y new_x]);
%% Make Nan Mask

im0=reconstruct_nan_mask(im0);
im1=reconstruct_nan_mask(im1);

%% Preprocess images
im0=normalize_image(im0,1);
im1=normalize_image(im1,1);


%% Align the images

%[M, imOut] = alignImages(im0, im1, iterations, levels, model, option);%, mask)
Minitial=eye(3);
if exist('H_im1_to_im0')
    Minitial=H_im1_to_im0;
    Minitial(1:2,3)=Minitial(1:2,3).*[new_x/prev_x;new_y/prev_y];
end



[H_im0_to_im1 imout2] = alignImages(im0, im1, iterations, 'a', 0,1);



H_im1_to_im0=inv(H_im0_to_im1);
%% Show images

H_im1_to_im0=H_im1_to_im0/H_im1_to_im0(9);

image1_warped=imtransform(im1,maketform('projective',H_im1_to_im0'), 'xdata', [1 size(im1,2)+H_im1_to_im0(7)], 'ydata', [1 size(im1,1)+H_im1_to_im0(8)]);
image1_warped=reconstruct_nan_mask(image1_warped);
figure(202);
imagesc(image1_warped);colormap 'gray'
figure(203);
image_combined=normalize_image(blend_images(im0,image1_warped));
image_blended=zeros([size(image1_warped) 3]);
image_blended(1:size(im0,1),1:size(im0,2),1)=normalize_image(im0)*255;
image_blended(1:size(image1_warped,1),1:size(image1_warped,2),2)=normalize_image(image1_warped)*255;
image_blended=uint8(image_blended);
imwrite(image_blended,'reg_res/blend_image.jpg')
imshow(image_blended);
[diff pct_overlap_pixels]=imcompare(im0,image1_warped);
disp(sprintf('Diff:%d',diff))
disp('done')

%% Write estimated image to file
%imwrite(uint8(image1_warped),sprintf('%s/(Real:%s)-Est:(%d,%d,%d|%d,%d,%d|%d-%d).pgm',path,file_name,H_im0_to_im1(1),H_im0_to_im1(2),H_im0_to_im1(3),H_im0_to_im1(4),H_im0_to_im1(5),H_im0_to_im1(6),H_im0_to_im1(7),H_im0_to_im1(8)))
%imwrite(uint8(image1_warped),sprintf('%s/(Real:%s)-Est:(%d,%d,%d|%d,%d,%d|%d-%d).pgm',path,file_name,H_im0_to_im1(1),H_im0_to_im1(2),H_im0_to_im1(3),H_im0_to_im1(4),H_im0_to_im1(5),H_im0_to_im1(6),H_im0_to_im1(7),H_im0_to_im1(8)))

%% 
im0=image_combined;