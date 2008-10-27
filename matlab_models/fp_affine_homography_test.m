% Target error is less than .1 (that is SumSquaredError)
max_error=0;
sum_error=0;
num_iters=500;
for i=1:num_iters
    affine_radius=1;
    trans_radius=100;
    coord_radius=500;
    %affine_radius=64;
    %trans_radius=1024;
    %coord_radius=1024;
    A=(rand(2,2))*affine_radius; % Generates a random affine sub matrix[-affine_rad,affine_rad]
    t=(rand(2,1))*trans_radius; % Generates a random translation vector[-trans_rad,trans_rad]
    
    %A=(rand(2,2)-.5)*2*affine_radius; % Generates a random affine sub matrix[-affine_rad,affine_rad]
    %t=(rand(2,1)-.5)*2*trans_radius; % Generates a random translation vector[-trans_rad,trans_rad]
    x=round(rand(2,1)*coord_radius); % Generates a random coord vector[0,coord_rad)
    for j=1:2
        if x(j)==coord_radius
            x(j)=coord_radius - 1;
        end
    end
    A0=A;
    t0=t;
    x0=x;
    % Result using double precision floating point
    x_p=fp_affine_homography(A,t,x);

    % Result using fixed point
    affine_word=18;
    affine_whole=6;
    trans_word=22;
    trans_whole=10;
    coord_word=11;
    coord_whole=10;
    out_word=20;
    out_whole=19;
    
    A=fi(A,1,affine_word,affine_word-affine_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
    t=fi(t,1,trans_word,trans_word-trans_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
    x=fi(x,1,coord_word,coord_word-coord_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
    H=[A,t];
    H=[H;0 0 1];
    x_p_fp=fp_affine_homography(A,t,x);
    x_p_fp=fi(x_p_fp,1,out_word,out_word-out_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');% Rounding occurs here
    delx=double(x_p-double(x_p_fp));
    err=sum(delx.*delx);
    max_error=max(double(err),max_error);
    if max_error == double(err)
        disp('MaxErr')
        disp(max_error)
        disp(double(A0))
        disp(double(t0))
        disp(double(x0))
    end
    sum_error=sum_error+double(err);
end
disp(sprintf('AvgErr:%f Max Err:%f',sum_error/num_iters,max_error))