function PrincipalCurvature = computePrincipalCurvature(DoGPyramid)

PrincipalCurvature=zeros(size(DoGPyramid,1),size(DoGPyramid,2),size(DoGPyramid,3));
for i=1:size(DoGPyramid,3)
    [Dx,Dy]=gradient(DoGPyramid(:,:,i));
    [Dxx,Dyx]=gradient(Dx);
    [Dxy,Dyy]=gradient(Dy);
    PrincipalCurvature(:,:,i)=((Dxx+Dyy).^2)./abs((Dxx.*Dyy)-Dxy.*Dyx);
end