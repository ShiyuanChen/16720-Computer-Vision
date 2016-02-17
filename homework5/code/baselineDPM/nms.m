function [refinedBBoxes] = nms(bboxes, bandwidth,K)
stopThresh = bandwidth*0.01;
if(~isempty(find(bboxes(:,end)<=0)))
    bboxes(:,end)=bboxes(:,end)+abs(min(bboxes(:,end)))+1;
end
[CCenters,CMemberships] = MeanShift(bboxes,bandwidth,stopThresh);
K=min(K,size(CCenters,1));
refinedBBoxes=zeros(K,size(bboxes,2)-1);
totalscores=zeros(size(CCenters,1),1);
for i=1:size(CMemberships,1)
    totalscores(CMemberships(i))=totalscores(CMemberships(i))+bboxes(i,end);
end
[~,idx]=sort(totalscores,'descend');
refinedBBoxes(:,:)=CCenters(idx(1:K),:);