function slicer(img,varargin)
%
%
% Properties:
%   
%   BASIC:
%     limits
%     minClusterSize
%     labels
%     output
%     title
%   MONTAGE:
%     view
%     mount
%     slices
%     skip
%   APPEARANCE:
%     colormaps
%     alpha
%     colorBarLocation
%     margins
%     innerMargins
%     colorMode
%     resolution           - 
%     showCoordinates      - Show plane coordinates
%     coordinateLocation   - Location of plane coordinates
%     
%     
%     
%   

if nargin == 0 %test mode
    load ./exampleData/data_test;
    underlay = bg.img;
    overlay = ol.img;
    img = {underlay,overlay};
    %img = {'spmT_0001.nii'};
%    limits = {[1000 10000], [3.16 5]};
% %     minClusterSize = {[], 200};
% %     colormaps = {'gray','hot'};
%     alpha = {0 1};
     %Title = 'Test p HC HC';
%     fontsize.Title = 12; % in points (1 point is 1/72 inches)
%     resolution = '500';  %pixels/inches
%     labels = {[],'t-value'};
%     cbLocation = 'best';
%     margins = [0 0 0 0]; %left right top bottom
%     
%     mount = [3,5];
%     view = 'ax';
    
    %optional
    % background_suppression = 1;
end

nLayers = length(img);
for l = 1:nLayers
    if ischar(img{l})  %in case data is a path to a nifti file
        %store image path
        img_paths{l} = img{l};
        hdr = spm_vol(img{l});
        img{l} = spm_read_vols(hdr);       
    end
end
layerStrings = cellstr(num2str([1:nLayers]')); %this is used to construct default parameters
colorbarDefaultList = {1,2,3,4,5};

%--------------VARARGIN----------------------------------------------------
params  =  {'labels','limits','minClusterSize','colormaps','alpha','cbLocation',...
            'margins', 'innerMargins','mount', 'view','resolution','zscore',...
            'slices','skip','colormode','showCoordinates','coordinateLocation',...
            'title','output','fontsize'};
defParms = {cellfun(@(x) ['img',x],layerStrings,'UniformOutput',0)', ... % labels
            cellfun(@(x) [min(x(:)) max(x(:))],img,'UniformOutput',0),... % limits: use min and max in each image as limits
            cell(1,nLayers),... % minClusterSize
            colorbarDefaultList(1:nLayers),... % colormaps
            num2cell(ones(1,nLayers)),...% alpha lelvel
            'best', [0 0 0 0], [0 0], ... % cbLocation; margins; InnerMargins
            [2 6],   'ax', '300',... % mount; view; resolution
            cell(1,nLayers), 'auto', [0.2 0.2],... %zscore; sclice; skip
            'k',  1, 'sw',... % colorMode; showCoordinates; coordinateLocation
            [], [], [12 10 6]}; % title; output; fontsize(title,colorbar,coord)
legalValues{1} = {@(x) (iscell(x) && length(x) == nLayers),['Labels is expected '...
    'to be a cell array whose length equals the number of layers. Empty labels ',...
    'will result in no colorbar.']};
legalValues{2} = {@(x) (iscell(x) && length(x) == nLayers && sum(cellfun(@numel, x)/nLayers) == 2),...
    ['Limits is expected to be a cell array whose length equals the number of layers. ',...
    'Each cell is expected to be a 2-element vector. Empty vectors are not allowed.']};
legalValues{3} = {@(x) (iscell(x) && length(x) == nLayers),['MinClusterSize is ',...
    'expected to be a cell array whose length equals the number of layers.']};
legalValues{4} = {@(x) (iscell(x) && length(x) == nLayers),['Colormaps is expected '...
    'to be a cell array whose length equals the number of layers. Each cell ',...
    'indicates a colormap which can be selected either by its name (string) or ',...
    'by its index (scalar). Run ''colormaps'' in matalab command window '...
    'for a list of available colormaps.']};
legalValues{5} = {@(x) (iscell(x) && length(x) == nLayers),['Alpha is ',...
    'expected to be a cell array whose length equals the number of layers (0<=alpha<=1).']};
legalValues{6} = {'best','south','east'};
legalValues{7} = {@(x) (~ischar(x) && numel(x)==4 && sum(x <= 1) == 4),['Margin is expected ',...
    'to be a 4-element vector: [left right top bottom]. Margins are in percentage (0-1).']};
legalValues{8} = {@(x) (~ischar(x) && numel(x)==2 && sum(x <= 1) == 2),['InnerMargins is expected ',...
    'to be a 2-element vector: [x y]. InnerMargins define the space between slices and ',...
    'are in percentage (0-1).']};
legalValues{9} = {@(x) (~ischar(x) && numel(x)==2 && all(mod(x,1)==0) && all(x>0)),['Mount is ',...
    'expected to be a 2-element vector: [rows columns]. Only positive integers are allowed.']};
legalValues{10} = {'ax','sag','cor'};
legalValues{11} ={@(x) (ischar(x) || numel(x) == 1),['Resolution is expected to be a scalar ',...
    'or char.']}; 
legalValues{12} =[]; %zscore
legalValues{13} ={@(x) ( (ischar(x) && strcmpi(x,'auto')) || (isnumeric(x)) && all(mod(x,1)==0) && all(x>0)),['Slice is expected ',...
    'to be either ''auto'' or an integer vector indicating the slices to be plotted.']}; 
legalValues{14} ={@(x) (~ischar(x) && numel(x)==2),['Skip is expected to be a ',...
    'a 2-element vector: [bottom top].']};
legalValues{15} = {'k','black','w','white'};
legalValues{16} = [0 1]; %showCoordinates
legalValues{17} = {'north','south','east','west','n','s','e','w','northeast','northwest',...
    'southeast','southwest','ne','nw','se','sw'};
legalValues{18} = []; %title
legalValues{19} = []; %output
legalValues{20} = {@(x) (~ischar(x) && numel(x)==3 && all(x>0)),['FontSize is expected ',...
    'to be a 3-element vector: [Title ColorbarLabel Coordinate]. Default is [12 10 6].']};
[labels,limits,minClusterSize,colorMaps,alpha,cbLocation,margins,...
    innerMargins,mount,view,resolution,zScore,slices,skip,colorMode,...
    showCoordinates,coordinateLocation,Title,output,...
    fontSize] = ParseVarargin(params,defParms,legalValues,varargin,1);
%--------------------------------------------------------------------------

%TODO add check for consistency between images

%get function name
funcName = mfilename;
fprintf('%s - welcome\n',funcName);

%check Matlab version, stop if version is older than:
matlabVersion = version;
matlabVersion = str2num(matlabVersion(1:3));

switch colorMode
    case {'k','black'}
        colorSet.background = 'k';
        colorSet.fonts = 'w';
    case {'w','white'}
        colorSet.background = 'w';
        colorSet.fonts = 'k';
end

%convert colormaps from selectors to actual maps
%first store user input to later save in opt variable
colorMapsInput = colorMaps;
for l = 1:nLayers
    a = colorMaps{l};
    if isnumeric(a)
        map = colormaps(abs(a));
        if a < 0 %flip the map
            map = flip(map);
        end
    else % no way to flip 
        map = colormaps(a);
    end
    % The default behaviour is to flip the map if both limits are negative.
    % The user can revert this by using a "negative" map (see above).
    if all(limits{l} <= 0)
        map = flip(map);
    end
    colorMaps{l} = map;        
end

%get info specific to the type of view
s =  size(img{1});
switch view
    case {'ax'}
        n_slices = s(3);
        for l = 1:nLayers
            img{l} = flipdim(img{l},2);
        end
        sliceDim = [s(1) s(2)];
    case {'sag'} %this might be flipped
        n_slices = s(1);
        sliceDim = [s(2) s(3)];
    case {'cor'} %this might be flipped
        sliceDim = [s(1) s(3)];
        n_slices = s(3);
end
if ischar(slices) %it means is auto
    slicesMode = 'auto';
    if ~isempty(skip)
        if skip(1) < 1; skip(1) = skip(1)*n_slices; end
        if skip(2) < 1; skip(2) = skip(2)*n_slices; end
    else
        skip = [0 0];
    end
    planes = fix(linspace( 1+(skip(1)) , n_slices-(skip(2)) ,mount(2)*mount(1)));
else
    skip = [];
    slicesMode = 'manual';
    planes = slices;
end
%planes = fix(linspace(1,n_slices,mount(2)*mount(1)));

%zscore images if required
img = zscore_images(img,zScore,nLayers);

%threshold images
img = threshold_images(img,limits,minClusterSize,nLayers);

%determin the number of colorbars based on variable labels. Layers with
%empty labels will not have colorbars
colorbarIndex = find(cellfun(@(x) ~isempty(x),labels));
colorbarN = length(colorbarIndex);
if colorbarN == 0
    cbLocation = 'none';
end

if ~isempty(Title)
    %Defines how many pixels the title occupies
    titleInInches = (fontSize(1)+1) *1/72; %add one points to increase top space and convert points to inches
    % now convert inches to pixels
    %this needs at least matlab 8.6 (R2015b).
    if matlabVersion >= 8.6 && (ispc || ismac)
        if ispc
            ScreenPixelsPerInch = 96;
        elseif ismac
            ScreenPixelsPerInch = 72;
        end
    else
        % in case of unix or older versions
        ScreenPixelsPerInch = java.awt.Toolkit.getDefaultToolkit().getScreenResolution();
    end
    titleInPixels = titleInInches*ScreenPixelsPerInch;
else
    titleInPixels = [];
end

[hFig,pos,cbConfig,figPos] = figureGrid(mount,sliceDim,margins,innerMargins,colorbarN,cbLocation,titleInPixels); %left right top bottom %x,y

set(hFig,'color',colorSet.background);

if showCoordinates
    planeCord = plane_coordinates(coordinateLocation);
    if exist('hdr','var')
        coordinates = xyz2mm(planes,hdr(1).mat,view);
        fprintf('%s - coordinates are in mm\n',mfilename);
    else
        coordinates = planes;
        fprintf('%s - coordinates are in voxels\n',mfilename);
    end
end

count = 0;
for row = 1:mount(1)
    for col = 1:mount(2)
        count = count +1;
        h_ax = plot_slice(pos{row,col},img,view,planes(count),limits,colorMaps,alpha);
        if count == 1
            firstAxe = h_ax;
        end
        if showCoordinates
            text(planeCord{1},planeCord{2},num2str(coordinates(count)),'Color',colorSet.fonts,'verticalAlignment',planeCord{4},'HorizontalAlignment',planeCord{3},'FontSize',fontSize(3),'FontUnits','points','Units','normalized','FontWeight','normal');
        end
    end
end


for l = 1:colorbarN
    cb = colorbar(h_ax(colorbarIndex(l)),'Location',cbConfig.location,'Position',cbConfig.colorbarPos{l},'Color','w');
    cb.Label.String = labels{colorbarIndex(l)};
    cb.Label.FontSize = fontSize(2);
    cb.Label.Color = colorSet.fonts;
    cb.Color = colorSet.fonts;
end

%remove any underscore present in the title
if ~isempty(Title)
    Title(strfind(Title,'_')) = '';
    text(firstAxe(1),0,1,Title,'Color',colorSet.fonts,'verticalAlignment','bottom','HorizontalAlignment','left','FontSize',fontSize(1),'FontUnits','points','Units','normalized','FontWeight','Bold');
end

% print figure if an output name is specified
if ~isempty(output)
    %remove any blank space in the outputname
    output(strfind(output,' ')) = '_';
    
    % decompose output name just in case there is a path
    [fp,nm,ext] = fileparts(output);
    if ~isempty(fp);fp = [fp,filesep];end
        
    %preappend function name
    output = [fp,funcName,'_',nm,ext];
    
    set(gcf, 'InvertHardcopy', 'off','PaperPositionMode','auto');
    %force again the position
    set(gcf,'Position',figPos);
    print([output,'.png'],'-dpng',['-r',resolution])

    % Store parameters in a structure
    
    opt.nLayers = nLayers;
    paths = GetFullPath(img_paths);
    for l = 1:nLayers; opt.(['img',num2str(l)]) = paths{l}; end
    opt.limits = limits;
    opt.minClusterSize = minClusterSize;
    opt.colorMaps = colorMapsInput;
    opt.labels = labels;
    opt.opacityLevels = alpha;
    opt.montage.view = view;
    opt.montage.mount = mount;
    opt.montage.slicesMode = slicesMode;
    opt.montage.slices = slices;
    opt.montage.skip = skip;  %it's not anymore in %, now is in slices.
    opt.appearance.colorMode = colorMode;
    opt.appearance.margins = margins;
    opt.appearance.innerMargins = innerMargins;
    opt.appearance.colorBarLocation0 = cbLocation;
    opt.appearance.showCoordinates = showCoordinates;
    opt.appearance.coordinateLocation = coordinateLocation;
    opt.appearance.resolution = resolution;

    save([output,'.mat'],'opt');
else
    fprintf('%s - no figure will be printed. Use ''output'' to save the figure.\n',funcName);
end

fprintf('%s - end\n',funcName);

return
end

function planeCordSettings = plane_coordinates(coordlocation)

switch lower(coordlocation)
    case {'north','n'}
        planeCordSettings = {0.5,1,'center','top'};
    case {'south','s'}
        planeCordSettings = {0.5,0,'center','bottom'};
    case {'east','e'}
        planeCordSettings = {1,0.5,'right','center'};
    case {'west','w'}
        planeCordSettings = {0,0.5,'left','center'};
    case {'northeast','ne'}
        planeCordSettings = {1,1,'right','top'};
    case {'northwest','nw'}
        planeCordSettings = {0,1,'left','top'};
    case {'southeast','se'}
        planeCordSettings = {1,0,'right','bottom'};
    case {'southwest','sw'}
        planeCordSettings = {0,0,'left','bottom'};
end

return
end


function h_ax = plot_slice(pos,img,plane,coordinates,limits,colorMaps,alphas)
nLayers = length(img);
ax = cell(nLayers,1);
h_ax = [];
%cycle on layers
for l = 1:nLayers
    ax{l} = axes('Position',pos);
    if l > 0 % set to 1 to exlude first layer
        %pixel to be transpart are marked by Nans
        alphadata = alphas{l}.*ones(size(img{l}));
        %alphadata(img{l} == 0) = 0;
        alphadata(isnan(img{l})) = 0;
    else
        alphadata = [];
    end
    draw_layer(plane,img{l},coordinates,limits{l},alphadata)
    colormap(ax{l},colorMaps{l});
    h_ax = [h_ax,ax{l}];
end
linkaxes(h_ax);
return
end

function img = threshold_images(img,limits,minClusterSize,nLayers)
%cycle on layers
for l = 1:nLayers
    low = limits{l}(1);
    up  = limits{l}(2);
    %there are three limits cases:
    % 1) + + -> threshold on min saturate on max
    % 2) - - -> threshold on max saturate on min
    % 3) - + -> threshold on min saturate on max (arbitrary choice. We might deal with the
    %        opposite case in the future)
    if all(limits{l}>=0) %case 1 
        img{l}(img{l} <= low) = NaN;
    elseif all(limits{l}<=0)  %case 2
        img{l}(img{l} >= up) = NaN;
    else %case 3
        img{l}(img{l} <= low) = NaN;
    end
    if not(isempty(minClusterSize{l})) | (minClusterSize{l} > 1)
        %binarize img
        a = img{l}; a(isnan(a)) = 0; a(a~=0) = 1;
        %find connected clusters
        [L,num] = spm_bwlabel(a,18);
        for j = 1:num
            indx = find(L==j);
            if length(indx) < minClusterSize{l}
                %then remove indices
                L(indx) = 0;
            end
        end
        %find not surviving indices
        indx = find(L==0);
        img{l}(indx) = NaN;
    end
end
return
end

function img = zscore_images(img,zScore,nLayers)
%cycle on layers
for l = 1:nLayers
    if isempty(zScore{l}) || zScore{l} == 0
        continue
    end
    % NB: this function is provisional. it only works for positive images.
    % Zero indeed are not considered legal values.
    %find non zero voxels
    indxZero = find(img{l} == 0);
    indx = find(img{l});
    a = img{l}(indx);
    a = zscore(a);
    img{l}(indx) = a;
    img{l}(indxZero) = NaN;
end
return
end


function draw_layer(plane,img,coordinates,limits,alphadata)

if nargin < 5
    alphadata = [];
end

switch plane
    case {'ax'}
        img = squeeze(img(:,:,coordinates))';
        if not(isempty(alphadata))
            alphadata = squeeze(alphadata(:,:,coordinates))';
        else
            alphadata = 1;
        end
    case {'sag'}
        img = flipdim(flipdim(squeeze(img(coordinates,:,:)),2)',2);
        if not(isempty(alphadata))
            alphadata = flipdim(flipdim(squeeze(alphadata(coordinates,:,:)),2)',2);
        else
            alphadata = 1;
        end
    case {'cor'}
        img = flipdim(squeeze(img(:,coordinates,:))',1);
        if not(isempty(alphadata))
            alphadata = flipdim(squeeze(alphadata(:,coordinates,:))',1);
        else
            alphadata = 1;
        end
end

imagesc(img,'AlphaData',alphadata); ax = gca; ax.CLim = limits;
AXIS = [1 size(img,2) 1 size(img,1)];
axis(AXIS);

set(gca,'Visible','off');
return
end

function mm = xyz2mm(xyz,mat,view)

voxelSize = [mat(1,1), mat(2,2), mat(3,3)]';
origin = round(mat(1:3,4)./voxelSize);
if nargin == 2
    if isrow(xyz)
        xyz = xyz';
    end
    mm = voxelSize.*(xyz + origin);
else
    switch view
        case {'ax'}
            mm = voxelSize(3)*(xyz + origin(3));
        case {'sag'}
            mm = voxelSize(1)*(xyz + origin(1));
        case {'cor'}
            mm = voxelSize(2)*(xyz + origin(2));
    end
end

return
end