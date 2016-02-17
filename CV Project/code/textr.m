
source = '../INRIAPerson/Test/gtboxes/';
dirs=dir([source, '*.txt']);
all_txtnames={dirs.name}';
l = length(all_txtnames);
gtbox=cell(1,l);
for i=1:l
    gtbox{i}=load([source, all_txtnames{i}]);
end
