function [pos, neg] = detectme_data(images, initial_scale)


image_dir = '/Users/a/Documents/MIT/CSAIL/temp/'
  
%get positives  
pos = [];
neg = [];
numneg = 0;
numpos = 0;
sizepos = size(images,2);
for i = 1:sizepos;
    fprintf('parsing positives: %d/%d\n', i, sizepos);
    numpos = numpos+1;
    
    im = imresize(images{1,i}{1,1}, initial_scale);
    info = images{1,i}{1,2};
    
    % store the image
    im_dir = strcat(image_dir,'image_',num2str(i),'.jpg');     
    imwrite(im,im_dir);
    
    %info about the positives
    pos(numpos).im = im_dir;
    w = size(im,2);
    h = size(im,1);
    x1 = round(info.box_x*w);
    y1 = round(info.box_y*h);
    x2 = round((info.box_x + info.box_width)*w);
    y2 = round((info.box_y + info.box_height)*h);
    
    pos(numpos).x1 = x1;
    pos(numpos).y1 = y1;
    pos(numpos).x2 = x2;
    pos(numpos).y2 = y2;
    
    %negative image: the same as positives one with a balck patch on the
    %positive bounding box
    
    im_neg = im;
    im_neg(y1:y2,x1:x2,1) = round(rand(y2-y1+1, x2-x1+1)*255);
    im_neg(y1:y2,x1:x2,2) = round(rand(y2-y1+1, x2-x1+1)*255); 
    im_neg(y1:y2,x1:x2,3) = round(rand(y2-y1+1, x2-x1+1)*255);
    im_neg_dir = strcat(image_dir,'image_neg_',num2str(i),'.jpg');
    imwrite(im_neg, im_neg_dir);
    numneg = numneg+1;
    neg(numneg).im = im_neg_dir;
    
end
  
