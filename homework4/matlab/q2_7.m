load('../data/templeCoords.mat');
x2=zeros(length(x1),1);
y2=zeros(length(y1),1);
for i=1:length(x1)
    [ x2(i), y2(i) ] = epipolarCorrespondence( im1, im2, F, x1(i), y1(i) );
end
[ cloud, ~ ] = triangulate( M1, [x1,y1], M2, [x2,y2] );
scatter3(cloud(:,1),cloud(:,2),cloud(:,3),'.');