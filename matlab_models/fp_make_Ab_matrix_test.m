for j=5:10
    coord_bits=j+1;
    for i=1:20
        fp_make_Ab_matrix(fix(4*(rand()-.5)*2^(coord_bits-1))/2,fix(4*(rand()-.5)*2^(coord_bits-1))/2,2*(rand()-.5),2*(rand()-.5),2*(rand()-.5),coord_bits-1,1);
    end
end

