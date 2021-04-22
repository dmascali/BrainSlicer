function slicerCollage(list,varargin)



if nargin == 0
    %search slicer image in the current folder
    list = dir(['slicer_*.png']);
    if isempty(list)
        disp('No slicer png found.');
    end
    nImg = length(list);
    order = 1:nImg;
    %determin the dimenion to concatenate.
    %todo check dim compatibility
    img = imread(list(1).name);
    s = size(img); [~,dim] = min(s(1:2));
    output = 'slicerCollage';
else
    %--------------VARARGIN----------------------------------------------------
    params  =  {'order','dim','output'};
    defParms = {     [],   [],      'slicerCollage'};
    legalValues{1} = [];
    legalValues{2} = [1,2];
    legalValues{3} = [];
    [order,dim,output] = ParseVarargin(params,defParms,legalValues,varargin,1);
    %--------------------------------------------------------------------------
end
   
if isempty(list)
    list = dir(['slicer_*.png']);
    if isempty(list)
        disp('No slicer png found.');
    end
end
nImg = length(list);
   
if isempty(dim)
    img = imread(list(1).name);
    s = size(img); [~,dim] = min(s(1:2));    
end
  
if isempty(order)
    order = 1:nImg;
end

    
IMG = [];
for l = order
   img = imread(list(l).name); 
   IMG = cat(dim,IMG,img);
end
figure; 
imshow(IMG,'border','tight');
set(gca,'units','pixels') % set the axes units to pixels
x = get(gca,'position'); % get the position of the axes
set(gcf,'units','pixels') % set the figure units to pixels
y = get(gcf,'position'); % get the figure position
set(gcf,'position',[y(1) y(2) x(3) x(4)])% set the position of the figure to the length and width of the axes
set(gca,'units','normalized','position',[0 0 1 1]) % set the axes units to pixels


print([output,'.png'],'-dpng',['-r300'])

    
return
end