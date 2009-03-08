function [Ix,Iy,It]=fp_derivative_computation_3x3_test(im1,im2)
%Ix=zeros(size(im1)-2);
%Iy=zeros(size(im1)-2);
%It=zeros(size(im1)-2);

img_word=10;
img_whole=0;


img1=fi(im1,1,img_word,img_word-img_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
img2=fi(im2,1,img_word,img_word-img_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
It=img2(3:end-2,3:end-2)-img1(3:end-2,3:end-2);
Ix=img1(3:end-2,4:end-1)-img1(3:end-2,2:end-3);
Iy=img1(4:end-1,3:end-2)-img1(2:end-3,3:end-2);


% for i=3:(size(im1,1)-2)
%      for j=3:(size(im1,2)-2)
%          disp(hex(img1((i-1):(i+1),(j-1):(j+1))))
%      end 
%  end

function [Ix,Iy,It]=fp_derivative_computation_3x3_module(img0,img1_1_1)
%img_word=10;
%img_whole=0;

%img0=fi(img0,1,img_word,img_word-img_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
%img1_1_1=fi(img1_1_1,1,img_word,img_word-img_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');

Ix = img0(2,3)-img0(2,1);
Iy = img0(3,2)-img0(1,2);
It = img1_1_1-img0(2,2);

%Ix=fi(Ix,1,img_word,img_word-img_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
%Iy=fi(Iy,1,img_word,img_word-img_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
%It=fi(It,1,img_word,img_word-img_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');

%if rand() < .01
%    disp(sprintf('TI:{16#%s#,16#%s#,16#%s#,16#%s#,16#%s#,16#%s#,0,0,0,0}\nTO:{16#%s#,16#%s#,16#%s#,0,0,0,0}',hex(img0(1,2)),hex(img0(2,1)),hex(img0(2,2)),hex(img0(2,3)),hex(img0(3,2)),hex(img1_1_1),hex(Ix),hex(Iy),hex(It)))
%end
