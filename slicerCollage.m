function slicerCollage(varargin)
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
%    dim           - Select the dimension along which to concatenate the
%                    images. Default: the longest dimension. 
%    order         - Vector of integers indicating the concatenation order.
%                    Default: 1:N, where N is the number of images. 
%    output        - Output name. Default: 'slicerCollage'. 
%    folder        - The path (relative or absolute) of the folder 
%                    containing slicer images. Default: './' (i.e., the 
%                    folder).
%    wildcard      - Char expression for matching slicer images (e.g.,:
%                    'slicer_BOLD*.png'). Default: 'slicer_*.png'. 
%    show          - Show combined image. Default: true. 
%
%   See also SLICER, COLORMAPS

%__________________________________________________________________________
% Daniele Mascali
% ITAB, UDA, Chieti - 2021
% danielemascali@gmail.com

% TODO:
% change showfigure to show
% concatenate opt variable if mat files are present

%--------------VARARGIN----------------------------------------------------
params  =  {'order','dim',       'output','showFigure','folder','wildcard'};
defParms = {     [],   [],'slicerCollage',           1,    './','slicer_*.png'};
legalValues{1} = [];
legalValues{2} = [1,2];
legalValues{3} = [];
legalValues{4} = [0,1];
legalValues{5} = [];
legalValues{6} = [];
[order,dim,output,showFigure,folder,...,
    wildcard] = ParseVarargin(params,defParms,legalValues,varargin,1);
%--------------------------------------------------------------------------
 
%get function name
funcName = mfilename;
fprintf('%s - welcome\n',funcName);

%get list of slicer images
if folder(end) ~= '/'; folder(end+1) = '/'; end
pattern = [folder,wildcard];
fprintf('%s - looking for images using the pattern:\n',funcName);
fprintf('%s \n',pattern);
list = dir(pattern);
if isempty(list)
    disp('No slicer png found.');
    return
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

% determine the minimum size across images.
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

if showFigure
    figure('Name','SlicerCollage','MenuBar', 'None');
    warning off
    imshow(IMG,'border','tight');
    warning on
end
    
fprintf('%s - end\n',funcName);
return
end