function [confusionMatrix,accuracy] = evaluateRecognitionSystem()

load('../dat/traintest.mat','test_imagenames','test_labels','train_labels','mapping');
load('vision.mat');

source = '../dat/';
target = '../dat/';

l = length(test_imagenames);
confusionMatrix=zeros(size(mapping,2));
for i=1:l
    load([source, strrep(test_imagenames{i},'.jpg','.mat')],'wordMap');
    h = getImageFeaturesSPM(3, wordMap, size(dictionary,2));
    distances = distanceToSet(h, train_features);
    count=zeros(1,size(mapping,2));
    divd=zeros(1,size(mapping,2));
    for j=1:size(distances,2)
        count(1,train_labels(1,j))=count(1,train_labels(1,j))+distances(1,j);
        divd(1,train_labels(1,j))=divd(1,train_labels(1,j))+1;
    end
    [~,nnI] = max(count./divd);
    confusionMatrix(test_labels(i),nnI) = confusionMatrix(test_labels(i),nnI)+1;
end
accuracy=trace(confusionMatrix)/sum(confusionMatrix(:));
save('comfusionMatrix','confusionMatrix','accuracy');
