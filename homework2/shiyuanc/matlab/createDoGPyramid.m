function [DoGPyramid, DoGLevels] = createDoGPyramid(GaussianPyramid, levels)
for i=1:(length(levels)-1)
    DoGPyramid(:,:,i)=GaussianPyramid(:,:,i+1)-GaussianPyramid(:,:,i);
    DoGLevels(i)=levels(i+1);
end