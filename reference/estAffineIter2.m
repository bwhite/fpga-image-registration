function M = estAffineIter2(im1,im2,numIters,M,verbose,level,method)
[T,sx,sy] = compute_scale_transform(size(im1,1),size(im1,2)); % This is a constant for each image size
% Each iteration warps the images according to the previous
% estimate, and estimates the residual motion.
blur_rad=1;
% Incrementally estimate the correct transform
if method==1
    im1=conv2(im1,fspecial('gaussian',[3,3],blur_rad),'same'); % Smooth first
end
max_M=zeros(3,3);
for iter=1:numIters
   imWarp2=warpProjective2(im2,M);
%   if method==1
        %imWarp2=conv2(imWarp2,fspecial('gaussian',[3,3],blur_rad),'same');
%   end
   % Show output on a figure window
   if verbose>=1
        figure(532);imagesc(imWarp2);colormap('gray')
   end

   % Save output
   if verbose==2
       mkdir('reg_res')
       mkdir('reg_res/im1');
       mkdir('reg_res/im2');
       tmp_im1=uint8(255*normalize_image(imresize(im1,[240 320])));
       tmp_rgb_im1=uint8(ones([240 320 3]));
       tmp_rgb_im1(:,:,1)=tmp_im1;
       tmp_rgb_im1(:,:,2)=tmp_im1;
       tmp_rgb_im1(:,:,3)=tmp_im1;
       imwrite(tmp_rgb_im1,sprintf('reg_res/im1/affim1-%.3d-%.3d.jpg',level,iter));
        
       
       tmp_im2=uint8(255*normalize_image(imresize(imWarp2,[240 320])));
       tmp_rgb_im2=uint8(ones([240 320 3]));
       tmp_rgb_im2(:,:,1)=tmp_im2;
       tmp_rgb_im2(:,:,2)=tmp_im2;
       tmp_rgb_im2(:,:,3)=tmp_im2;
       imwrite(tmp_rgb_im2,sprintf('reg_res/im2/affim2-%.3d-%.3d.jpg',level,iter));
   end
   
   % Compute homography
   deltaM=estAffine2(im1,imWarp2,T,sx,sy,method);
   M=deltaM*M;
   max_M=max(abs(M),max_M);
end
if verbose==1
    disp(sprintf('Max |M| for level %d',level))
    disp(max_M)
end