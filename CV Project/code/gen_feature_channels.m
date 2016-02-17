function [integral_I] = gen_feature_channels(image)
    hog=zeros(size(image,1), size(image,2),6);
    channels=zeros(size(image,1), size(image,2), 10);

    angles=[0,pi/6,pi/3,pi/2,pi*2/3,pi*5/6,pi];
    [Gmag,Gdir] = gradientMag(rgbConvert(image,'gray'),0,0,0,0);
    sum_Gmag = sum(Gmag(:));
    for j=1:6
%         hog(:,:,j)=Gmag.*((Gdir>=angles(j)& Gdir<angles(j+1)))./sum_Gmag;
        hog(:,:,j)=Gmag.*((Gdir>=angles(j)& Gdir<angles(j+1)));
    end
    
    channels(:,:,2:7)=hog;
    channels(:,:,1)=Gmag;
    channels(:,:,8:10)= rgbConvert(image, 'luv')/255.0;
    s=zeros(size(channels));
    integral_I=zeros(size(channels));
    integral_I(1,1,:)=channels(1,1,:);
    s(1,1,:)=channels(1,1,:);
    s(2,1,:)=channels(2,1,:);
    integral_I(2,1,:)=integral_I(1,1,:)+s(2,1,:);
    for k=2:size(channels,2) 
        s(1,k,:)=s(1,k-1,:)+channels(1,k,:);
        integral_I(1,k,:)=s(1,k,:);
    end
    for j=2:size(channels,1)
        s(j,1,:)=channels(j,1,:);
        integral_I(j,1,:)=integral_I(j-1,1,:)+s(j,1,:);
    end
    for j=2:size(channels,1)
        for k=2:size(channels,2)
            s(j,k,:)=s(j,k-1,:)+channels(j,k,:);
            integral_I(j,k,:)=integral_I(j-1,k,:)+s(j,k,:);
        end
    end
    
end