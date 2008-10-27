function out_img=reconstruct_nan_mask(img)
orig_img=img;
if ndims(img)==3
    img=rgb2gray(img);
end
thresh_img=img(:)==0;
thresh_img=reshape(thresh_img,size(img,1),size(img,2));
[label_img num_labels]=bwlabel(thresh_img);
largest_label_elements=[];
min_area=.05*numel(img);
for label_iter=1:num_labels
    temp_label_elements=find(label_img(:) == label_iter);
    temp_area=length(temp_label_elements);
    if temp_area > min_area
        largest_label_elements=[largest_label_elements; temp_label_elements];
    end
end
if length(largest_label_elements) >= .05*numel(img) % Only modify if the impact is on at least a certain amount of the image
    mask_img=ones(size(img));
    mask_img(largest_label_elements)=NaN;
    out_img=zeros(size(orig_img));
    if ndims(orig_img)==3
        out_img(:,:,1)=double(orig_img(:,:,1)).*mask_img;
        out_img(:,:,2)=double(orig_img(:,:,2)).*mask_img;
        out_img(:,:,3)=double(orig_img(:,:,3)).*mask_img;
    else
        out_img=double(orig_img).*mask_img;
    end
else
    out_img=orig_img;
end
