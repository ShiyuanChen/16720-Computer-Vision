function [locs,desc] = computeBrief_r(im, locs, levels, compareX, compareY)
 
nbits=size(compareX,1);
patchWidth=9;
originoffset=ceil(patchWidth/2);
halfWidth=floor(patchWidth/2);
Xoffset(:,:)=[fix((compareX(:,1)-1)./patchWidth)+1-originoffset,rem(compareX(:,1)-1,patchWidth)+1-originoffset]';
Yoffset(:,:)=[fix((compareY(:,1)-1)./patchWidth)+1-originoffset,rem(compareY(:,1)-1,patchWidth)+1-originoffset]';

radius=4;
idx=1:81;
[rows,cols]=ind2sub([9,9],idx);
rows=rows-5;
cols=cols-5;
patch=zeros(2,1);
ptr=1;
for i=1:81
    if(rows(i).^2+cols(i).^2<=radius.^2)
        patch(:,ptr)=[cols(i);rows(i)];
        ptr=ptr+1;
    end
end
count=1;
temp(:,:)=locs(:,:);
locs=zeros(1,3);
theta=zeros(1);
desc=zeros(1,nbits);
for i=1:size(temp,1)
    if(temp(i,1)-halfWidth>=1 && temp(i,1)+halfWidth<=size(im,2) && temp(i,2)-halfWidth>=1 && temp(i,2)+halfWidth<=size(im,1))
        locs(count,:)=temp(i,:);
        theta(count)=atan2(sum(patch(2,:).*transpose(diag(im(locs(count,2)+patch(2,:),locs(count,1)+patch(1,:))))),sum(patch(1,:).*transpose(diag(im(locs(count,2)+patch(2,:),locs(count,1)+patch(1,:))))));
        R=[cos(theta(count)),-sin(theta(count));sin(theta(count)),cos(theta(count))];
        XoffsetR=int8(round(R*Xoffset(:,:)));
        YoffsetR=int8(round(R*Yoffset(:,:)));
        desc(count,:)=transpose(diag(im(locs(count,2)+XoffsetR(2,:),locs(count,1)+XoffsetR(1,:)))<diag(im(locs(count,2)+YoffsetR(2,:),locs(count,1)+YoffsetR(1,:))));
        count=count+1;
    end
end