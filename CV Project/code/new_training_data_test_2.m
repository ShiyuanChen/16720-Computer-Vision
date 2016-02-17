%% [[Fast]] Do sliding window detection on positive images with 5 pyramid with cascade

% The training data is 104 X 40 small size
source = '../INRIAPerson/Test/pos/';
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
l = length(all_imagenames);

tic
% read one test image with people
image = (imread([source, all_imagenames{28}]));
% im = image(140:677, 238:520, :);
im = image;
% figure; imshow(im);


% Build gaussPyramid
num_scale = 8;
level_per_octave=3;
[pyramids, scale]=im_pyramid(im, level_per_octave, num_scale);
features_pyramid = cell(1, num_scale); 

for i = 1:num_scale
    features_pyramid{i} = gen_feature_channels(pyramids{i});
end

% for i = 1:num_scale*2-1
%     figure;
%     imshow(im_pyramid{i});
%     size(im_pyramid{i})
% end

% do sliding window
topLeftRow = 1;
topLeftCol = 1;
h = 104;
w = 40;
step_size = 6;

ICF_test = zeros(80000, nFeatures);
windows = zeros(80000, 5); % [x1, y1, x2, y2, score]
from_scale = zeros(80000, 1);
fcount = 0;

for i = 1:num_scale
    im = pyramids{i};
    if (size(im,1) < h || size(im, 2)<w)
        break
    end
    features = features_pyramid{i};
    [bottomRightCol bottomRightRow d] = size(im);

%     num_windows = ceil((bottomRightCol-h)/step_size * (bottomRightRow-w)/step_size*1.1);
%     pos_windows = zeros(num_windows,5);
    
    % scan the entire image and extract features for each sliding window
    for y = topLeftCol:step_size:bottomRightCol-h-step_size
        for x = topLeftRow:step_size:bottomRightRow-w-step_size
            fcount = fcount+1;   
            window_feature = features(y:y+h-1, x:x+w-1, :);   
            window_feature(:,:,2:7) = window_feature(:,:,2:7) / window_feature(end,end,1);
            ICF_test(fcount, :) = rnd_sample_features(window_feature, feature_selection_small);
            windows(fcount, 1:4) = [x, y, x+w-1, y+h-1];
            from_scale(fcount) = scale(i);
        end
%         fcount
    end
end

toc

tic
    ICF_test = ICF_test(1:fcount, :);
    windows = windows(1:fcount, :);
    for j = 1:2
        [~, scores] = predict(small_cascade_models{j},ICF_test);
        picked = scores(:,2)>thresholds(j);
        ICF_test = ICF_test(picked, :);
        windows = windows(picked, :);
        from_scale = from_scale(picked);
    end

    [predict_class, scores] = predict(small_cascade_models{3},ICF_test);
    pos_windows = windows(predict_class==1, :);
    from_scale = from_scale(predict_class==1, :);
    pos_windows(:, 1:4) = ceil(pos_windows(:,1:4) ./ repmat(from_scale, 1, 4)); % rescale back to origial image coordinates
    
    pos_scores = scores(predict_class==1, 2);
    pos_windows(:,5) = pos_scores;
    
toc


%     n_pos_windows_current_im = size(pos_windows,1);
%     all_pos_windows(num_pos_windows:num_pos_windows+n_pos_windows_current_im-1, :) = pos_windows;
%     num_pos_windows = num_pos_windows + n_pos_windows_current_im;


% select only windows with score > threshold
% score_thr = 0; % for select the best sub-window
% all_pos_windows = all_pos_windows(1:num_pos_windows-1, :);
% selected_pos_windows = all_pos_windows(all_pos_windows(:,5)> score_thr, :);
figure; 
subplot(2,2,1);showboxes(pyramids{1},  pos_windows);
subplot(2,2,2); showboxes(pyramids{1},  pos_windows);

if size(pos_windows,1)>=2
% My nms function
bestBBox = nms(pos_windows,50,10);
subplot(2,2,3); showboxes(pyramids{1},  bestBBox);
end

% nms function by PDollar
bbs = bbNms(pos_windows);
subplot(2,2,4); showboxes(pyramids{1}, bbs);



% Elapsed time is 118.042341 seconds.
