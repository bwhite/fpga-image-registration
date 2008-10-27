%function fp_smooth_computation_3x3_test()
input_word=9;
input_whole=0;
filter_word=16;
filter_whole=0;
output_word=9;
output_whole=0;
blur_rad=1;

iters=1;
mask_smooth=fspecial('gaussian',[3 3],blur_rad);
sum_sqr=0;
max_err=0;
max_meth_diff=0;
fp_method=2;
round_mode='fix';
overflow_mode='wrap';
f=fopen('fp_smooth_computation_3x3_test_out.hdlt','w');
for i=1:iters
    % The maximum input precision is 0:0:9, thus that is what we will use
    % as opposed to the full double precision of rand(3)
    %mat_dat=rand(3);
    %mat_dat=[12:14;17:19;22:24]/(2^9);
    r=0;%x
    s=0;%y
    %mat_dat=([0 1 2; 5 6 7; 10 11 12]+repmat([r+5*s],3,3))/2^9;
    mat_dat=[415 416 417;31 32 33; 159 160 161]/2^9;
    data=fi(mat_dat,0,input_word,input_word-input_whole,'OverflowMode',overflow_mode,'RoundMode',round_mode,'MaxProductWordLength',1024,'MaxSumWordLength',1024);
    %data=fi(((2^9*ones(3)-1)/2^9),0,filter_word,input_word-input_whole,'OverflowMode',overflow_mode,'RoundMode',round_mode,'MaxProductWordLength',1024,'MaxSumWordLength',1024);
    smooth_double=sum(double(data(:)).*mask_smooth(:));
   
    
    mask_smooth_fp=fi(mask_smooth,0,filter_word,filter_word-filter_whole,'OverflowMode',overflow_mode,'RoundMode',round_mode,'MaxProductWordLength',1024,'MaxSumWordLength',1024);
    % The following enforces that the mask will sum to 1 by making the
    % middle value equal the residual
    mask_smooth_fp(2,2)=fi(1-(sum(mask_smooth_fp(:))-mask_smooth_fp(2,2)),0,filter_word,filter_word-filter_whole,'OverflowMode',overflow_mode,'RoundMode',round_mode,'MaxProductWordLength',1024,'MaxSumWordLength',1024);
    if fp_method==1
        smooth_fp=fi(sum(data(:).*mask_smooth_fp(:)),0,output_word,output_word-output_whole,'OverflowMode',overflow_mode,'RoundMode',round_mode,'MaxProductWordLength',1024,'MaxSumWordLength',1024);
    else
        tmp_nsew=mask_smooth_fp(2)*sum(data([2,4,6,8]));
        tmp_corner=mask_smooth_fp(1)*sum(data([1,3,7,9]));
        tmp_center=mask_smooth_fp(5)*data(5);
        smooth_fp=fi(tmp_nsew+tmp_corner+tmp_center,0,output_word,output_word-output_whole,'OverflowMode',overflow_mode,'RoundMode',round_mode,'MaxProductWordLength',1024,'MaxSumWordLength',1024);
    end
    test_vector_in_str=sprintf('TI:{1,%s,%s,%s,%s,%s,%s,%s,%s,%s}\n',dec(data(1,1)),dec(data(1,2)),dec(data(1,3)),dec(data(2,1)),dec(data(2,2)),dec(data(2,3)),dec(data(3,1)),dec(data(3,2)),dec(data(3,3)));
    test_vector_out_str=sprintf('TO:{1,%s}\n',dec(smooth_fp));
    fwrite(f,test_vector_in_str,'char');
    fwrite(f,test_vector_out_str,'char');
    
    err=abs(double(smooth_fp)-smooth_double);
    max_err=max(err,max_err);
    sum_sqr=sum_sqr+err*err;
end
fclose(f)
disp(sqrt(sum_sqr/iters))
disp(max_err)
disp(max_meth_diff)
disp(hex(smooth_fp))