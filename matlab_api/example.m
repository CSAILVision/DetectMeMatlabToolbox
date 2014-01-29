%%%%%%
% This is an example about an evaluation of a Test set against a Training
% set, both taken from the DetectMe database.
%
%

initial_scale=0.5;
cls='TrainContest';
server = 'http://detectme.csail.mit.edu/';

str = 'mug';

% Download Test Set from Server: Detector ID--->142
[~, test_all] = getdetector(142);
test_set = format_dataset(test_all, cls);

%Pre-compute Hog Features and Piramyds
for j=1:size(test_set,2)
        im = color(test_set(j).im);
        [feat, scales] = featpyramid(im, 6, 10);
        test_set(j).features = feat(31:end);
        test_set(j).scales = scales(31:end);
end

% Download Training Set from Server: Detector ID---->198
[detector1, test_set_detector] = getdetector(198);
model = format_detector(detector1);
model.class=cls;

% Visualize detector
visualizeHOG(model.rootfilters{1}.w);

% Test detector with the desired test and training sets
threshold = 0;
[rec,prec, ap, BB, ids, score, tp] = eval_svm_parfor(test_set, model, threshold);

% show Top detections
figure;
for i=1:25
    subaxis(5,5,i, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
    im = test_set(ids(i)).im;
    bbox = round(BB(:,i));
    showboxes(im, bbox')
    text(bbox(1),bbox(2)-10,strcat('\color{red}',num2str(score(i))),'FontSize',16)
end


figure;
% Precision Recall curves
plot(rec,prec)
ylabel('Precision')
xlabel('Recall')
title(strcat('Class:', cls))
legend( strcat('DetectMe ','(', num2str(ap), ')'))

figure;


% Show Positive Detections
j=1;
for i=1:size(score,1)
    if tp(i)==1
        subaxis(5,5,j, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
        j = j+1;
        im = test_set(ids(i)).im;
        bbox = round(BB(:,i));
        showboxes(im, bbox')
        text(bbox(1),bbox(2)-10,strcat('\color{green}',num2str(score(i))),'FontSize',16)
    end
end
figure;
scatter(1:size(score,1), score, [], tp, 'fill')






