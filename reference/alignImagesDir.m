function [ssd_error, overlap_pct, homographies,dir_list,directory]=alignImagesDir(directory)
directory=strcat(directory,'/'); % Shouldn't hurt to tack this on again, as multiple doesn't change anything
mkdir('reg_res')
ssd_error=[];
overlap_pct=[];
homographies=[]; % 3Nx3 where N is the number of pairs run
%% Initialize parameters
iterations = [50 50 30 5 2];
levels=length(iterations);
verbose=1;

%% Query directory, remove non-images
dir_list=dir(directory);
dir_list=dir_list(3:size(dir_list,1)); % Take off the . and ..
dir_keep_list=[];
for i=1:length(dir_list)
    temp_name=dir_list(i).name;
    temp_len=length(temp_name);
    if temp_len < 4
        continue;
    end
    x = strmatch(temp_name(temp_len-2:temp_len), strvcat('ppm','pgm','jpg','peg'),'exact');
    if ~isempty(x)
        dir_keep_list=[dir_keep_list i];
    end
end
dir_list=dir_list(dir_keep_list);
% TODO Collect the results of this process into the necessary matrices
for i=1:(length(dir_list)-1)
%% Load Images
    im0 = imread(strcat(directory,dir_list(i).name));
    disp(strcat(directory,dir_list(i).name));
    im1 = imread(strcat(directory,dir_list(i+1).name));
    disp(strcat(directory,dir_list(i+1).name));
    if(size(im0,3) > 2)
        im0 = rgb2gray(im0);
    end

    if(size(im1,3) > 2)
        im1 = rgb2gray(im1);
    end
    im0 = double(im0);
    im1 = double(im1);

%% Check bounds
    levels=max([length(iterations) levels]);
    assert(levels <= 7);

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


    % Resize images to make them friendly to the required pyramid level
    im0=imresize(im0,[new_y new_x]);
    im1=imresize(im1,[new_y new_x]);

%% Preprocess images
    im0=normalize_image(im0,1);
    im1=normalize_image(im1,1);


%% Align the images
    Minitial=eye(3);
    if exist('H_im1_to_im0')
        Minitial=H_im1_to_im0;
        Minitial(1:2,3)=Minitial(1:2,3).*[new_x/prev_x;new_y/prev_y];
    end

    [H_im0_to_im1 imout2] = alignImages(im0, im1, iterations, 'a', 1,verbose);
    H_im1_to_im0=inv(H_im0_to_im1);
    
%% Show images

    H_im1_to_im0=H_im1_to_im0/H_im1_to_im0(9);

    image1_warped=imtransform(im1,maketform('projective',H_im1_to_im0'), 'xdata', [1 size(im1,2)+H_im1_to_im0(7)], 'ydata', [1 size(im1,1)+H_im1_to_im0(8)]);
    image1_warped=reconstruct_nan_mask(image1_warped);
    figure(202);
    imagesc(image1_warped);colormap 'gray'
    figure(203);
    image_combined=normalize_image(blend_images(im0,image1_warped),0);
    image_blended=zeros([size(image1_warped) 3]);
    image_blended(1:size(im0,1),1:size(im0,2),1)=normalize_image(im0)*255;
    image_blended(1:size(image1_warped,1),1:size(image1_warped,2),2)=normalize_image(image1_warped)*255;
    image_blended=uint8(image_blended);
    imwrite(image_blended,sprintf('reg_res/%s-%s.jpg',dir_list(i).name,dir_list(i+1).name));
    imshow(image_blended);
    [diff pct_overlap_pixels]=imcompare(im0,image1_warped);
    disp(sprintf('Diff:%d Overlap:%d',diff,pct_overlap_pixels))
    ssd_error=[ssd_error diff];
    overlap_pct=[overlap_pct pct_overlap_pixels];
    homographies=[homographies;H_im0_to_im1];
end