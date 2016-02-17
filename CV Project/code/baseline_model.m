%% Image
source = '../INRIAPerson/Test/pos/';
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
l = length(all_imagenames);
I = (imread([source, all_imagenames{3}]));


%% Matlab people detector
peopleDetector = vision.PeopleDetector;

% scaled_test_images
bs_bboxes = cell(1, 50);

for im_number = 1:50
    I = scaled_test_images{im_number};
    [bboxes,scores] = step(peopleDetector,I);
    a = [bboxes, scores];
    
    a(:, 3) = a(:,3) + a(:,1);
    a(:,4) = a(:,4) + a(:,2);
    
    bs_bboxes{im_number} = a;
%     I = insertObjectAnnotation(I,'rectangle',bboxes,scores);
%     subplot(2,3,i);imshow(I);
end

[rec,prec,ap] = evalAP(scaled_gtbox(1:50),bs_bboxes);


figure;
peek = 13;
for i = 1:2:12
    subplot(3,4,i); showboxes(scaled_test_images{peek+fix(i/2)}, bs_bboxes{peek+fix(i/2)});
    subplot(3,4,i+1); showboxes(scaled_test_images{peek+fix(i/2)}, scaled_gtbox{peek+fix(i/2)});
end


peek = 1;
figure; 
subplot(1,2,1);showboxes(scaled_test_images{peek},  bs_bboxes{peek});
subplot(1,2,2);showboxes(scaled_test_images{peek},  scaled_gtbox{peek});


% [bboxes,scores] = step(peopleDetector,I);
% I = insertObjectAnnotation(I,'rectangle',bboxes,scores);
% figure, imshow(I)
% title('Detected people and detection scores');