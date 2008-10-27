% Produces a 2xN and 1xN matrix of coordinates (2 for x,y 1 for 1-D memory
% addressing, N is the number of memory accesses required by the method) that are used to specify the pixels accessed (in order) for
% convolution style pixel ordering.  This ordering removes the need to
% buffer entire lines/columns of image data.
% From [0,len-1] ordering, mem_addr is [0,height*width-1]
% conv_width is optional, if it is omitted
function [xy_coords,mem_addresses]=fp_convolution_pixel_addressing(height,width,conv_height,row_skip)
x=0;
y=0;
mem_addr=0;
xy_coords=[];
mem_addresses=[];
if ~exist('conv_width')
    conv_width=0;
end
if ~exist('row_skip')
    row_skip=1;
end

for i=0:row_skip:height-conv_height
    for j=0:width-1
        for k=0:conv_height-1
            x=j;
            y=i+k;
            xy_coords=[xy_coords;x,y];
            mem_addresses=[mem_addresses;mem_addr];
            mem_addr=mem_addr+width;
            tmp_img=zeros(height,width);
            tmp_img(y+1,x+1)=1;
            figure(1);imagesc(tmp_img);
            pause(.2)
        end
        mem_addr=mem_addr-conv_height*width; % NOTE This multiply is known at synthesis time
        mem_addr=mem_addr+1;
    end
end

num_failed=0;
for i=1:length(xy_coords)
    if (xy_coords(i,1)+xy_coords(i,2)*width)~=mem_addresses(i)
        num_failed=num_failed+1;
        disp(i)
    end
end
disp(sprintf('Num Matches Failed: %d',num_failed))