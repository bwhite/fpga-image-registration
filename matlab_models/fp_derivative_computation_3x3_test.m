function [Ix,Iy,It]=fp_derivative_computation_3x3_test(im1,im2)
Ix=zeros(size(im1)-4);
Iy=zeros(size(im1)-4);
It=zeros(size(im1)-4);
blur_rad=1;
der_conv=[1 0 -1];
It=im2(3:size(im2,1)-2,3:size(im2,2)-2)-im1(3:size(im2,1)-2,3:size(im2,2)-2);
im_x=conv2(im1,der_conv,'same');
im_y=conv2(im1,der_conv','same');
Ix=im_x(3:size(im2,1)-2,3:size(im2,2)-2);
Iy=im_y(3:size(im2,1)-2,3:size(im2,2)-2);

% input_word=9;
% input_whole=0;
% filter_word=25;
% filter_whole=0;
% output_word=26; % Signed
% output_whole=0;

% Method 1 - 3x3 and 3x3 derivative mask [-1 0 1] with gaussian smoothing
% mask_smooth=fspecial('gaussian',[3,1],1);
% %mask_smooth=fi(fspecial('gaussian',[3,1],1),0,filter_word,filter_word-filter_whole,'MaxProductWordLength',1024,'MaxSumWordLength',1024);
% %mask_smooth=fi([0,1,0],1,filter_word,filter_word-filter_whole-1,'MaxProduc
% %tWordLength',1024,'MaxSumWordLength',1024);
% for i=3:size(im1,1)-2
%     for j=3:size(im1,2)-2
%         neighborhood_data=im1(i-1:i+1,j-1:j+1);
%         %neighborhood_data=fi(im1(i-1:i+1,j-1:j+1),0,input_word,input_word-input_whole,'MaxProductWordLength',1024,'MaxSumWordLength',1024);
%         if ~isnan(im2(i,j))
%             new_image_pix=im2(i,j);
%             %new_image_pix=fi(im2(i,j),0,input_word,input_word-input_whole,'MaxProductWordLength',1024,'MaxSumWordLength',1024);    
%             [Ix_t,Iy_t,It_t]=fp_derivative_computation_3x3(neighborhood_data,new_image_pix,mask_smooth,output_word,output_whole);
%             Ix(i-2,j-2)=double(Ix_t);
%             Iy(i-2,j-2)=double(Iy_t);
%             It(i-2,j-2)=double(It_t);
%         else
%             Ix(i-2,j-2)=double(NaN);
%             Iy(i-2,j-2)=double(NaN);
%             It(i-2,j-2)=double(NaN);
%         end
%     end
% end
