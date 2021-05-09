function slicerCollage(list,varargin)
%SLICERCOLLAGE Combine multiple slicer's images into a single image.
%  SLICERCOLLAGE() searches into the current folder for any slicer's image
%   and concatenate them along the longest dimension. To be concatenated
%   images must have the same number of pixels in the dimension used for
%   concatenation. The collage is saved in the current folder as
%   "slicerCollage.png".
%
%  The default beaviour can be modified using the following parameters 
%   (each parameter must be followed by its value ie, 'param1',value1, 
%   'param2',value2):  
%
%   COLORMAP('default') sets the current figure's colormap to
%   the root's default, whose setting is PARULA.
%
%   See also SLICER, COLORMAPS

%__________________________________________________________________________
% Daniele Mascali
% ITAB, UDA, Chieti - 2021
% danielemascali@gmail.com

% TODO:
% change showfigure to show
% concatenate opt variable if mat files are present

if nargin == 0
    %if no input is provided. Try to guess every parameter. Look for slicer
    %images in the current folder. 
    list = dir('slicer_*.png');
    if isempty(list)
        disp('No slicer images found.');
        return
    end
    nImg = length(list);
    order = 1:nImg;
    %determin the dimenion along which to concatenate images
    %todo check dim compatibility
    img = imread(list(1).name);
    s1 = size(img); [~,dim] = min(s1(1:2));
    output = 'slicerCollage';
    showFigure = 1;
else
    %--------------VARARGIN----------------------------------------------------
    params  =  {'order','dim',       'output','showFigure'};
    defParms = {     [],   [],'slicerCollage',           1};
    legalValues{1} = [];
    legalValues{2} = [1,2];
    legalValues{3} = [];
    legalValues{4} = [0,1];
    [order,dim,output,showFigure] = ParseVarargin(params,defParms,legalValues,varargin,1);
    %--------------------------------------------------------------------------
end
   
%get function name
funcName = mfilename;
fprintf('%s - welcome\n',funcName);

if isempty(list)
    list = dir('slicer_*.png');
    if isempty(list)
        disp('No slicer png found.');
        return
    end
end
nImg = length(list);

if isempty(order)
    order = 1:nImg;
end
   
if isempty(dim)
    img = imread(list(order(1)).name);
    s1 = size(img); [~,dim] = min(s1(1:2));    
end
  
fprintf('%s - dime  = %d\n',funcName,dim);
fprintf(['%s - order = ',repmat('%d ', 1, length(order)),'\n'],funcName,order);
fprintf('%s - concatenating images:\n',funcName);

count = 1;
img = cell(length(order),1);
sizeImg = nan(length(order),2);
for l = order
    img{count} = imread(list(l).name); 
    s = size(img{count});
    sizeImg(count,:) = [s(1) s(2)];   
    count = count +1;
end
commonSize = min(sizeImg);

IMG = [];
count = 1;
for l = order
   fprintf('-> %d(%d) %s\n',count,l,list(l).name);
   if l > 1 %check size consistency
      if any(size(img{count})~= s1)
          if abs(sum((size(img{count}) - s1))) > 2
            error('Images must have equal size.');
          end
      end
   end
   IMG = cat(dim,IMG,img{count}(1:commonSize(1),1:commonSize(2),:));
   count = count +1;
end
imwrite(IMG,[output,'.png']);

% IMG = [];
% count = 1;
% for l = order
%    img = imread(list(l).name); 
%    fprintf('-> %d(%d) %s\n',count,l,list(l).name);
%    if l > 1 %check size consistency
%       if any(size(img)~= s1)
%           %let's see if it is just one voxel. Sometimes this happens.
%           if sum((size(img) - s1)) <=2
%               img = img(1:s1(1),1:s1(2),:);
%               fprintf('One voxel mismatch found, the image has been cropped.');
%           else
%             error('Images must have equal size.');
%           end
%       end
%    end
%    IMG = cat(dim,IMG,img);
%    count = count +1;
% end
% imwrite(IMG,[output,'.png']);

if showFigure
    figure('Name','SlicerCollage','MenuBar', 'None');
    warning off
    imshow(IMG,'border','tight');
    warning on
end
    
fprintf('%s - end\n',funcName);
return
end