function [CCenters,CMemberships] = MeanShift(data,bandwidth,stopThresh)
	points = data(:, 1:end-1);
	[N, F] = size(points); % N is the number of points

	centers = zeros(N, F);
    % find center for each of the data points
	for i = 1:N 
        move = stopThresh + 1;
        temp_pt = points(i, :);
        while move > stopThresh
           % compute distance for current point to all other points
           distance = bsxfun(@minus, points, temp_pt);
           distance = sum(distance.^2, 2);
           distance = sqrt(distance);
           
           % filter for points within bandwidth
           valid_idx = distance < bandwidth;
           
           % compute weighted sum -> the new center
           if sum(valid_idx)==1
               mean_pt = points(valid_idx,:);
           else
               mean_pt = bsxfun(@times, points(valid_idx,:),data(valid_idx,end));
               mean_pt = sum(mean_pt) / sum(data(valid_idx,end));
           end
           
           % update the new center
           move = norm(temp_pt - mean_pt);
           temp_pt = mean_pt;
        end
        centers(i,:) = temp_pt;
	end
     
    % combine close centers into one center
    CMemberships = zeros(N, 1);
    distances = pdist2(centers, centers);
    M = 0;
    for i = 1:N
        if CMemberships(i) == 0
            M = M+1;
            CMemberships(i) = M;
            CCenters(M,:) = centers(i,:);
            for j = i+1:N
               if (CMemberships(j) == 0) && (distances(i,j)<stopThresh)
                   CMemberships(j) = CMemberships(i);
               end
            end 
        end
    end
    
    
end

