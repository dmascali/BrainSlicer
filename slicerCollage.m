function slicerCollage(list,varargin)

if nargin == 0
    %if no input is provided. Try to guess every parameter. Look for slicer
    %images in the current folder. 
    list = dir('slicer_*.png');
    if isempty(list)
        disp('No slicer png found.');
    end
    nImg = length(list);
    order = 1:nImg;
    %determin the dimenion to concatenate.
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
   
if isempty(list)
    list = dir('slicer_*.png');
    if isempty(list)
        disp('No slicer png found.');
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
  
IMG = [];
for l = order
   img = imread(list(l).name); 
   if l > 1 %check size consistency
      if any(size(img)~= s1)
          error('Images must have equal size.');
      end
   end
   IMG = cat(dim,IMG,img);
end
imwrite(IMG,[output,'.png']);

if showFigure
    figure('Name','SlicerCollage','MenuBar', 'None');
    warning off
    imshow(IMG,'border','tight');
    warning on
end
    
return
end