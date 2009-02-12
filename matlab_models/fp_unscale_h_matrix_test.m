
for i=1:100
    h=2*(rand(3)-.5);
    h(3,1)=0;
    h(3,2)=0;
    h(3,3)=1;
    
    fp_unscale_h_matrix(h,100*(rand()-.5),1);
end