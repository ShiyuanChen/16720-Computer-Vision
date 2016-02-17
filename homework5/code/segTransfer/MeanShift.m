function [CCenters,CMemberships] = MeanShift(data,bandwidth,stopThresh)
fpts=data(:,1:end-1);
[nPts,nDim] = size(fpts);
CCenters=[];
weightsum=[];
CMemberships=zeros(nPts,1);
for i=1:nPts
    mean = fpts(i,:);                           % intilize mean to this points location                      
    while 1     %loop untill convergence
        dist2 = sum((repmat(mean,nPts,1) - fpts).^2,2);    %dist squared from mean to all points still active
        idx = find(dist2 <= bandwidth^2);               %points within bandWidth
                
        pre_mean = mean;                                   %save the old mean
        mean = sum(fpts(idx,:).*repmat(data(idx,end),1,nDim),1)./sum(data(idx,end),1);                %compute the new mean

        %**** if mean doesn't move much stop this cluster ***
        if norm(mean-pre_mean) < stopThresh            
            ifnew=true;
            nClusters=size(CCenters,1);
            for j = 1:nClusters
                disCluster2 = sum((mean-CCenters(j,:)).^2);     %distance from posible new clust max to old clust max
                if disCluster2 < stopThresh^2                    %if its within bandwidth/2 merge new and old
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
