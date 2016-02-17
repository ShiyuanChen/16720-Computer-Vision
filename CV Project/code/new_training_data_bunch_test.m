% Use the new smaller box training data with cascade model to test
% on a bunch of test images
source = '../INRIAPerson/Test/pos/';
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
l = length(all_imagenames);

num_images = 20;
detBoxCell = cell(1, num_images);
for im_number = 1:num_images
    im_number
    tic
    % read one test image with people
    im = (imread([source, all_imagenames{im_number}]));

    % Build gaussPyramid
    num_scale = 5;
    level_per_octave=2;
    [pyramids, scale]=im_pyramid(im, level_per_octave, num_scale+1);
    features_pyramid = cell(1, num_scale); 

    pyramids = pyramids(2:end);
    scale = scale(2:end);
    
    for i = 1:num_scale
        features_pyramid{i} = gen_feature_channels(pyramids{i});
    end

    % do sliding window
    topLeftRow = 1;
    topLeftCol = 1;
    h = 104;
    w = 40;
    step_size = 6;

    all_pos_windows = zeros(5000, 5);
    num_pos_windows = 0;
    for i = 1:num_scale
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

        topLeftCol = 41;
        topLeftRow = 41;
        % scan the entire image and extract features for each sliding window
        for y = topLeftCol:step_size:bottomRightCol-h-step_size
            for x = topLeftRow:step_size:bottomRightRow-w-step_size
                window_feature = features(y:y+h-1, x:x+w-1, :);   
                window_feature(:,:,2:7) = window_feature(:,:,2:7) / window_feature(end,end,1);
                ICF_test(fcount, :) = rnd_sample_features(window_feature, feature_selection_small);
                windows(fcount, 1:4) = [x, y, x+w-1, y+h-1];
                fcount = fcount+1;
                num_total_windows = num_total_windows + 1;
            end
%             fcount
        end

        ICF_test = ICF_test(1:fcount, :);
        for j = 1:2
            [~, scores] = predict(small_cascade_models{j},ICF_test);
            picked = scores(:,2)>thresholds(j);
            ICF_test = ICF_test(picked, :);
            windows = windows(picked, :);
        end

        [predict_class, scores] = predict(small_cascade_models{3},ICF_test);
%         pos_windows = windows( predict_class==1, :);
        pos_windows = windows(scores(:,2)>-7, :);
        pos_windows = ceil(pos_windows ./scale(i)); % rescale back to origial image coordinates
        
%         pos_scores = scores(predict_class==1, 2);
        pos_scores = scores(scores(:,2)>-7, 2);
        pos_windows(:,5) = pos_scores;

        n_pos_windows_current_im = size(pos_windows,1);
        all_pos_windows(num_pos_windows+1:num_pos_windows+n_pos_windows_current_im, :) = pos_windows;
        num_pos_windows = num_pos_windows + n_pos_windows_current_im;

    end

    % nms function by PDollar
    all_pos_windows = all_pos_windows(1:num_pos_windows, :);
    bbs = bbNms(all_pos_windows);
    detBoxCell{im_number} = bbs;
    
    toc
end


figure;
peek = 15;
for i = 1:2:12
    subplot(3,4,i); showboxes(imread([source, all_imagenames{peek+fix(i/2)}]),  all_pos_windows);
    subplot(3,4,i+1); showboxes(imread([source, all_imagenames{peek+fix(i/2)}]),  detBoxCell{peek+fix(i/2)});
end

% load('gtbox.mat');
figure;
[rec,prec,ap] = evalAP(gtbox(1:20),detBoxCell, 'draw', 1)