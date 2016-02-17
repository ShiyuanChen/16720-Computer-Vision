function [pyramids, scale] = im_pyramid(im, level_per_octave, nLevels)
% [feat, scale] = esvm_pyramid(im, params);
% Compute a pyramid worth of features by calling resize/features in
% over a set of scales defined inside params
% Copyright (C) 2011-12 by Tomasz Malisiewicz
% All rights reserved.
% 
% This file is part of the Exemplar-SVM library and is made
% available under the terms of the MIT license (see COPYING file).
% Project homepage: https://github.com/quantombone/exemplarsvm


%Make sure image is in double format
ifgrey=false;
im = double(im);
if size(im,3)~=3
    im=repmat(im,1,1,3);
    ifgrey=true;
end

%Get the levels per octave from the parameters

sc = 2 ^(1/level_per_octave);

% Start at detect_max_scale, and keep going down by the increment sc, until
% we reach nLevels or detect_min_scale
scale = zeros(1,nLevels);
pyramids = cell(1,nLevels);
for i = 1:nLevels
  scaler = 1.0 / sc^(i-1);
  scale(i) = scaler;
  pyramids{i} = uint8(resize(im,scale(i)));
  if ifgrey==true
      pyramids{i} = pyramids{i}(:,:,1);
  end
end
