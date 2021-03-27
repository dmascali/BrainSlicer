function print_maps(underlay,overlay,under_limits,over_limits,view,mount,Title,CB_label)

% underlay = '/storage/daniele/CBF/voxelwise/MNI152_T1_2mm.nii';
% overlay = '/storage/daniele/CBF/voxelwise/ALL_CBF_TAN_GM/spmT_0001.nii';

if nargin == 0
    load data_test;
    underlay = bg.img;
    overlay = ol.img;
    img = {underlay,overlay};
    limits = {[1000 10000], [2 5]};
    colormaps = {'gray','hot'};
    alpha = {0 1};
    Title = 'Test p HC HC';
    fontsize.Title = 12; % in points (1 point is 1/72 inches)
    resolution = '500';  %pixels/inches
    labels = {[],'t-value'};
    cbLocation = 'best';
    margins = [0 0 0 0]; %left right top bottom

    mount = [3,5];
    view = 'cor';
    
    %optional
   % background_suppression = 1;
end

% %--------------VARARGIN----------------------------------------------------
% params  =  {'underlay','overlay','Ulimits','Olimits','Ucolor','Ocolor','mount','FullOrt', 'SigNormalise', 'concat', 'type', 'tcompcor','SaveMask', 'MakeBinary'};
% defParms = {        [],      [],       [],       [],          'off',     [],        1     'off',           'on',       [], 'mean',         [],     'off',         'off'};
% legalValues{1} = [];
% legalValues{2} = {'on','off'};
% legalValues{3} = {@(x) (isempty(x) || (~ischar(x) && sum(mod(x,1))==0 && sum((x < 0)) == 0)),'Only positive integers are allowed, which represent the derivative orders'};
% legalValues{4} = [];
% legalValues{5} = {'on','off'};
% legalValues{6} = [];
% legalValues{7} = [-1 0 1 2 3 4 5];
% legalValues{8} = {'on','off'};
% legalValues{9} ={'on','off'};
% legalValues{10} = {@(x) (isempty(x) || (~ischar(x) && sum(mod(x,1))==0 && sum((x < 0)) == 0)),'Only one positive integers are allowed, which represent the starting indexes of the runs.'};
% legalValues{11} = {'mean','median'};
% legalValues{12} = {@(x) (isempty(x) || (~ischar(x) && numel(x) == 1 && mod(x,1)==0 && x > 0)),'Only one positive integer is allowed. The value defines the number of voxels to be selected with the highest temporal standard deviation.'};
% legalValues{13} ={'on','off'};
% legalValues{14} ={'on','off'};
% [confounds,firstmean,deri,squares,DatNormalise,freq,PolOrder,FullOrt,SigNormalise,ConCat,MetricType,tCompCor,SaveMask,MakeBinary] = ParseVarargin(params,defParms,legalValues,varargin,1);
% %--------------------------------------------------------------------------

%check Matlab version, stop if version is older than:
matlabVersion = version;
matlabVersion = str2num(matlabVersion(1:3)); 

n_layers = length(img);


for l = 1:n_layers
    if ischar(img{1})  %in case data is a path to a nifti file
        img{1} = spm_read_vols(spm_vol(underlay));
        %threshold images
        if not(isnan(limits(l,1)))
           img{1}(abs(img{1}) < limits(l,1)) = 0; 
        end
        
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
        for l = 1:n_layers
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
img = threshold_images(img,limits);

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

pause(1)
close all

return
end


function h_ax = plot_slice(pos,img,plane,coordinates,limits,colormaps,alphas)
n_layers = length(img);
ax = cell(n_layers,1);
h_ax = [];
%cycle on layers
for l = 1:n_layers
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

function img = threshold_images(img,limits)
n_layers = length(img);
%cycle on layers
for l = 1:n_layers
    low = limits{l}(1);
    up  = limits{l}(2);
    if low < up
        img{l}(img{l} < low) = 0;
    else
        img{l}(img{l} > up) = 0;
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