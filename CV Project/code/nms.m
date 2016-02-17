function [refinedBBoxes] = nms(bboxes, bandwidth, K)
    % Adjust the weights to be positive numbers
    lowest_weight = min(bboxes(:,end));
    if lowest_weight <= 0
        bboxes(:,end) = bboxes(:,end) + abs(lowest_weight) + 1;
    end
    
    % run mean shift to detect centers
    stopThresh = bandwidth * 0.001;
    [CCenters,CMemberships] = MeanShift(bboxes,bandwidth,stopThresh);
    
    % pick only top K
    if size(CCenters,1) > K
        % Sort the centers according to the number of members it has
        [count,class]=hist(CMemberships,unique(CMemberships));
        [~, idx] = sort(count, 'descend');
        
        % Pick the top K centers with the mosts members
        refinedBBoxes = CCenters(idx(1:K), :);
    else
        refinedBBoxes = CCenters;
    end
end