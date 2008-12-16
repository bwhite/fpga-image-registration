coord_bits=10;
for i=1:100
    fp_make_Ab_matrix(2*(rand()-.5)*2^(coord_bits-1),2*(rand()-.5)*2^(coord_bits-1),2*(rand()-.5),2*(rand()-.5),2*(rand()-.5),coord_bits-1,1);
end
