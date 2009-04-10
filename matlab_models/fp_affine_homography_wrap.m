disp('\n\n')
for kjdkfj=1:20
    A=rand(2)*2;
    t=rand(2,1)*5;
    x=rand(2,1)*480;
    A=[10 0; 0 10];
    t=rand(2,1)*480;
    x=480*rand(2,1);
    % Result using fixed point
    affine_word=18;
    affine_whole=6;
    trans_word=22;
    trans_whole=10;
    coord_word=10;
    coord_whole=10;
    out_word=20;
    out_whole=19;

    A=fi(A,1,affine_word,affine_word-affine_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','floor');
    t=fi(t,1,trans_word,trans_word-trans_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','floor');
    x=fi(x,0,coord_word,coord_word-coord_whole,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','floor');
    x_p_fp=fp_affine_homography(A,t,x);
    x_p_fp=fi(x_p_fp,0,coord_word,coord_word-coord_whole,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','floor');% Rounding occurs here

    out='TI:{1';
    for i=1:2
        out=strcat(out,sprintf(',16#%s#',hex(x(i))));
    end
    for i=1:4
        out=strcat(out,sprintf(',16#%s#',hex(A(i))));
    end
    for i=1:2
        out=strcat(out,sprintf(',16#%s#',hex(t(i))));
    end
    out=strcat(out,'}');
    disp(out)

    out='TO:{';
    for i=1:2
        out=strcat(out,sprintf('16#%s#,',hex(x_p_fp(i))));
    end
    disp(strcat(out,'0,0,1}'));
end
disp('')