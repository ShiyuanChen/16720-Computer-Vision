function [wordMap] = getVisualWords(I, filterBank, dictionary)

filterResponses=extractFilterResponses(I, filterBank);
[~,idx]=min(pdist2(dictionary',filterResponses));
wordMap=zeros(size(I,1),size(I,2));
for j=1:size(I,2)
    for i=1:size(I,1)
        wordMap(i,j)=idx((j-1)*size(I,1)+i);
    end
end