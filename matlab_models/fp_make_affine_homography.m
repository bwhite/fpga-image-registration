function h=make_affine_homography(x)
h=[x(2)+1 x(3) x(1);x(5) x(6)+1 x(4); 0 0 1];