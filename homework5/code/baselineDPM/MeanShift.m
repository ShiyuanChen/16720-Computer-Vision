function [CCenters,CMemberships] = MeanShift(data,bandwidth,stopThresh)
fpts=data(:,1:end-1);
[nPts,nDim] = size(fpts);
CCenters=[];
weightsum=[];
CMemberships=zeros(nPts,1);
for i=1:nPts
    mean = fpts(i,:);
    while 1
        dist2 = sum((repmat(mean,nPts,1) - fpts).^2,2);
        idx = find(dist2 <= bandwidth^2);
                
        pre_mean = mean;
        mean = sum(fpts(idx,:).*repmat(data(idx,end),1,nDim),1)./sum(data(idx,end),1);

        if norm(mean-pre_mean) < stopThresh            
            ifnew=true;
            nClusters=size(CCenters,1);
            for j = 1:nClusters
                disCluster2 = sum((mean-CCenters(j,:)).^2);
                if disCluster2 < stopThresh^2
                    CCenters(j,:)=(CCenters(j,:)*weightsum(j,:)+mean*sum(data(idx,end),1))/(weightsum(j,:)+sum(data(idx,end),1));
                    weightsum(j,:)=weightsum(j,:)+sum(data(idx,end),1);
                    CMemberships(i,:)=j;
                    ifnew=false;
                    break;
                end
            end
            
            if ifnew
                CCenters(nClusters+1,:)=mean;
                weightsum(nClusters+1,:)=sum(data(idx,end),1);
                CMemberships(i,:)=nClusters+1;
            end
            break;
        end
    end
end
