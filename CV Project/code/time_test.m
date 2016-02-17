source = '../INRIAPerson/Test/pos/';
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
image = (imread([source, all_imagenames{1}]));


%% Use naive Ghist and Gmaganitude calculation
tic
angles=[0,30,60,90,120,150,180];
[Gmag,Gdir] = imgradient(rgb2gray(image));
temp = Gdir;
temp(temp<0) = temp(temp<0)+180;
Gmag = temp;
for j=1:6
    hog(:,:,j)=Gmag.*((Gdir>=angles(j)& Gdir<angles(j+1))|(Gdir>=angles(j)-180 & Gdir<angles(j+1)-180))./sum(sum(Gmag));
end
toc
% Elapsed time is 0.100710 seconds.


%% Use PDollar gradientMag
tic
I=rgbConvert(image,'gray');
[Gx,Gy]=gradient2(I); 
M=sqrt(Gx.^2+Gy.^2); 
O=atan2(Gy,Gx);
toc
% Elapsed time is 0.020805 seconds.

tic
full=0; 
[M1,O1]=gradientMag(I,0,0,0,full);
toc
% Elapsed time is 0.010513 seconds.

% The difference between the 2 meghods
D=abs(M-M1); 
mean2(D), if(full), o=pi*2; else o=pi; end
D=abs(O-O1); 
D(~M)=0; 
D(D>o*.99)=o-D(D>o*.99); 
mean2(abs(D))
toc


%% Updated naive Ghist and Gmaganitude calculation
tic
angles=[0,pi/6,pi/3,pi/2,pi*2/3,pi*5/6,pi];
[Gmag,Gdir] = gradientMag(rgbConvert(image,'gray'),0,0,0,full);
sum_Gmag = sum(Gmag(:));

for j=1:6
    hog(:,:,j)=Gmag.*((Gdir>=angles(j)& Gdir<angles(j+1)))/sum_Gmag;
end
toc
% Elapsed time is 0.040921 seconds.
% Save 0.06 sec per training image => 1 min per 1000 training image.


