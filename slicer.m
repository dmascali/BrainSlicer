function slicer(img,varargin)
% SLICER Visualize and print volumetric brain data. 
%   SLICER(IMG) shows a bunch of slices from IMG. IMG is expected to be a 
%   cell array containing either paths to NIfTI volumes or 3D matrices. 
%   Each cell in IMG represents a layer, each layer is plotted on top of 
%   previous layers.
%   To print the figure as PNG use the "output" option (see below). A mat
%   file, which stores info related to the printed figure, will be saved too. 
%
% Options can be specified using the following parameters (each parameter 
%   must be followed by its value ie,'param1',value1,'param2',value2. 
%   NB: when a cell array is required, its length needs to be equal to the
%   number of layers):
%   
%   BASIC:
%     limits               - CellArray. Each cell is expected to be a 
%                            2-element vector indicating minimum and maximum
%                            values to be displayed for that layer. For 
%                            empty vectors the min and max value across the
%                            volume is used. Default: {[]}.
%     minClusterSize       - CellArray. Each cell contains the minimum 
%                            cluster size that is allowed (in voxels) for 
%                            that layer. Default: {[]}.
%     colormaps            - CellArray. Each cell indicates a colormap 
%                            which can be selected either by its name (char)
%                            or by its index (scalar). Run 'colormaps' 
%                            in matalab command window for a list of 
%                            available maps.
%     labels               - CellArray. Each layer is associated with a
%                            colorbar, this option allows you to specify
%                            the label on each colorbar. Empty cell will
%                            result in no colorbar appearing for that
%                            layer.[e.g., {[],'t-maps'} will show the
%                            colorbar for the second layer only]. 
%     output               - Char. Export the figure as PNG using the 
%                            specified ouptut name. Without this option,
%                            no figure will be printed. Default: [].
%     volume               - CellArray. In case IMG contains multiple
%                            temporal volumes, this option allows you to 
%                            specify which volume needs to be plotted. 
%                            Default: {1} 
%     p-map                - CellArray of boolean values. If you are plotting
%                            a p-value map use this flag to create a 1-p map,
%                            so that the image can be thresholded appropriately
%                            (e.g, [0.95 1]). Default: {false}
%
%   MONTAGE:
%     view                 - Char. Choose between one of the three planes:
%                            'ax','sag','cor'. Default: 'ax'. 
%     mount                -
%     slices               - Char/Vector. 
%     skip                 - 2-element vector. When 'slices' is set to 'auto',
%                            you can specify how many slices to skip from
%                            the beginning and end of the series. If values
%                            are < 1, values are considered as percent
%                            (i.e, skip as many slices corresponding to the
%                            percentage value). Default: [0.2 0.2]
%
%   APPEARANCE:
%     title                - Char. Show a title on the top-left corner. 
%                            Default: [].
%     alpha                - CellArray. Each cell indicates the layer's 
%                            opacity level ( 0<=alpha<=1 ). Default = {1}
%     cbLocation           - Char. Specify the location for the colorbars.
%                            Available locations are:
%                            'best','south','east'. Default = 'best'.
%                            If the colorbar is not desired (i.e., labels
%                            set to empty) but you still wish to get the 
%                            same margins as if there were the colorbar, you
%                            can use the following cbLocation values: 
%                           'void','southvoid','eastvoid'.
%     fontsize             - 3-element vector specifying the fontsize of:
%                            [Title, ColorBarLabel, Coordinates]. 
%                            Default: [12,10,6].
%     margins              - 4-element vector specifying figure margins:
%                            [left right top bottom]. Margins are in 
%                            percentage (0-1). Defalut = [0 0 0 0].
%     innerMargins         - 2-element vector specifying the space between
%                            slices: [x y].  InnerMargins are in 
%                            percentage (0-1) and can also be negative in
%                            case you wish to crop the images (useful with
%                            large bounding boxes). Defalut = [0 0].
%     colorMode            - Char. Two colorMode are available: 'black' (or
%                            'k') for a dark mode in which the background is
%                            black, or a 'white' (or 'w') for a light mode
%                            in which the background is white. Default:
%                            'black'.
%     resolution           - Scalar/char indicating the PNG resolution.
%                            Default: 300. 
%     size                 - Char. Define the size of the printed figure 
%                            by specifing either the figure hight or
%                            the figure width in mm. You cannot specify both
%                            since the aspect ratio is dictated by the
%                            number of slices. E.g.: 'w170' or 'h30' (i.e.,
%                            width of 170 mm or hight of 30 mm).
%     showCoordinates      - Boolean. Show plane coordinates. Default:
%                            True.
%     coordinateLocation   - Char. Location of plane coordinates. Available
%                            locations are: 'north','south','east','west',
%                            'northeast','northwest','southeast','southwest',
%                            or aliases: 'n','s','e','w','ne','nw','se',
%                            'sw'. Default: 'southwest'.
%   MISCELLANEOUS:
%     show                 - Boolean. Show figure. Default: True. 
%     noMat                - Boolean. Do not output the mat file containing
%                            info related to the printed figure. Default:
%                            False.
%     
%     
%     
%   See also SLICERCOLLAGE, COLORMAPS

funcName = mfilename; %get function name
if nargin == 0
    help(funcName)
    return
end

nLayers = length(img);
for l = 1:nLayers
    if ischar(img{l})  %in case data is a path to a nifti file
        %store image path
        imgPaths{l} = img{l};
        [~,hdr] = evalc('spm_vol(img{l});'); % to avoid an annoying messange in case of .gz
        img{l} = spm_read_vols(hdr);       
    end
    %check consistency between images
    if l == 1 
        s = size(img{l});
        if numel(s) < 3; error('Bad defined IMG: 3D or 4D images are required.'); end
    end
    if l > 1
        sCurrent = size(img{l}); sCurrent = sCurrent(1:3);
        if ~isequal(sCurrent,s(1:3)) 
            error('Image size mismatch for layer %d.',l);
        end
    end 
end

layerStrings = cellstr(num2str([1:nLayers]')); %this is used to construct default parameters
colorbarDefaultList = {1,2,3,4,5};

%--------------VARARGIN----------------------------------------------------
params  =  {'labels','limits','minClusterSize','colormaps','alpha','cbLocation',...
            'margins', 'innerMargins','mount', 'view','resolution','zscore',...
            'slices','skip','colormode','showCoordinates','coordinateLocation',...
            'title','output','fontsize','noMat','show','volume','p-map','size'};
defParms = {cellfun(@(x) ['img',x],layerStrings,'UniformOutput',0)', ... % labels
            cellfun(@(x) [min(x(:)) max(x(:))],img,'UniformOutput',0),... % limits: use min and max in each image as limits
            cell(1,nLayers),... % minClusterSize
            colorbarDefaultList(1:nLayers),... % colormaps
            num2cell(ones(1,nLayers)),...% alpha lelvel
            'best', [0 0 0 0], [0 0], ... % cbLocation; margins; InnerMargins
            [2 6],   'ax', '300',... % mount; view; resolution
            cell(1,nLayers), 'auto', [0.2 0.2],... %zscore; slice; skip
            'k',  1, 'sw',... % colorMode; showCoordinates; coordinateLocation
            [], [], [8 6 4],..., % title; output; fontsize(title,colorbar,coord),
            0, 1, num2cell(ones(1,nLayers)),...%  noMat, show, volume
            num2cell(zeros(1,nLayers)),[]}; % p-map, size
legalValues{1} = {@(x) (iscell(x) && length(x) == nLayers),['Labels is expected '...
    'to be a cell array whose length equals the number of layers. Empty labels ',...
    'will result in no colorbar.']};
legalValues{2} = {@(x) (iscell(x) && length(x) == nLayers && all(cellfun(@(x) (isempty(x) || numel(x) == 2),x))),...
    ['Limits is expected to be a cell array whose length equals the number of layers. ',...
    'Each cell is expected to be either a 2-element vector or an empty vector (automatic limits).']};
legalValues{3} = {@(x) (iscell(x) && length(x) == nLayers),['MinClusterSize is ',...
    'expected to be a cell array whose length equals the number of layers.']};
legalValues{4} = {@(x) (iscell(x) && length(x) == nLayers),['Colormaps is expected '...
    'to be a cell array whose length equals the number of layers. Each cell ',...
    'indicates a colormap which can be selected either by its name (string) or ',...
    'by its index (scalar). Run ''colormaps'' in matalab command window '...
    'for a list of available colormaps.']};
legalValues{5} = {@(x) (iscell(x) && length(x) == nLayers),['Alpha is ',...
    'expected to be a cell array whose length equals the number of layers.']};
legalValues{6} = {'best','south','east','eastvoid','southvoid','void'};
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
legalValues{17} = {'north','south','east','west','northeast','northwest',...
    'southeast','southwest','n','s','e','o','ne','nw','se','sw'};
legalValues{18} = []; %title
legalValues{19} = []; %output
legalValues{20} = {@(x) (~ischar(x) && numel(x)==3 && all(x>0)),['FontSize is expected ',...
        'to be a 3-element vector: [Title ColorbarLabel Coordinate]. Default is [12 10 6].']};
legalValues{21} = [0 1]; %noMat
legalValues{22} = [0 1]; %Show
legalValues{23} = {@(x) (iscell(x) && length(x) == nLayers && all(cellfun(@(x) (mod(x,1)==0 && x > 0),x)) ),['Volume is ',...
    'expected to be a cell array whose length equals the number of layers. For 4-D images, this option ',...
    'allows you to select the temporal volume to be consider. Positive integers are allowed.']};
legalValues{24} = {@(x) (iscell(x) && length(x) == nLayers),['P-map is ',...
    'expected to be a cell array whose length equals the number of layers. If you are plotting ',...
    'a p-value map this option will create a 1-p map, so that you can threshold it appropriately.']};
legalValues{25} = []; %todo check for size
[labels,limits,minClusterSize,colorMaps,alpha,cbLocation,margins,...
    innerMargins,mount,view,resolution,zScore,slices,skip,colorMode,...
    showCoordinates,coordinateLocation,Title,output,fontSize,noMat,...
    show,volume,pmap,printSize] = ParseVarargin(params,defParms,legalValues,varargin,1);
%--------------------------------------------------------------------------

fprintf('%s - welcome\n',funcName);

% Define default values that cannot be assigned by ParseVarargin (e.g.,
% empty vectors within the cells).
if any(cellfun(@isempty,limits))
    indx = find(cellfun(@isempty,limits));
    autoLimits = cellfun(@(x) [min(x(:)) max(x(:))],img,'UniformOutput',0);
    limits(indx) = autoLimits(indx);
end

%check if there are 4D volumes
is4D = cellfun(@(x) numel(size(x)) > 3,img,'UniformOutput',1);
if any(is4D)
    indx = find(is4D);
    fprintf('%s - warning: layer(s) %d has(have) multiple volumes\n',funcName,length(indx));
    if sum([volume{:}])/nLayers > 1
        for l = 1:length(indx)
            %TODO: add error checking
            img{indx(l)} = img{indx(l)}(:,:,:,volume{indx(l)});
            fprintf('%s - selecting volume %d for layer %d\n',funcName,volume{indx(l)},indx(l));
        end
    else
        frpintf([repmat(' ',length([funcName,' - '])),'use ''volume'' to select volumes\n']); 
    end
end

%check for p-maps
if sum([pmap{:}]) >= 1
   indx = find([pmap{:}]);
   for l = 1:length(indx)
       %find where image is greater than zero
       indxMap = find(img{indx});
       img{indx}(indxMap) = 1 - img{indx}(indxMap);
   end   
end

%check Matlab version, stop if version is older than TODO:
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
%first store user input for later saving in opt variable
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
        for l = 1:nLayers
            img{l} = flipdim(img{l},2);
        end
        sliceDim = [s(1) s(2)];
    case {'sag'} %this might be flipped
        sliceDim = [s(2) s(3)];
    case {'cor'} %this might be flipped
        sliceDim = [s(1) s(3)];
end
if ischar(slices) %it means is auto
    slicesMode = 'auto';
    switch view
        case 'ax', totalSlices = s(3);
        case 'sag',totalSlices = s(1);
        case 'cor',totalSlices = s(2);
    end
    if ~isempty(skip)
        if skip(1) < 1; skip(1) = skip(1)*totalSlices; end
        if skip(2) < 1; skip(2) = skip(2)*totalSlices; end
    else
        skip = [0 0];
    end
    planes = fix(linspace( 1+(skip(1)) , totalSlices-(skip(2)) ,mount(2)*mount(1)));
    nPlanes = length(planes);
else
    skip = [];
    slicesMode = 'manual';
    planes = slices;
    nPlanes = length(planes);
    if nPlanes > mount(2)*mount(1)
        % let's adjust mount 
        discrepancy = length(planes) - mount(2)*mount(1);
        [~,maxIndx] = max(mount); [~,minIndx] = min(mount);
        % how many row/column to add to cover the discrepancy?
        toAdd = ceil(discrepancy/(mount(maxIndx)));
        mount(minIndx) = mount(minIndx) + toAdd;
    elseif nPlanes < mount(2)*mount(1)
        % let's handle the case the slices are fewer than the largest
        % dimension of mount
        [~,maxIndx] = max(mount); [~,minIndx] = min(mount);
        if nPlanes <= mount(maxIndx)
            mount(minIndx) = 1;
            mount(maxIndx) = nPlanes;
        end
    end
end

%zscore images if required
img = zscore_images(img,zScore,nLayers);

%threshold images
img = threshold_images(img,limits,minClusterSize,nLayers);

%determin the number of colorbars based on labels. Layers with
%empty labels will not have colorbars
colorbarIndex = find(cellfun(@(x) ~isempty(x),labels));
colorbarN = length(colorbarIndex);
if sum(strcmpi(cbLocation,{'eastvoid','southvoid','void'})) > 0
    % override any indication in labels by forcing colobarN to be zero
    colorbarN = 0;
end
if colorbarN == 0 && sum(strcmpi(cbLocation,{'eastvoid','southvoid','void'})) == 0
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

% define figure position, each axe position and colorbars
[hFig,pos,cbConfig,figPos] = figureGrid(mount,sliceDim,margins,innerMargins,colorbarN,cbLocation,titleInPixels,show); %left right top bottom %x,y

set(hFig,'color',colorSet.background);

if showCoordinates
    planeCord = plane_coordinates(coordinateLocation);
    if exist('hdr','var')
        coordinates = xyz2mm(planes,hdr(1).mat,view);
        fprintf('%s - coordinates are in mm\n',mfilename);
    else
        coordinates = planes;
        fprintf('%s - coordinates are in voxel units\n',mfilename);
    end
end

count = 0;
for row = 1:mount(1)
    for col = 1:mount(2)
        count = count +1;
        if count > nPlanes
            break
        end
        h_ax = plot_slice(pos{row,col},img,view,planes(count),limits,colorMaps,alpha);
        if count == 1
            firstAxe = h_ax;
        end
        if showCoordinates
            text(planeCord{1},planeCord{2},num2str(coordinates(count)),'Color',colorSet.fonts,...
                'verticalAlignment',planeCord{4},'HorizontalAlignment',planeCord{3},...
                'FontSize',fontSize(3),'FontUnits','points','Units','normalized','FontWeight','normal');
        end
    end
end

for l = 1:colorbarN
    cb = colorbar(h_ax(colorbarIndex(l)),'Location',cbConfig.location,'Position',cbConfig.colorbarPos{l},'Color','w');
    cb.Label.String = labels{colorbarIndex(l)};
    cb.Label.FontSize = fontSize(2);
    cb.FontSize = fontSize(2);
    cb.Label.Color = colorSet.fonts;
    cb.Color = colorSet.fonts;
    ticksMode = 'matlab';
    switch ticksMode 
        case 'matlab'
            % do nothing
        case  2
            set(cb,'Ticks',cb.Limits);
        case 'mix'
            limitsIncluded = ismember(cb.Limits,cb.Ticks);
            a = cb.Limits; b = cb.Ticks; delta = mean(diff(b));
            if limitsIncluded(2); a(2) = []; end 
            if limitsIncluded(1); a(1) = []; end
            b = sort([a, b]);
            %exclude ticks if too close to each others
            if abs(b(end) - b(end-1)) <= 0.5*delta
                b(end-1) = [];
            end
            if abs(b(2)-b(1)) <= 0.5*delta
                b(2) = [];
            end
            set(cb, 'Ticks', b)
        case 'manual'
            nTicks = length(cb.Ticks);
            Ticks = linspace(cb.Limits(1),cb.Limits(2),nTicks);
            Ticks(2:end-1) = round(Ticks(2:end-1),2,'significant');
            set(cb,'Ticks',Ticks);
%             TickLabels = arrayfun(@(x) sprintf('%1g',x),Ticks,'un',0);
%             set(cb,'TickLabels',TickLabels);
    end
end

%remove any underscore present in the title
if ~isempty(Title)
    Title(strfind(Title,'_')) = '';
    %force again figure position. Sometimes pos changes and title is
    %missplaced.
    set(hFig,'Position',figPos); pause(0.02); %the pause seems to be required on some systems to give time to Java to update 
    text(firstAxe(1),0,1,Title,'Color',colorSet.fonts,'verticalAlignment','bottom',...
        'HorizontalAlignment','left','FontSize',fontSize(1),'FontUnits','points',...
        'Units','normalized','FontWeight','Bold');
end

% print figure if an output name is specified
if ~isempty(output)
    %add output name to figure title
    set(hFig,'name',output)
    %remove any blank space in the outputname
    output(strfind(output,' ')) = '_';
    
    % decompose output name just in case there is a path
    [fp,nm,ext] = fileparts(output);
    if ~isempty(fp);fp = [fp,filesep];end
        
    %preappend function name
    output = [fp,funcName,'_',nm,ext];
    
    % --------------Set the size of the printed image----------------------
    %determin the aspect ratio
    aspectRatio = figPos(3)/figPos(4);
    if isempty(printSize)
        %set default value
        fixSize = 17;
        %determin the longest dimension
        if aspectRatio >= 1
            printSize = 'w';
        else
            printSize = 'h';
        end
    else
        fixSize = str2double(printSize(2:end))/10; %converto to cm 
    end
    switch printSize(1)
        case 'h'; PaperPosition = [0 0 fixSize*aspectRatio fixSize];
        case 'w'; PaperPosition = [0 0 fixSize fixSize/aspectRatio];
    end
    if ~ischar(resolution); resolution=num2str(resolution); end
    set(hFig, 'InvertHardcopy', 'off','PaperPositionMode','auto',...
        'PaperUnits','centimeters','PaperPosition',PaperPosition);
    fprintf('%s - printing image:\n',funcName);
    fprintf('- filename: \t%s\n',[output,'.png']);
    fprintf('- resolution: \t%s dpi\n',resolution);
    printSizePixel = round(str2double(resolution)*PaperPosition/2.54);
    fprintf('- size: \t%.0f x %.0f pixels\n',printSizePixel(3),printSizePixel(4));
    fprintf('- size: \t%.1f x %.1f cm\n',PaperPosition(3),PaperPosition(4));
    % ---------------------------------------------------------------------

    %force again the position and finally print image
    set(hFig,'Position',figPos); pause(0.02);
    print([output,'.png'],'-dpng',['-r',resolution])

    if ~noMat
        % Store parameters in a structure  
        opt.nLayers = nLayers;
        if exist('imgPaths','var')
            paths = GetFullPath(imgPaths);
            for l = 1:nLayers; opt.(['img',num2str(l)]) = paths{l}; end
        end
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
        opt.appearance.fontSize = fontSize;
        opt.appearance.colorBarLocation0 = cbLocation;
        opt.appearance.showCoordinates = showCoordinates;
        opt.appearance.coordinateLocation = coordinateLocation;
        opt.resolution = resolution;
        opt.sizePixels = [printSizePixel(3),printSizePixel(4)];
        opt.sizeCm = [PaperPosition(3),PaperPosition(4)];

        save([output,'.mat'],'opt');
    end
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
    % 1) + + -> threshold on min, saturate on max
    % 2) - - -> threshold on max, saturate on min
    % 3) - + -> threshold on min, saturate on max (arbitrary choice. We might deal with the
    %           opposite case in the future)
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