
%numCores=4;
%try
%    fprintf('Closing any pools...\n');
%     matlabpool close; 
%    delete(gcp('nocreate'))
%catch ME
%    disp(ME.message);
%end
%fprintf('Starting a pool of workers with %d cores\n', numCores);
% matlabpool('local',numCores);
%parpool('local', numCores);

% add pdollar tool box for luv conversion
addpath('./toolbox/pdollar/channels');
savepath;

nFeatures=1000;
source = '../INRIAPerson/train_64x128_H96/pos/';
target = '../dat/'; 
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
l = length(all_imagenames);
cellSize = 8;
hog=cell(l,1);
channels=cell(l,1);
features=cell(l,1);
integral_I=cell(l,1);
angles=[0,30,60,90,120,150,180];

h = 128;
w = 64;
padding = 16;


for i=1:l
    i
    image = (imread([source, all_imagenames{i}]));
    image=image(padding+1:h+padding, padding+1:w+padding, :);
    %hog{i} = vl_hog(image, cellSize, 'verbose');
    [Gmag,Gdir] = imgradient(rgb2gray(image));
    for j=1:6
        hog{i}(:,:,j)=Gmag.*((Gdir>=angles(j)& Gdir<angles(j+1))|(Gdir>=angles(j)-180 & Gdir<angles(j+1)-180))./sum(sum(Gmag));
    end
    channels{i}(:,:,2:7)=hog{i};
%     channels{i}(:,:,1)=rgb2gray(image);
    channels{i}(:,:,1)=Gmag;
    channels{i}(:,:,8:10)= rgbConvert(image, 'luv')/255.0;
    s=zeros(size(channels{i}));
    integral_I{i}=zeros(size(channels{i}));
    integral_I{i}(1,1,:)=channels{i}(1,1,:);
    s(1,1,:)=channels{i}(1,1,:);
    s(2,1,:)=channels{i}(2,1,:);
    integral_I{i}(2,1,:)=integral_I{i}(1,1,:)+s(2,1,:);
    for k=2:size(channels{i},2) 
        s(1,k,:)=s(1,k-1,:)+channels{i}(1,k,:);
        integral_I{i}(1,k,:)=s(1,k,:);
    end
    for j=2:size(channels{i},1)
        s(j,1,:)=channels{i}(j,1,:);
        integral_I{i}(j,1,:)=integral_I{i}(j-1,1,:)+s(j,1,:);
    end
    for j=2:size(channels{i},1)
        for k=2:size(channels{i},2)
            s(j,k,:)=s(j,k-1,:)+channels{i}(j,k,:);
            integral_I{i}(j,k,:)=integral_I{i}(j-1,k,:)+s(j,k,:);
        end
    end
end

layer=randi(10,nFeatures,1);
count=1;
x1=randi(size(channels{1},2),nFeatures,1);
y1=randi(size(channels{1},1),nFeatures,1);
x2=zeros(nFeatures,1);
y2=zeros(nFeatures,1);
ICF = zeros(l, nFeatures);

while count <=nFeatures
    x2(count)=randi(size(channels{1},2));
    y2(count)=randi(size(channels{1},1));
    if (x1(count)-x2(count))*(y1(count)-y2(count))>=25;
        if x1(count)>x2(count)
            temp=x1(count);
            x1(count)=x2(count);
            x2(count)=temp;
            temp=y1(count);
            y1(count)=y2(count);
            y2(count)=temp;
        end
        
        for i = 1 : l
            ICF(i, count) = integral_I{i}(y2(count),x2(count),layer(count)) ...
                            - integral_I{i}(y1(count),x2(count),layer(count)) ...
                            - integral_I{i}(y2(count),x1(count),layer(count)) ...
                            + integral_I{i}(y1(count),x1(count),layer(count));
        end    
        count=count+1;
    end
end


feature_selection = [x1, y1, x2, y2, layer];

save('train_ICF.mat', 'ICF', 'feature_selection', 'integral_I');