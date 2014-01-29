cd '/Users/a/Documents/MIT/CSAIL/matlab/url-connection-matlab/voc-release3.1'
cls = 'cup'
initial_scale = 0.5;
TRAIN_ID = 7; 
TEST_ID1 = 8; 
TEST_ID2 = 6; 


load('cup')
save('cup', 'detector', 'images', 'test_images1', 'test_images2')

load('chair')
save('chair', 'detector', 'images', 'test_images1', 'test_images2')

% Get detector and images
[detector, images] = getdetector(TRAIN_ID);

% Train Pedro
globals; %Load Globals Variables
[pos, neg] = detectme_data(images, initial_scale); %Stores positives and create negatives from the positive images
model_pedro = initmodel(pos, 6, [8 7]); %Init of Pedro's model, calculate the aspect ratio. 
model_pedro = train(cls, model_pedro, pos, neg, 1, 1, 4, 1, 2^28);
model_pedro.class = cls;

% format from DetectMe to Pedro
model_detectme = adapt_detector(detector);


%%
% Visualize models
model = model_detectme;

figure;
for i=1:25
    subplot(5, 5, i);
    mat = model.rootfilters{1}.w(:,:,i);
    imagesc(mat); 
end

figure;
subplot(1,2,1);
visualizeHOG(model_detectme.rootfilters{1}.w);
subplot(1,2,2);
visualizeHOG(model_pedro.rootfilters{1}.w);



%%
%PRECISION RECALL

%test set construction
[~,test_images] = getdetector(TEST_ID1);
[~,test_images2] = getdetector(TEST_ID2);
%test_images = cat(2, test_images1, test_images2);

% format from DetectMe to DPM
test = format_dataset(test_images, cls, initial_scale);


threshold = -1000;
[rec_pedro,prec_pedro,ap_pedro, BB_pedro, ids_pedro, score_pedro] = eval_svm_parfor(test,model_pedro,threshold);
[rec_detectme,prec_detectme,ap_detectme, BB_detectme, ids_detectme, score_detectme] = eval_svm_parfor(test,model_detectme,threshold);
ap_pedro
ap_detectme


% show top detections
ids = ids_detectme;
BB = BB_detectme;
score = score_detectme;

ids = ids_pedro;
BB = BB_pedro;
score = score_pedro;

figure;
for i=1:25
    subplot(5, 5, i);
    im = test_images{ids(i)}{1};
    im = imresize(im, initial_scale);
    bbox = round(BB(:,i));
    showboxes(im, bbox')
    text(bbox(1),bbox(2)-10,strcat('\color{red}',num2str(score(i))),'FontSize',16)
end


% P/R comparison
plot(rec_pedro, prec_pedro, rec_detectme, prec_detectme)
ylabel('Precision')
xlabel('Recall')
title(strcat('Class:', cls))
legend(strcat('DPM ','(', num2str(ap_pedro), ')'), strcat('DetectMe ','(', num2str(ap_detectme), ')'))
ap_pedro
ap_detectme



%visualize HOG of a picture
IMAGE_POSITION = 4; 

im = test_images{ids(IMAGE_POSITION)}{1};
im = imresize(im, initial_scale);
image(im)

im_scaled = imresize(test_images{ids(IMAGE_POSITION)}{1},0.4);
w = features(im2double(im_scaled), 8);

pad = 2;
bs = 40;
scale = max(w(:));
im = HOGpicture(w, bs);
im = imresize(im, 2);
im = padarray(im, [pad pad], 0);
im = uint8(im * (255/scale));
colormap gray
axis('image')
image(im)

%%
%Execution


im = test_images{1}{1};
im_resize = imresize(im, 0.4);
bbox = process(im, model_pedro, -1); % detect objects
showboxes(im, bbox);          % display results

