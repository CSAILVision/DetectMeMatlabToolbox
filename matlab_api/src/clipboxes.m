function newboxes = clipboxes(im, boxes)

% boxes = clipboxes(im, boxes)
% Clips boxes to image boundary.
newboxes = [];
if ~isempty(boxes)
  boxes(:,1) = max(boxes(:,1), 1);
  boxes(:,2) = max(boxes(:,2), 1);
  boxes(:,3) = min(boxes(:,3), size(im.im, 2));
  boxes(:,4) = min(boxes(:,4), size(im.im, 1));
  for i=1:size(boxes,1)
     w =boxes(i,3)-boxes(i,1);
     h =boxes(i,4)-boxes(i,2);
     if w>100 && h >100
         newboxes = [newboxes ; boxes(i,:)];
     end
  end
end
