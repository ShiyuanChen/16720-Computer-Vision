im1=imread('../data/model_chickenbroth.jpg');
im1 = im2double(im1);
if size(im1,3)==3
    im1= rgb2gray(im1);
end
[locs1, desc1] = briefLite(im1);
matches=cell(11);
count=zeros(11,1);
for i=0.5:0.1:1.5
    im2=imresize(im1,i,'bicubic');
    [locs2, desc2] = briefLite(im2);
    matches{uint8(i*10-4)} = briefMatch(desc1, desc2);
	count(uint8(i*10-4))=size(matches{uint8(i*10-4)},1);
    if i==0.5
        plotMatches(im1, im2, matches{uint8(i*10-4)}, locs1, locs2);
    end
end
fig=figure;
bar(0.5:0.1:1.5, count);

%print(fig,'../results/q3_2_1','-djpeg','-r300');