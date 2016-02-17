im1=imread('../data/model_chickenbroth.jpg');
im1 = im2double(im1);
if size(im1,3)==3
    im1= rgb2gray(im1);
end
[locs1, desc1] = briefLite(im1);
matches=cell(36);
count=zeros(36,1);
for i=0:10:350
    im2=imrotate(im1,i,'bilinear');
    [locs2, desc2] = briefLite(im2);
    matches{i/10+1} = briefMatch(desc1, desc2);
    count(i/10+1)=size(matches{i/10+1},1);
end
fig=figure;
bar(0:10:350, count);
%print(fig,'../results/q3_1_1','-djpeg','-r300');