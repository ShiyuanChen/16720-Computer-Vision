% Use the new smaller box training data with cascade model to test
% on a bunch of test images
source = '../INRIAPerson/Test/pos/';
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
l = length(all_imagenames);


%% resize all test image to have hight(numRows) 500
% And re-scale the ground truth coordinates accordingly
scaled_test_images = cell(1, l);
scaled_gtbox = cell(1, l);
for im_number = 1:l
    im_number
    % read one test image with people and rescale
    im = imread([source, all_imagenames{im_number}]);
    scaled_test_images{im_number} = imresize(im, [500 NaN]);
    % calculte scale ratio
    ratio = 500/size(im, 1)
    scaled_gtbox{im_number} = gtbox{im_number}*ratio;
end

% for i = 1:3
%     figure; 
%     showboxes(scaled_test_images{i},  scaled_gtbox{i});
%     size(scaled_test_images{i})
% end

%%
thresholds = [-4.5   -6.0   NaN];

num_images = 50;
offset = 0;
detBoxCell = cell(1, num_images);
detBoxBeforeNMS = cell(1, num_images);
for im_number = 1+offset:num_images+offset
    im_number
    tic
    % read one test image with people
    im = scaled_test_images{im_number};

    % Build gaussPyramid
    num_scale = 5;
    level_per_octave=2;
    [pyramids, scale]=im_pyramid(im, level_per_octave, num_scale);
    features_pyramid = cell(1, num_scale); 

%     pyramids = pyramids(2:end);
%     scale = scale(2:end);
    
    for i = 1:num_scale
        features_pyramid{i} = gen_feature_channels(pyramids{i});
    end

    % do sliding window
    topLeftRow = 1;
    topLeftCol = 1;
    h = 110;
    w = 46;
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
        for y = topLeftCol:step_size:bottomRightCol-h-step_size-41
            for x = topLeftRow:step_size:bottomRightRow-w-step_size-41
                window_feature = features(y:y+h-1, x:x+w-1, :);   
                window_feature(:,:,2:7) = window_feature(:,:,2:7) / window_feature(end,end,1);
                ICF_test(fcount, :) = rnd_sample_features(window_feature, feature_selection_small);
                windows(fcount, 1:4) = [x, y, x+w-1, y+h-1];
                fcount = fcount+1;
%                 num_total_windows = num_total_windows + 1;
            end
%             fcount
        end

        ICF_test = ICF_test(1:fcount, :);
        for j = 1:2
            [~, scores] = predict(small_cascade_models{j},ICF_test);
            picked = scores(:,2)>thresholds(j);
            ICF_test = ICF_test(picked, :);
            windows = windows(picked, :);
            scores = scores(picked, :);
        end

%         disp('done predict stage 1 and 2 ...');
        [predict_class, scores] = predict(small_cascade_models{3},ICF_test);
%         disp('done predict stage 1 and 3 ...');

        pos_windows = windows(scores(:,2)>-10000, :);
        pos_windows = ceil(pos_windows ./scale(i)); % rescale back to origial image coordinates
        
        pos_scores = scores(scores(:,2)>-10000, 2);
        pos_windows(:,5) = pos_scores;

        n_pos_windows_current_im = size(pos_windows,1);
        all_pos_windows(num_pos_windows+1:num_pos_windows+n_pos_windows_current_im, :) = pos_windows;
        num_pos_windows = num_pos_windows + n_pos_windows_current_im;

    end

    % nms function by PDollar
    all_pos_windows = all_pos_windows(1:num_pos_windows, :);
    bbs = bbNms(all_pos_windows);
    detBoxCell{im_number-offset} = bbs;
    detBoxBeforeNMS{im_number-offset} = all_pos_windows;
    
    toc
end


figure;
peek = 42;
for i = 1:2:12
    subplot(3,4,i); showboxes(scaled_test_images{peek+fix(i/2)}, detBoxBeforeNMS{peek+fix(i/2)});
    subplot(3,4,i+1); showboxes(scaled_test_images{peek+fix(i/2)}, detBoxCell{peek+fix(i/2)});
end


% load('gtbox.mat');
[rec,prec,ap] = evalAP(scaled_gtbox(1:50),detBoxCell);

% with image 1~20, ap = 16.82%

% with 288 image, thresholds = [-4.5   -5.0   NaN]. 
% ap = 0.1303, max(rec) = 0.2513. file =
% 'detection_im288_v1.mat', 

% with 50 image, thresholds = [-4.5   -6.0   NaN];
% ap = 0.2182, max(rec) = 0.3830.
% detBoxCell_2182 = detBoxCell;
save('predictions_2182.mat', 'scaled_gtbox', 'detBoxCell');

% with 50 image, thresholds = [-5.0   -6.0   NaN];
% ap = 0.2174, max(rec) = 0.3830.
% detBoxCell_2174 = detBoxCell;


detBoxCell_2182_thresholded = detBoxCell_2182;
for j = -6:0.1:-5
for i = 1:50
    a = detBoxCell_2182{i};
    detBoxCell_2182_thresholded{i} =a(a(:,end)>j, :);
end
[rec,prec,ap] = evalAP(scaled_gtbox(1:50),detBoxCell_2182_thresholded);
ap
end

figure;
peek = 7;
for i = 1:2:12
    subplot(3,4,i); showboxes(scaled_test_images{peek+fix(i/2)}, detBoxCell_2182_thresholded{peek+fix(i/2)});
    subplot(3,4,i+1); showboxes(scaled_test_images{peek+fix(i/2)}, detBoxCell_2182{peek+fix(i/2)});
end


% Compare detBoxes and gtbox
peek = 1;
figure; 
subplot(1,2,1);showboxes(scaled_test_images{peek},  detBoxCell{peek});
subplot(1,2,2);showboxes(scaled_test_images{peek},  scaled_gtbox{peek});

% save('detection_im288_v1.mat', 'detBoxBeforeNMS', 'detBoxCell', 'scaled_gtbox'); % with small_cascade_model_3.mat


[miss_rate,fppi] = evalAP_ROC(scaled_gtbox(1:50),detBoxCell_2182_thresholded);
figure;
loglog(fppi, log10(miss_rate), '-s');
axis([1e-4 1e2 -Inf 0]);
legend('our method', 'FontSize',18)



% see 
detBoxCell_2182_plot = detBoxCell_2182;
for i = 1:50
    a = detBoxCell_2182{i};
    detBoxCell_2182_plot{i} =a(a(:,end)>-5.1, :);
end

figure; 
for i = 30:50
    subplot(4,6,i);
    showboxes(scaled_test_images{i},  detBoxCell_2182_plot{i});
end

% im#4 (-4)
% im#40 (-5.1)
% im#23 (-5.5)
% im#49 (-5)
figure; 
peek = 50;
showboxes(scaled_test_images{peek},  detBoxCell_2182{peek}(detBoxCell_2182{peek}(:,5)>-5, :));

s = 0;
for i = 1:l
   s = s + size(scaled_test_images{i}, 2);
end
s/l