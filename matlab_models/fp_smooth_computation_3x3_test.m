%function fp_smooth_computation_3x3_test()
input_word=9;
input_whole=0;
filter_word=16;
filter_whole=0;
output_word=9;
output_whole=0;
blur_rad=1;

iters=100;
mask_smooth=fspecial('gaussian',[3 3],blur_rad);
sum_sqr=0;
max_err=0;
for i=1:iters
    % The maximum input precision is 0:0:9, thus that is what we will use
    % as opposed to the full double precision of rand(3)
    %data=fi(rand(3),0,filter_word,input_word-input_whole,'MaxProductWordLength',1024,'MaxSumWordLength',1024);
    smooth_double=sum(double(data(:)).*mask_smooth(:));
    data=fi((2^9*ones(3)-1),0,filter_word,input_word-input_whole,'MaxProductWordLength',1024,'MaxSumWordLength',1024);
    
    mask_smooth_fp=fi(mask_smooth,0,filter_word,filter_word-filter_whole,'MaxProductWordLength',1024,'MaxSumWordLength',1024);
    smooth_fp=fi(sum(data(:).*mask_smooth_fp(:)),0,filter_word,output_word-output_whole,'MaxProductWordLength',1024,'MaxSumWordLength',1024);
    err=abs(double(smooth_fp)-smooth_double);
    max_err=max(err,max_err);
    sum_sqr=sum_sqr+err*err;
end
disp(sqrt(sum_sqr/iters))
disp(max_err)