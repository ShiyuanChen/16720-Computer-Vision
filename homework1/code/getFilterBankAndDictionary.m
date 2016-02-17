function [filterBank, dictionary] = getFilterBankAndDictionary(image_names)

a=150;
K=300;
I=cell(length(image_names),1);
filterBank=createFilterBank();
filter_responses=zeros(a*length(image_names),length(filterBank)*3);

for i = 1:length(image_names)
    I{i}=imread(image_names{i});
    temp=extractFilterResponses(I{i}, filterBank);
    perm=randperm(size(temp,1),a);
    for j=1:a
        filter_responses(a*(i-1)+j,:)=temp(perm(j),:);
    end
end
[~,dictionary] = kmeans(filter_responses,K,'EmptyAction','drop');
dictionary=dictionary';

