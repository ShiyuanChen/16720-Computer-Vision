%% [[Fast]] Do sliding window detection on positive images with 5 pyramid with cascade

% % Number of cores to use
% numCores = 4;
% 
% % Close the pools, if any
% try
%     fprintf('Closing any pools...\n');
%     delete(gcp('nocreate'));
% catch ME
%     disp(ME.message);
% end
% 
% fprintf('Starting a pool of workers with %d cores\n', numCores);
% parpool('local', numCores);

tic

% The training data is 104 X 40 small size
source = '../INRIAPerson/Test/pos/';
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
l = length(all_imagenames);


% read one test image with people
image = (imread([source, all_imagenames{100}]));
% im = image(140:677, 238:520, :);
im = image;
figure; imshow(im);

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
step_size = 4;

all_pos_windows = zeros(5000, 5);
num_pos_windows = 1;
for i = 1:num_scale
    i
    im = pyramids{i};
    if (size(im,1) < h || size(im, 2)<w)
        break
    end
    features = features_pyramid{i};
    [bottomRightCol bottomRightRow d] = size(im);

    num_windows = ceil((bottomRightCol-h)/step_size * (bottomRightRow-w)/step_size*1.1);
    pos_windows = zeros(num_windows,5);
    ICF_test = zeros(num_windows,nFeatures);
    windows = zeros(num_windows, 5); % [x1, y1, x2, y2, score]
    fcount = 1;
    
    % scan the entire image and extract features for each sliding window
    for y = topLeftCol:step_size:bottomRightCol-h-step_size
        for x = topLeftRow:step_size:bottomRightRow-w-step_size
            window_feature = features(y:y+h-1, x:x+w-1, :);   
            window_feature(:,:,2:7) = window_feature(:,:,2:7) / window_feature(end,end,1);
            ICF_test(fcount, :) = rnd_sample_features(window_feature, feature_selection_small);
            windows(fcount, 1:4) = [x, y, x+w-1, y+h-1];
            fcount = fcount+1;
        end
        fcount
    end

    ICF_test = ICF_test(1:fcount, :);
    for j = 1:2
        scores = cell(1,4);
        row_per_slice = fix(size(ICF_test,1)/4);
        ind = [0 row_per_slice 2*row_per_slice 3*row_per_slice size(ICF_test,1)];
        scores = cell(1,4);
        parfor slice = 1:4
            [~, scores{slice}] = predict(small_cascade_models{j},ICF_test(ind(slice)+1:ind(slice+1),:));
        end
        scores = cat(1, scores{:});
        picked = scores(:,2)>thresholds(j);
        ICF_test = ICF_test(picked, :);
        windows = windows(picked, :);
    end

    [predict_class, scores] = predict(small_cascade_models{3},ICF_test);
    pos_windows = windows( predict_class==1, :);
    pos_windows = ceil(pos_windows ./scale(i)); % rescale back to origial image coordinates
    
    pos_scores = scores(predict_class==1, 2);
    pos_windows(:,5) = pos_scores;
      
    n_pos_windows_current_im = size(pos_windows,1);
    all_pos_windows(num_pos_windows:num_pos_windows+n_pos_windows_current_im-1, :) = pos_windows;
    num_pos_windows = num_pos_windows + n_pos_windows_current_im;
    
end


% select only windows with score > threshold
score_thr = 0; % for select the best sub-window
all_pos_windows = all_pos_windows(1:num_pos_windows-1, :);
selected_pos_windows = all_pos_windows(all_pos_windows(:,5)> score_thr, :);
figure; 
subplot(2,2,1);showboxes(pyramids{1},  all_pos_windows);
subplot(2,2,2); showboxes(pyramids{1},  selected_pos_windows);

if size(all_pos_windows)>=2
% My nms function
bestBBox = nms(selected_pos_windows,50,10);
subplot(2,2,3); showboxes(pyramids{1},  bestBBox);
end

% nms function by PDollar
bbs = bbNms(selected_pos_windows);
subplot(2,2,4); showboxes(pyramids{1}, bbs);

toc

% delete(gcp('nocreate'));

