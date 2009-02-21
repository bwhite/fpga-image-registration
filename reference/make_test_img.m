function img=make_test_img()
img=zeros(480,640);
for i=1:480
    for j=1:640
        img(i,j)=mod((i-1)*640+(j-1),2^9);
    end
end
img=img/2^9;