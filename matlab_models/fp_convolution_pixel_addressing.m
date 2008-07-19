% Produces a 2xN and 1xN matrix of coordinates (2 for x,y 1 for 1-D memory
% addressing, N is the number of memory accesses required by the method) that are used to specify the pixels accessed (in order) for
% convolution style pixel ordering.  This ordering removes the need to
% buffer entire lines/columns of image data.
% From [0,len-1] ordering, mem_addr is [0,height*width-1]
function [mem_addresses,xy_coords,conv_pos,ti_string]=fp_convolution_pixel_addressing(height,width,conv_height,row_skip,border_size)
x=0;
y=0;
xy_coords=[];
mem_addresses=[];
conv_pos=[];
if ~exist('conv_width')
    conv_width=0;
end
if ~exist('row_skip')
    row_skip=0;
end
if ~exist('border_size')
    border_size=0;
end

% Display the TI line for unit testing
width_offset=(conv_height-1)*width-1;
last_valid_y=height-conv_height-border_size-mod(height-2*border_size-conv_height,1+row_skip);
new_row_offset=width_offset-2*border_size-row_skip*width;
ti_string=sprintf('TI:{1,%d,%d,%d,%d,%d,0}',height,width,width_offset,last_valid_y,new_row_offset);
disp(ti_string)

mem_addr=border_size*width+border_size;
for i=border_size:row_skip+1:height-conv_height-border_size
    for j=border_size:width-1-border_size
        for k=0:conv_height-1
            x=j;
            y=i+k;
            xy_coords=[xy_coords;x,y];
            mem_addresses=[mem_addresses;mem_addr];
            conv_pos=[conv_pos;k];
            mem_addr=mem_addr+width;
            tmp_img=zeros(height,width);
            tmp_img(y+1,x+1)=1;
            figure(1);imagesc(tmp_img);
            pause(.1)
        end
        mem_addr=mem_addr-conv_height*width; % NOTE This multiply is known at synthesis time
        mem_addr=mem_addr+1;
    end
    mem_addr=mem_addr+2*border_size+row_skip*width;
end

num_failed=0;
for i=1:length(xy_coords)
    if (xy_coords(i,1)+xy_coords(i,2)*width)~=mem_addresses(i)
        num_failed=num_failed+1;
        disp(i)
    end
end
disp(sprintf('Num Matches Failed: %d',num_failed))