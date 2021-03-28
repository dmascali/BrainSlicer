function print_maps(img,Title,varargin)

% underlay = '/storage/daniele/CBF/voxelwise/MNI152_T1_2mm.nii';
% overlay = '/storage/daniele/CBF/voxelwise/ALL_CBF_TAN_GM/spmT_0001.nii';

if nargin == 0 %test mode
    load data_test;
    underlay = bg.img;
    overlay = ol.img;
    img = {underlay,overlay};
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
layerStrings = cellstr(num2str([1:nLayers]')); %this is used to construct default parameters
num2cell(1:nLayers);
colorbarDefaultList = {'gray','hot','cool'};

% variable that needs to be put in varargin in the future:
fontsize.Title = 12;

%--------------VARARGIN----------------------------------------------------
params  =  {'labels','limits','minClusterSize','colormaps','alpha','cbLocation', 'margins', 'mount', 'view','resolution'};
defParms = {cellfun(@(x) ['img',x],layerStrings,'UniformOutput',0)', ...
            cellfun(@(x) [min(x(:)) max(x(:))],img,'UniformOutput',0),... % use min and max in each image as limits
            cell(1,nLayers),...
            colorbarDefaultList(1:nLayers),...
            num2cell([0 ones(1,nLayers-1)]),...
            'best', [0 0 0 0],   [6 2],   'ax', '300'};
legalValues{1} = [];
legalValues{2} = [];
legalValues{3} = [];
legalValues{4} = [];
legalValues{5} = [];
legalValues{6} = {'best','south','east'};
legalValues{7} = [];
legalValues{8} = [];
legalValues{9} = {'ax','sag','cor'};
legalValues{10} =[];
[labels,limits,minClusterSize,colormaps,alpha,cbLocation,margins,mount,view,resolution] = ParseVarargin(params,defParms,legalValues,varargin,1);
%--------------------------------------------------------------------------

%TO:
% add colormaps from FSL:
% they should be in:
% /usr/local/fsl/fslpython/envs/fslpython/lib/python3.7/site-packages/fsleyes/assets/colourmaps



%check Matlab version, stop if version is older than:
matlabVersion = version;
matlabVersion = str2num(matlabVersion(1:3));




for l = 1:nLayers
    if ischar(img{l})  %in case data is a path to a nifti file
        img{l} = spm_read_vols(spm_vol(img{l}));
%         %threshold images
%         if not(isnan(limits(l,1)))
%             img{1}(abs(img{1}) < limits(l,1)) = 0;
%         end
        
    end
end

% % "backroung suppression" on first layer
% if background_suppression
%     img{1}(img{1} < 1000) = 0;
% end

% %threshold overlay
% img1(abs(img1) < over_limits(1)) = 0;

%TODO add check for consistency between images

%get info specific to the type of view
s =  size(img{1});
switch view
    case {'ax'}
        n_slices = s(3);
        for l = 1:nLayers
            img{l} = flipdim(img{l},2);
        end
        slice_dim = [s(1) s(2)];
    case {'sag'} %this might be flipped
        n_slices = s(1);
        slice_dim = [s(2) s(3)];
    case {'cor'} %this might be flipped
        slice_dim = [s(1) s(3)];
        n_slices = s(3);
end
%todo: skip a percentage of bottom and top slices
planes = fix(linspace(15,n_slices-20,mount(2)*mount(1)));

%threshold images
img = threshold_images(img,limits,minClusterSize);

%determin the number of colorbars based on variable labels. Layers with
%empty labels will not have colorbars
colorbarIndex = find(cellfun(@(x) not(isempty(x)),labels));
colorbarN = length(colorbarIndex);

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

[pos,cbConfig,figPos] = figure_grid([mount(2), mount(1)],slice_dim,margins,[0 0],colorbarN,cbLocation,titleInPixels); %left right top bottom %x,y



%tiledlayout(mount(2),mount(1), 'Padding', 'none', 'TileSpacing', 'compact');
count = 0;
for row = 1:mount(2)
    for col = 1:mount(1)
        count = count +1;
        h_ax = plot_slice(pos{row,col},img,view,planes(count),limits,colormaps,alpha);
        if count == 1
            firstAxe = h_ax;
        end
    end
end


for l = 1:colorbarN
    cb = colorbar(h_ax(colorbarIndex(l)),'Location',cbConfig.location,'Position',cbConfig.colorbarPos{l},'Color','w');
    cb.Label.String = labels{colorbarIndex(l)};
    cb.Label.FontSize = 10;
    cb.Label.Color = 'w';
end

text(firstAxe(1),0,1,Title,'Color','w','verticalAlignment','bottom','HorizontalAlignment','left','FontSize',fontsize.Title,'FontUnits','points','Units','normalized','FontWeight','Bold');

Title(strfind(Title,' ')) = '_';

set(gcf, 'InvertHardcopy', 'off','PaperPositionMode','auto');
%try to force again position. It works!
set(gcf,'Position',figPos);
print(Title,'-dpng',['-r',resolution])

% pause(1)
% close all

return
end


function h_ax = plot_slice(pos,img,plane,coordinates,limits,colormaps,alphas)
nLayers = length(img);
ax = cell(nLayers,1);
h_ax = [];
%cycle on layers
for l = 1:nLayers
    ax{l} = axes('Position',pos);
    if l > 1 %transparancy (exlude first layer)
        %pixel to be transpart either 0 or Nans
        alphadata = alphas{l}.*img{l};
        alphadata(img{l} == 0) = 0;
        alphadata(isnan(alphadata)) = 0;
    else
        alphadata = [];
    end
    draw_layer(plane,img{l},coordinates,limits{l},alphadata)
    colormap(ax{l},colormaps{l});
    h_ax = [h_ax,ax{l}];
end
linkaxes(h_ax);
return
end

function img = threshold_images(img,limits,minClusterSize)
nLayers = length(img);
%cycle on layers
for l = 1:nLayers
    low = limits{l}(1);
    up  = limits{l}(2);
    if low < up
        img{l}(img{l} < low) = 0;
    else
        img{l}(img{l} > up) = 0;
    end
    if not(isempty(minClusterSize{l})) | (minClusterSize{l} > 1)
        %binarize img
        a = img{l}; a(not(a==0)) = 1;
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

function [xyz] = mni2xyz(mni,vs)

if vs == 2
    origin = [45 63 36]; % [X Y Z]
elseif vs == 1
    origin = [91 126 72]; % [X Y Z]
end


xyz(1)=origin(1) + round(mni(1)/vs) +1;      %was origin(1) - mni(1)/vs
xyz(2)=origin(2) + round(mni(2)/vs) +1;
xyz(3)=origin(3) + round(mni(3)/vs) +1;

return
end

function [mni] = xyz2mni(xyz,vs)

if vs == 2
    origin = [45 63 36]; % [X Y Z]
elseif vs == 1
    origin = [91 126 72]; % [X Y Z]
end

mni = vs*(xyz - origin -1);


return
end