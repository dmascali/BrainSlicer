function print_maps(img,Title,varargin)
%
%
% Properties:
%   
%   APPEARANCE:
%     limits
%     minClusterSize
%     labels
%   Montage:
%     view
%     mount
%     slices
%     skip
%   Appearance:
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

% underlay = '/storage/daniele/CBF/voxelwise/MNI152_T1_2mm.nii';
% overlay = '/storage/daniele/CBF/voxelwise/ALL_CBF_TAN_GM/spmT_0001.nii';

if nargin == 0 %test mode
    load data_test;
    underlay = bg.img;
    overlay = ol.img;
    img = {underlay};
    img = {'spmT_0001.nii'};
%    limits = {[1000 10000], [3.16 5]};
% %     minClusterSize = {[], 200};
% %     colormaps = {'gray','hot'};
%     alpha = {0 1};
     Title = 'Test p HC HC';
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
        hdr = spm_vol(img{l});
        img{l} = spm_read_vols(hdr);       
    end
end
layerStrings = cellstr(num2str([1:nLayers]')); %this is used to construct default parameters
num2cell(1:nLayers);
colorbarDefaultList = {1,2,3};

% variable that needs to be put in varargin in the future:
fontsize.Title = 12;

%--------------VARARGIN----------------------------------------------------
params  =  {'labels','limits','minClusterSize','colormaps','alpha','cbLocation', 'margins', 'innerMargins','mount', 'view','resolution','zscore','slices','skip','colormode','showCoordinates','coordinateLocation'};
defParms = {cellfun(@(x) ['img',x],layerStrings,'UniformOutput',0)', ...
            cellfun(@(x) [min(x(:)) max(x(:))],img,'UniformOutput',0),... % use min and max in each image as limits
            cell(1,nLayers),...
            colorbarDefaultList(1:nLayers),...
            num2cell(ones(1,nLayers)),...
            'best', [0 0 0 0], [0 0],  [2 6],   'ax', '300',cell(1,nLayers), 'auto', [0.2 0.2], 'k',  1, 'sw'};
legalValues{1} = [];
legalValues{2} = [];
legalValues{3} = [];
legalValues{4} = [];
legalValues{5} = [];
legalValues{6} = {'best','south','east'};
legalValues{7} = [];
legalValues{8} = [];
legalValues{9} = [];
legalValues{10} = {'ax','sag','cor'};
legalValues{11} =[];
legalValues{12} =[];
legalValues{13} =[];
legalValues{14} =[];
legalValues{15} = {'k','black','w','white'};
legalValues{16} = [0 1];
legalValues{17} = {'north','south','east','west','n','s','e','w','northeast','northwest','southeast','southwest','ne','nw','se','sw'};
[labels,limits,minClusterSize,colormaps,alpha,cbLocation,margins,innerMargins,mount,view,resolution,zScore,slices,skip,colorMode,showCoordinates,coordinateLocation] = ParseVarargin(params,defParms,legalValues,varargin,1);
%--------------------------------------------------------------------------

%TO:
% add colormaps from FSL:
% they should be in:
% /usr/local/fsl/fslpython/envs/fslpython/lib/python3.7/site-packages/fsleyes/assets/colourmaps
%TODO add check for consistency between images



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
    if not(isempty(skip))
        if skip(1) < 1; skip(1) = skip(1)*n_slices; end
        if skip(2) < 1; skip(2) = skip(2)*n_slices; end
    else
        skip = [0 0];
    end
    planes = fix(linspace( 1+(skip(1)) , n_slices-(skip(2)) ,mount(2)*mount(1)));
else
    planes = slices;
end
%planes = fix(linspace(1,n_slices,mount(2)*mount(1)));

%zscore images if required
img = zscore_images(img,zScore,nLayers);

%threshold images
img = threshold_images(img,limits,minClusterSize,nLayers);

%determin the number of colorbars based on variable labels. Layers with
%empty labels will not have colorbars
colorbarIndex = find(cellfun(@(x) not(isempty(x)),labels));
colorbarN = length(colorbarIndex);
if colorbarN == 0
    cbLocation = 'none';
end

%Defines how many pixels the title occupies
titleInInches = (fontsize.Title+1) *1/72; %add one points to increase top space and convert points to inches
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

[hFig,pos,cbConfig,figPos] = figure_grid(mount,sliceDim,margins,innerMargins,colorbarN,cbLocation,titleInPixels); %left right top bottom %x,y

set(hFig,'color',colorSet.background);

if showCoordinates
    planeCord = plane_coordinates(coordinateLocation);
    if exist('hdr','var')
        coordinates = xyz2mm(planes,hdr(1).mat,view);
        disp('Coordinates are in mm.');
    else
        coordinates = planes;
        disp('Coordinates are in voxels.');
    end
end

count = 0;
for row = 1:mount(1)
    for col = 1:mount(2)
        count = count +1;
        h_ax = plot_slice(pos{row,col},img,view,planes(count),limits,colormaps,alpha);
        if count == 1
            firstAxe = h_ax;
        end
        if showCoordinates
            text(planeCord{1},planeCord{2},num2str(coordinates(count)),'Color',colorSet.fonts,'verticalAlignment',planeCord{4},'HorizontalAlignment',planeCord{3},'FontSize',6,'FontUnits','points','Units','normalized','FontWeight','normal');
        end
    end
end


for l = 1:colorbarN
    cb = colorbar(h_ax(colorbarIndex(l)),'Location',cbConfig.location,'Position',cbConfig.colorbarPos{l},'Color','w');
    cb.Label.String = labels{colorbarIndex(l)};
    cb.Label.FontSize = 10;
    cb.Label.Color = colorSet.fonts;
    cb.Color = colorSet.fonts;
end

%remove any undersocre present in the title
Title(strfind(Title,'_')) = '';
text(firstAxe(1),0,1,Title,'Color',colorSet.fonts,'verticalAlignment','bottom','HorizontalAlignment','left','FontSize',fontsize.Title,'FontUnits','points','Units','normalized','FontWeight','Bold');

%remove any blank space in the outputname
Title(strfind(Title,' ')) = '_';

set(gcf, 'InvertHardcopy', 'off','PaperPositionMode','auto');
%try to force again position. It works!
set(gcf,'Position',figPos);
print([Title,'.png'],'-dpng',['-r',resolution])

% Store parameters in a structure
%opt.images = 
opt.nLayers = nLayers;
opt.limits = limits;
opt.minClusterSize = minClusterSize;
opt.colormaps = colormaps;
opt.labels = labels;
opt.opacityLevels = alpha;
opt.montage.view = view;
opt.montage.mount = mount;
opt.montage.slices = slices;
opt.montage.skip = skip;  %it's not anymore in %, now is in slices.
opt.appearance.colorMode = colorMode;
opt.appearance.margins = margins;
opt.appearance.innerMargins = innerMargins;
opt.appearance.colorBarLocation0 = cbLocation;
opt.appearance.showCoordinates = showCoordinates;
opt.appearance.coordinateLocation = coordinateLocation;
opt.appearance.resolution = resolution;

opt

% pause(1)
% close all

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
    colormap(ax{l},colormaps(colorMaps{l}));
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
    if sum(limits{l}>=0) >= 2 %case 1 
        img{l}(img{l} <= low) = NaN;
    elseif sum(limits{l}<=0) == 2 %case 2
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
        img{l}(indx) = 0;
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