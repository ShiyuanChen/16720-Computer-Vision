function [locs,desc] = computeBrief(im, locs, levels, compareX, compareY)
% k=sqrt(2);
%sigma0=1;
%[GaussianPyramid] = createGaussianPyramid(im, sigma0, k, levels);
nbits=size(compareX,1);
patchWidth=9;
originoffset=ceil(patchWidth/2);
halfWidth=floor(patchWidth/2);
Xoffset(:,:)=[fix((compareX(:,1)-1)./patchWidth)+1-originoffset,rem(compareX(:,1)-1,patchWidth)+1-originoffset]';
Yoffset(:,:)=[fix((compareY(:,1)-1)./patchWidth)+1-originoffset,rem(compareY(:,1)-1,patchWidth)+1-originoffset]';
count=1;
temp(:,:)=locs(:,:);
locs=zeros(1,3);
desc=zeros(1,nbits);
for i=1:size(temp,1)
    if(temp(i,1)-halfWidth>=1 && temp(i,1)+halfWidth<=size(im,2) && temp(i,2)-halfWidth>=1 && temp(i,2)+halfWidth<=size(im,1))
        locs(count,:)=temp(i,:);
        %desc(count,:)=transpose(diag(GaussianPyramid(locs(count,2)+Xoffset(2,:),locs(count,1)+Xoffset(1,:),locs(count,3)+1))<diag(GaussianPyramid(locs(count,2)+Yoffset(2,:),locs(count,1)+Yoffset(1,:),locs(count,3)+1)));
        desc(count,:)=transpose(diag(im(locs(count,2)+Xoffset(2,:),locs(count,1)+Xoffset(1,:)))<diag(im(locs(count,2)+Yoffset(2,:),locs(count,1)+Yoffset(1,:))));
        count=count+1;
    end
end