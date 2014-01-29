function model = adapt_detector(detector)


% Formats data set of annotated images from DetectMe to DPM structure


% Particular from DetectMe
model.class = detector.name;
detsize = detector.sizes(1:2);
model.sbin = 6;
model.rootfilters{1}.size = detsize;
model.rootfilters{1}.w = reshape(detector.weights,detsize(1),detsize(2),31);
model.offsets{1}.w = - detector.bias;% look at the sign of bias term!!

% set up offset 
model.offsets{1}.w = 0;
model.offsets{1}.blocklabel = 1;
model.blocksizes(1) = 1;
model.regmult(1) = 0;
model.learnmult(1) = 20;
model.lowerbounds{1} = -100;

% set up root filter
height = model.rootfilters{1}.size(1);
% root filter is symmetric
width = ceil(model.rootfilters{1}.size(2)/2);
model.rootfilters{1}.blocklabel = 2;
model.blocksizes(2) = width * height * 31;
model.regmult(2) = 1;
model.learnmult(2) = 1;
model.lowerbounds{2} = -100*ones(model.blocksizes(2),1);

% set up one component model
model.components{1}.rootindex = 1;
model.components{1}.offsetindex = 1;
model.components{1}.parts = {};
model.components{1}.dim = 2 + model.blocksizes(1) + model.blocksizes(2);
model.components{1}.numblocks = 2;

% initialize the rest of the model structure
model.interval = 10;
model.numcomponents = 1;
model.numblocks = 2;
model.partfilters = {};
model.defs = {};
model.maxsize = model.rootfilters{1}.size;
model.minsize = model.rootfilters{1}.size;