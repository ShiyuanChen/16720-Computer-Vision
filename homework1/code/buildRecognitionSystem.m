function buildRecognitionSystem(layerNum)

layerNum = uint32(layerNum);
source = '../dat/';
target = '../dat/';

load('../dat/traintest.mat','train_imagenames','train_labels','mapping');
load('dictionary.mat','filterBank','dictionary');
train_imagenames=train_imagenames;

l = length(train_imagenames);
train_features=zeros(size(dictionary,2)*(4^layerNum-1)/3,l);

for i=1:l
    load([source, strrep(train_imagenames{i},'.jpg','.mat')],'wordMap');
    train_features(:,i) = getImageFeaturesSPM(layerNum, wordMap, size(dictionary,2));
end

save('vision.mat','filterBank','dictionary','train_features','train_labels');
