function [ICF] = rnd_sample_features(features, feature_selection)
    nFeatures = size(feature_selection, 1);
    ICF = zeros(1, nFeatures);
    
    x1 = feature_selection(:,1);
    y1 = feature_selection(:,2);
    x2 = feature_selection(:,3);
    y2 = feature_selection(:,4);
    layer = feature_selection(:,5);

    for i = 1 : nFeatures
        ICF(i) = features(y2(i),x2(i),layer(i)) ...
                - features(y1(i),x2(i),layer(i)) ...
                - features(y2(i),x1(i),layer(i)) ...
                + features(y1(i),x1(i),layer(i));
    end  
    
end

