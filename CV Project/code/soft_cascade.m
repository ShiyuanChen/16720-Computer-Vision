% initialize parameters
nStages = 3;
nWeak = [30 100 500];

% Assume ICF_test_pos for normalized positive image are ready
% Assume ICF_test_neg for randomly sampled negative windows are ready

% Training dataset
Data = [ICF_pos(1:2000, :); ICF_neg];
label_pos = ones(2000,1);
label_neg = zeros(4560, 1);
label = [label_pos;label_neg];

% Developement dataset, consist of 416 positive samples
dev_size = 416;
dev_data = ICF_pos(2001:2000+dev_size, :);
dev_label = ones(dev_size,1);

% working negative data
working_neg_data = ICF_neg;
neg_size = size(working_neg_data, 1);

% Start training
models = cell(1, nStages); % The cascade of models
thresholds = zeros(1, nStages); % The threshold to call a positive

% split ICF_neg backup data into 2 parts, for stage 2 and 3
ICF_neg_backup_cell = cell(2,1);
ICF_neg_backup_cell{1} = ICF_neg_backup[1:900,:];
ICF_neg_backup_cell{2} = ICF_neg_backup[901:1800,:];


for i = 1:nStages
    working_data = [ICF_pos(1:2000, :); working_neg_data];
    working_lable = [label_pos;zeros(size(working_neg_data,1),1)];
    models{i} = fitensemble(working_data,working_lable,'AdaBoostM1',nWeak(i),'Tree');
    
    % predict on development set
    [ypredict, scores] = predict(models{i},dev_data);
    thresholds(i) = min(scores(:,2));
    
    % remove easy negatives
    [ypredict, scores] = predict(models{i},working_neg_data);
    working_neg_data = working_neg_data(scores(:,2)>thresholds(i), :);
    if i>1
        working_neg_data = [working_neg_data; ICF_neg_backup{i-1}];
    end
    disp(size(working_neg_data,1));
end

% save('cascade_model.mat', 'models', 'thresholds','nWeak','nStages');

%% train model for stage one: nWeak=30
% tic
% 
% 
% ens2 = fitensemble(Data,label,'AdaBoostM1',100,'Tree');
% toc
% % Elapsed time is 57.947777 seconds.
% 
% 
% rsLoss = resubLoss(ens2,'Mode','Cumulative');
% plot(rsLoss);
% xlabel('Number of Learning Cycles');
% ylabel('Resubstitution Loss');
