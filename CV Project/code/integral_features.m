function [ICF] = integral_features(image, feature_selection)
    nFeatures = size(feature_selection, 1);
    hog=zeros(size(image,1), size(image,2),6);
    channels=zeros(size(image,1), size(image,2), 10);
    ICF = zeros(1, nFeatures);
    
%     angles=[0,30,60,90,120,150,180];
%     [Gmag,Gdir] = imgradient(rgb2gray(image));
%     for j=1:6
%         hog(:,:,j)=Gmag.*((Gdir>=angles(j)& Gdir<angles(j+1))|(Gdir>=angles(j)-180 & Gdir<angles(j+1)-180))./sum(sum(Gmag));
%     end
    
    angles=[0,pi/6,pi/3,pi/2,pi*2/3,pi*5/6,pi];
    [Gmag,Gdir] = gradientMag(rgbConvert(image,'gray'),0,0,0,0);
    sum_Gmag = sum(Gmag(:));
    for j=1:6
        hog(:,:,j)=Gmag.*((Gdir>=angles(j)& Gdir<angles(j+1)))./sum(sum(Gmag));
%         hog(:,:,j)=Gmag.*((Gdir>=angles(j)& Gdir<angles(j+1)));
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
    
    x1 = feature_selection(:,1);
    y1 = feature_selection(:,2);
    x2 = feature_selection(:,3);
    y2 = feature_selection(:,4);
    layer = feature_selection(:,5);

    for i = 1 : nFeatures
        ICF(i) = integral_I(y2(i),x2(i),layer(i)) ...
                - integral_I(y1(i),x2(i),layer(i)) ...
                - integral_I(y2(i),x1(i),layer(i)) ...
                + integral_I(y1(i),x1(i),layer(i));
    end  
    
end