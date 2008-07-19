% Takes in the output from the fp_convolution_pixel_addressing and
% generates output vectors for testgen use
function conv_pixel_addressing_test_gen(mem_addresses,xy_coords,conv_pos,ti_string)
for i=1:length(mem_addresses)
    disp(ti_string)
    disp(sprintf('TO:{%d,%d,%d,%d,1,0,0}',mem_addresses(i),xy_coords(i,1),xy_coords(i,2),conv_pos(i)))
end