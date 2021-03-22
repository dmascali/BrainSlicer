function print_maps(underlay,overlay,under_limits,over_limits,view,mount,name,CB_label)

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
    name = 'Test HC HC';
    labels = {'MNI','t-value'};

    mount = [4,5];
    view = 'ax';
    
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

%try to guess final figure size
s =  size(img{1});
switch view
    case {'ax'}
        slice_dim = [s(1) s(2)];
        n_slices = s(3);
    case {'sag'} %this might be flipped
        slice_dim = [s(2) s(3)];
        n_slices = s(1);
    case {'cor'} %this might be flipped
        slice_dim = [s(1) s(3)];
        n_slices = s(3);
end

%todo: skip a percentage of bottom and top slices

planes = fix(linspace(15,n_slices-20,mount(2)*mount(1)));
% marginTollerance = 2;
% width = (mount(1) + marginTollerance)*slice_dim(1);  
% hight = (mount(2) + marginTollerance)*slice_dim(2);  
% figure('Position',[0 0 width hight]);

%threshold images
img = threshold_images(img,limits);

%determin the number of colorbars based on variable labels. Layers with
%empty labels will not have colorbars
colorbarIndex = cellfun(@isempty,labels);
colorbarN = sum(not(colorbarIndex));

[pos,CBpos,figPos] = figure_grid([mount(2), mount(1)],slice_dim,[1 9 11 1],[0 0],colorbarN); %left right top bottom %x,y



%tiledlayout(mount(2),mount(1), 'Padding', 'none', 'TileSpacing', 'compact'); 
count = 0;
for row = 1:mount(2)
    for col = 1:mount(1)
        count = count +1;
        h_ax = plot_slice(pos{row,col},img,view,planes(count),limits,colormaps,alpha);
    end
end


for l = 1:colorbarN
    cb = colorbar(h_ax(l),'Position',CBpos{l},'Color','w');
    cb.Label.String = labels{l};
    cb.Label.FontSize = 10;
    cb.Label.Color = 'w';
end

cb1.Label.String = CB_label;
cb1.Label.FontSize = 10;
cb1.Label.Color = 'w';

cb2.Label.String = CB_label;
cb2.Label.FontSize = 10;
cb2.Label.Color = 'w';

h = annotation('textbox', [0 0.95 0 0], 'String', name, 'FitBoxToText', true,'Color','w','edgecolor','none','verticalAlignment','middle','FontSize',17,'Fontweight','bold');

name(strfind(name,' ')) = '_';

set(gcf, 'InvertHardcopy', 'off','PaperPositionMode','auto');
%try to force again position. It works!
set(gcf,'Position',figPos);
print(name,'-dpng','-r500')

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
        if isempty(alphadata)
            imagesc(flipdim(squeeze(img(:,:,coordinates)),2)',limits);
        else
            imagesc(flipdim(squeeze(img(:,:,coordinates)),2)','AlphaData',flipdim(squeeze(alphadata(:,:,coordinates)),2)');
            ax = gca;
            ax.CLim = limits;
        end
        xlim([1 size(img,1)]);
        ylim([1 size(img,2)]);
    case {'sag'}
        imagesc(flipdim(squeeze(img(coordinates,:,:))',1),limits);
    case {'cor'}
        imagesc(flipdim(squeeze(img(:,coordinates,:))',1),limits);
end
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