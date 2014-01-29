function [boxes] = detect(input, model, thresh, bbox, ...
                          overlap, label, fid, id, maxsize)

% boxes = detect(input, model, thresh, bbox, overlap, label, fid, id, maxsize)
% Detect objects in input using a model and a score threshold.
% Higher threshold leads to fewer detections.
%
% The function returns a matrix with one row per detected object.  The
% last column of each row gives the score of the detection.  The
% column before last specifies the component used for the detection.
% The first 4 columns specify the bounding box for the root filter and
% subsequent columns specify the bounding boxes of each part.
%
% If bbox is not empty, we pick best detection with significant overlap. 
% If label and fid are included, we write feature vectors to a data file.

latent = false;
write = false;

if nargin < 9
  maxsize = inf;
end

% we assume color images
%input = color(input);

% prepare model for convolutions
rootfilters = [];
rootfilters{1} = model.rootfilters{1}.w;


% cache some data
ridx = model.components{1}.rootindex;
oidx = model.components{1}.offsetindex;
root = model.rootfilters{ridx}.w;
rsize = [size(root,1) size(root,2)];
numparts = length(model.components{1}.parts);


% we pad the feature maps to detect partially visible objects
padx = ceil(model.maxsize(2)/2+1);
pady = ceil(model.maxsize(1)/2+1);

% the feature pyramid
interval = model.interval;

feat = input.features;
scales = input.scales;

% detect at each scale
best = -inf;
ex = [];
boxes = [];

%for level = interval+1:length(feat)
for level = 1:length(feat)   
  scale = model.sbin/scales(level);    
  
  if size(feat{level}, 1)+2*pady < model.maxsize(1) || ...
     size(feat{level}, 2)+2*padx < model.maxsize(2) || ...
     (write && ftell(fid) >= maxsize)
    continue;
  end
    
  % convolve feature maps with filters 
  featr = padarray(feat{level}, [pady padx 0], 0);
  rootmatch = fconv(featr, rootfilters, 1, length(rootfilters));
  
  % root score + offset
  score = rootmatch{ridx} + model.offsets{oidx}.w;  
    
    
  
  % get all good matches
  I = find(score > thresh);
  [Y, X] = ind2sub(size(score), I);        
  tmp = zeros(length(I), 4*(1+numparts)+2);
  
  for i = 1:length(I)
    x = X(i);
    y = Y(i);
    [x1, y1, x2, y2] = rootbox(x, y, scale, padx, pady, rsize);
    b = [x1 y1 x2 y2];
    tmp(i,:) = [b 1 score(I(i))];
  end
  boxes = [boxes; tmp];
end


% The functions below compute a bounding box for a root or part 
% template placed in the feature hierarchy.
%
% coordinates need to be transformed to take into account:
% 1. padding from convolution
% 2. scaling due to sbin & image subsampling
% 3. offset from feature computation    

function [x1, y1, x2, y2] = rootbox(x, y, scale, padx, pady, rsize)
x1 = (x-padx)*scale+1;
y1 = (y-pady)*scale+1;
x2 = x1 + rsize(2)*scale - 1;
y2 = y1 + rsize(1)*scale - 1;

function [probex, probey, px, py, px1, py1, px2, py2] = ...
    partbox(x, y, ax, ay, scale, padx, pady, psize, Ix, Iy)
probex = (x-1)*2+ax;
probey = (y-1)*2+ay;
px = double(Ix(probey, probex));
py = double(Iy(probey, probex));
px1 = ((px-2)/2+1-padx)*scale+1;
py1 = ((py-2)/2+1-pady)*scale+1;
px2 = px1 + psize(2)*scale/2 - 1;
py2 = py1 + psize(1)*scale/2 - 1;


