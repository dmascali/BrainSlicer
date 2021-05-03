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
   
%get function name
funcName = mfilename;
fprintf('%s - welcome\n',funcName);

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
  
fprintf('%s - dime  = %d\n',funcName,dim);
fprintf(['%s - order = ',repmat('%d ', 1, length(order)),'\n'],funcName,order);
fprintf('%s - concatenating images:\n',funcName);

IMG = [];
count = 1;
for l = order
   img = imread(list(l).name); 
   fprintf('-> %d(%d) %s\n',count,l,list(l).name);
   if l > 1 %check size consistency
      if any(size(img)~= s1)
          %let's see if it is just one voxel. Sometimes this happens.
          if sum((size(img) - s1)) <=2
              img = img(1:s1(1),1:s1(2),:);
              fprintf('One voxel mismatch found, the image has been cropped.');
          else
            error('Images must have equal size.');
          end
      end
   end
   IMG = cat(dim,IMG,img);
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