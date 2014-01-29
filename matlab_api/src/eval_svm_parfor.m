% **********************************************************************
% Evaluate a model learned with svm (use learn_svm1, in DTsvm folder)
%
% inputs:
% 
% - test: test images (Agata's PASCAL format, with test(i).rec, it's faster)
% - model: learned model (use train_generativeHOG)
% - (optional) thr: detection threshold, it uses the threshold of the model by default
% - (optional) message: additional text to display during the computations
% - (optional) boxes: boxes with the detections, if they are already computed 
% 
% output:
% 
% - rec: recall vector
% - prec: precision vector
% - ap2012: computed with VOC2012
% - ap2007: computed with VOC2007
% 
% **********************************************************************


function [rec,prec,ap2012, BB, ids, confidence, tp] = eval_svm_parfor(test,model,thr,boxes)
if nargin == 4
    if length(boxes) ~= length(test)
        display('Error');
        pause();
    end
end

if nargin < 3
    thr = model.thresh;
end

minoverlap = 0.4; 
cls = model.class;

if nargin < 4 % compute boxes
    % get detections
    %parfor i = 1:length(test)     
    parfor i = 1:length(test)  
        boxes{i} = process(test(i), model, thr); % detect objects
        %fprintf('%s: testing: %d/%d (%d detected boxes, avg score:%f)\n', cls, i, length(test), length(boxes{i}), mean(boxes{i}(:,end)));
    end
end

% extract ground truth objects and construct BB matrix
npos=0;
BB = [];
confidence = [];
k = 1;
for i=1:length(test)
    test(i).rec.objects;
    % extract objects of target class
    clsinds = strmatch(model.class, {test(i).rec.objects(:).class}, 'exact');
    gt(i).BB = cat(1, test(i).rec.objects(clsinds).bbox)';
    gt(i).diff = [test(i).rec.objects(clsinds).difficult];
    gt(i).det = false(length(clsinds),1);
    npos = npos + sum(~gt(i).diff);
    
    BB = [BB;boxes{i}];    
    for j = 1:size(boxes{i},1)
        ids(k) = i; % test(i).rec.filename(1:end-4);
        k = k + 1;
    end    
end
confidence = BB(:,end);
BB = BB(:,1:4);
BB = BB';


% sort detections by decreasing confidence
[sc,si]=sort(confidence,'descend');
confidence = confidence(si);
ids=ids(si);
BB=BB(:,si);
thresholds = sc;

% assign detections to ground truth objects
nd=size(BB,2); % number of total detections
tp=zeros(nd,1);
fp=zeros(nd,1);
tic;
for d=1:nd
    % display progress
    if toc>1
        %fprintf('%s: pr: compute: %d/%d\n',cls,d,nd);
        drawnow;
        tic;
    end
    
    % find ground truth image
    i = ids(d); 
    if isempty(i)
        error('unrecognized image "%s"',ids{d});
    elseif length(i)>1
        error('multiple image "%s"',ids{d});
    end

    % assign detection to ground truth object if any
    %size(gt(i).BB)
    bb=BB(:,d);
    ovmax=-inf;
    
    
    
    for j=1:size(gt(i).BB,2)
        bbgt=gt(i).BB(:,j);
        bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
        iw=bi(3)-bi(1)+1;
        ih=bi(4)-bi(2)+1;
        if iw>0 & ih>0                
            % compute overlap as area of intersection / area of union
            ua=(bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
               (bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1)-...
               iw*ih;
            ov=iw*ih/ua;
            if ov>ovmax 
                ovmax=ov;
                jmax=j;
                bi_max = bi;
            end
        end
    end
    % assign detection as true positive/don't care/false positive
    if ovmax>=minoverlap
        if ~gt(i).diff(jmax)
            if ~gt(i).det(jmax)
                tp(d)=1;            % true positive
                gt(i).det(jmax)=true;
            else
                fp(d)=1;            % false positive (multiple detection)
            end
        end
    
    else
        fp(d)=1;                    % false positive 
    end
end

% compute precision/recall
fp2 = cumsum(fp);
tp2 = cumsum(tp);
rec = tp2/npos;
prec = tp2./(fp2+tp2);


% AP with VOC2012 code
ap2012 = VOCap(rec,prec);

end

function ap = VOCap(rec,prec)

    mrec=[0 ; rec ; 1];
    mpre=[0 ; prec ; 0];
    for i = numel(mpre)-1:-1:1
        mpre(i) = max(mpre(i),mpre(i+1));
    end
    i = find(mrec(2:end)~=mrec(1:end-1))+1;
    ap = sum((mrec(i)-mrec(i-1)).*mpre(i));
end

