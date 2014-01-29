function [ap,prec,rec] = eval_submission(train_detector, test_set)
% This functions runs the detector "train_detector" against the test set
% and returns the average precision (ap) and the Precision (prec) - Recall
% (rec) curve. 

initial_scale=0.5
cls='TrainContest';


%Get detector
model1 = format_detector(train_detector);
model1.class=cls;

% test detector
threshold = -1000;
[rec,prec, ap, BB, ids, score, tp] = eval_svm_parfor(test_set, model1, threshold);

end




