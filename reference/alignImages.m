function [M, imOut] = alignImages(im1, im2, iterations,model,method,verbose,Minitial)
% iterations is a vector (one for each pyramid level)
% verbose = 1 shows results to screen, verbose = 2 also saves them to disk
% method = 0 is the standard matlab implementation, method = 1 is the fixed point implementation
% model is 'projective' or 'affine'
% Minitial is the initial homography, if left off 
% [1] Bergen et al., 'Hierarchicial Model-Based Motion Estimation', Proceedings
% of the Second European Conference on Computer Vision, pp. 237-252, 1992.

if(~exist('model'))
    model = 'projective';
end

if (~exist('iterations'))
	iterations = [75 30 5 2];
end

levels=length(iterations);

% Create Pyramids
[fig1, fig2] = createPyramid(im1,im2, levels);
if ~exist('Minitial')
    Minitial = eye(3);
else
    Minitial(1:2,3)=Minitial(1:2,3)/(2^levels); % Later we expect the translation to be w.r.t. the smallest pyramid level
end

for x = 1:levels
    if length(iterations) >1
        iters=iterations(x);
    else
        iters=iterations;
    end
    Minitial(1:2,3)=Minitial(1:2,3)*2;
    
    ima1 = fig1(levels-x+1).im;
    ima2 = fig2(levels-x+1).im;
   
    % Choose Projective (Steve Mann)
    if(model(1) == 'p')
        M = estMannIter2(ima1,ima2,iters,Minitial,verbose,x,method);
    end
        
    % Choose Affine
    if(model(1) == 'a')
        M = estAffineIter2(ima1,ima2,iters,Minitial,verbose,x,method);
    end

    Minitial = M;
end

imOut = warpProjective2(im2,Minitial);