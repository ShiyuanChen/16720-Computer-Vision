function locs = getLocalExtrema(DoGPyramid, DoGLevels, PrincipalCurvature,th_contrast, th_r)
conn(:,:,1)=[0,0,0;
             0,1,0;
             0,0,0];
conn(:,:,2)=[1,1,1;
             1,0,1;
             1,1,1];
conn(:,:,3)=[0,0,0;
             0,1,0;
             0,0,0];
%localE(:,:,:)=(imregionalmax(DoGPyramid(:,:,:),conn)|imregionalmin(DoGPyramid(:,:,:),conn))& (abs(DoGPyramid(:,:,:))>th_contrast) & (PrincipalCurvature<th_r);
localE(:,:,:)=((DoGPyramid(:,:,:)>imdilate(DoGPyramid(:,:,:),conn)) | ((-DoGPyramid(:,:,:))>imdilate((-DoGPyramid(:,:,:)),conn))) & (abs(DoGPyramid(:,:,:))>th_contrast) & (PrincipalCurvature<th_r);
[locs(:,2),locs(:,1)]=find(localE);
%locs(:,3)=DoGLevels(fix(locs(:,1)./size(DoGPyramid,2))+1);
locs(:,3)=fix((locs(:,1)-1)./size(DoGPyramid,2))+1;
locs(:,1)=rem(locs(:,1)-1,size(DoGPyramid,2))+1;
         