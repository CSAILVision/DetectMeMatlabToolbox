function formatted_dataset = format_dataset(dataset, cls, initial_scale)

% Formats data set of annotated images from DetectMe to DPM structure
% Initial scale for all images
% DetectMe scales each image initially 0.5 in training and 0.4 in detection

if nargin < 3
  initial_scale = 0.5;
end

formatted_dataset = [];
for i=1:size(dataset,2)
   
    im = dataset{i};
    im_data = imresize(im{1}, initial_scale);
    w = size(im_data, 2);
    h = size(im_data, 1);
    
    %test
    bbox = [im{2}.box_x im{2}.box_y im{2}.box_x im{2}.box_y];
    bbox = bbox + [0 0 im{2}.box_width im{2}.box_height];
    bbox = round(bbox .* [w h w h]);
    
    test_image = {};
    test_image.im = im_data;

    ob = {};
    ob.class = cls;
    ob.bbox = bbox;
    ob.difficult = 0;

    test_image.rec.objects = ob;
    
    formatted_dataset = [formatted_dataset test_image];
   
end