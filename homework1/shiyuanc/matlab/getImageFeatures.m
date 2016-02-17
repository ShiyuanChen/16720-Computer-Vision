function [h] = getImageFeatures(wordMap, dictionarySize)

his=hist(wordMap,[1:dictionarySize]);
h=double(sum(his,2))/double((size(wordMap,1)*size(wordMap,2)));