function [detector,images] = getdetector(id)

% Get detector and associated annotated images from server

    server = 'http://detectme.csail.mit.edu/';
    %server = 'http://128.52.128.116/';
    % Get detector data
    detectorURL = strcat(server,'detectors/api/',num2str(id),'/?format=json');
    detectorJSON = urlread2(detectorURL);
    detector = loadjson(detectorJSON);
    detector.weights = loadjson(detector.weights);
    %detector.support_vectors = loadjson(detector.support_vectors);
    detector.sizes = loadjson(detector.sizes);
    detector.bias = detector.weights(end);
    detector.weights = detector.weights(1:end-1);
    
    % Get Images meta data
    imagesURL = strcat(server,'detectors/api/annotatedimages/fordetector/',num2str(id),'/?format=json');
    imagesJSON = urlread2(imagesURL);
    imagesMetaData = loadjson(imagesJSON);

    % Download actual images
    numImages = size(imagesMetaData,2);
    images = cell(1,numImages);
    for i=1:numImages
        fprintf('getting image %d\n', i);
        imageMetaData = imagesMetaData(1,i);
        imageMetaData = imageMetaData{1,1};
        imageURL = getfield(imageMetaData, 'image_jpeg');
        imageURL = strcat(server,'media/',imageURL);
        A = imread(imageURL,'jpg'); %Change
        images{i} = {A, imageMetaData};
    end

end
