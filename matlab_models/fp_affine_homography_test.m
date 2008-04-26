% Target error is less than .1 (that is SumSquaredError)
max_error=0;
sum_error=0;
num_iters=100;
for i=1:num_iters
    affine_radius=32;
    trans_radius=1024;
    coord_radius=1024;
    A=(rand(2,2)-.5)*2*affine_radius; % Generates a random affine sub matrix[-affine_rad,affine_rad]
    t=(rand(2,1)-.5)*2*trans_radius; % Generates a random translation vector[-trans_rad,trans_rad]
    x=rand(2,1)*coord_radius; % Generates a random coord vector[0,coord_rad]

    % Result using double precision floating point
    x_p=fp_affine_homography(A,t,x);

    % Result using fixed point
    affine_word=18;
    affine_whole=5;
    trans_word=25;
    trans_whole=10;
    coord_word=25;
    coord_whole=10;
    out_word=25;
    out_whole=18;
    
    A=fi(A,1,affine_word,affine_word-affine_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024);
    t=fi(t,1,trans_word,trans_word-trans_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024);
    x=fi(x,1,coord_word,coord_word-coord_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024);
    H=[A,t];
    H=[H;0 0 1];
    x_p_fp=fp_affine_homography(A,t,x);
    delx=double(x_p-double(x_p_fp));
    err=sum(delx.*delx);
    max_error=max(double(err),max_error);
    sum_error=sum_error+double(err);
end
disp(sprintf('AvgErr:%f Max Err:%f',sum_error/num_iters,max_error))