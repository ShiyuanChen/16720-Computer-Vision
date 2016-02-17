function [confusionMatrix,accuracy] = evaluateRecognitionSystem()

load('../dat/traintest.mat','test_imagenames','test_labels','mapping');
load('vision.mat');

source = '../dat/';
target = '../dat/';

l = length(test_imagenames);
confusionMatrix=zeros(size(mapping,2));
for i=1:l
    load([source, strrep(test_imagenames{i},'.jpg','.mat')],'wordMap');
    h = getImageFeaturesSPM(3, wordMap, size(dictionary,2));
    distances = distanceToSet(h, train_features);
    [~,nnI] = max(distances);
    confusionMatrix(test_labels(i),train_labels(nnI)) = confusionMatrix(test_labels(i),train_labels(nnI))+1;
end
accuracy=trace(confusionMatrix)/sum(confusionMatrix(:));
save('comfusionMatrix','confusionMatrix','accuracy');
