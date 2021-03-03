function print_maps(underlay,varargin)

% underlay = '/storage/daniele/CBF/voxelwise/MNI152_T1_2mm.nii';
% overlay = '/storage/daniele/CBF/voxelwise/ALL_CBF_TAN_GM/spmT_0001.nii';
load data_test;
underlay = bg.img;
overlay = ol.img;

name = 'Test HC > HC';
CB_label = 't-value';

%--------------VARARGIN----------------------------------------------------
params  =  {'underlay','overlay','Ulimits','Olimits','Ucolor','Ocolor','mount','FullOrt', 'SigNormalise', 'concat', 'type', 'tcompcor','SaveMask', 'MakeBinary'};
defParms = {        [],      [],       [],       [],          'off',     [],        1     'off',           'on',       [], 'mean',         [],     'off',         'off'};
legalValues{1} = [];
legalValues{2} = {'on','off'};
legalValues{3} = {@(x) (isempty(x) || (~ischar(x) && sum(mod(x,1))==0 && sum((x < 0)) == 0)),'Only positive integers are allowed, which represent the derivative orders'};
legalValues{4} = [];
legalValues{5} = {'on','off'};
legalValues{6} = [];
legalValues{7} = [-1 0 1 2 3 4 5];
legalValues{8} = {'on','off'};
legalValues{9} ={'on','off'};
legalValues{10} = {@(x) (isempty(x) || (~ischar(x) && sum(mod(x,1))==0 && sum((x < 0)) == 0)),'Only one positive integers are allowed, which represent the starting indexes of the runs.'};
legalValues{11} = {'mean','median'};
legalValues{12} = {@(x) (isempty(x) || (~ischar(x) && numel(x) == 1 && mod(x,1)==0 && x > 0)),'Only one positive integer is allowed. The value defines the number of voxels to be selected with the highest temporal standard deviation.'};
legalValues{13} ={'on','off'};
legalValues{14} ={'on','off'};
[confounds,firstmean,deri,squares,DatNormalise,freq,PolOrder,FullOrt,SigNormalise,ConCat,MetricType,tCompCor,SaveMask,MakeBinary] = ParseVarargin(params,defParms,legalValues,varargin,1);
%--------------------------------------------------------------------------

plane = [22, 35, 43 55 67];
under_limits = [0 10000];
over_limits = [4 7];
view = 'ax';

mount = [5,3,10,1];

if ischar(underlay)  %in case data is a path to a nifti file
    img0 = spm_read_vols(spm_vol(underlay));
else
    img0 = underlay;
end
if ischar(overlay) 
    img1 = spm_read_vols(spm_vol(overlay));
else
    img1 = overlay;
end

img0(img0 < 1000) = 0;

%threshold overlay
img1(abs(img1) < over_limits(1)) = 0; 

%try to guess final figure size
s =  size(img0);
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

planes = fix(linspace(20,n_slices-20,mount(2)*mount(1)));
% marginTollerance = 2;
% width = (mount(1) + marginTollerance)*slice_dim(1);  
% hight = (mount(2) + marginTollerance)*slice_dim(2);  
% figure('Position',[0 0 width hight]);

[pos,CBpos] = figure_grid([mount(2), mount(1)],slice_dim,[0 13 12 1],[0 0]); %left right top bottom %x,y


%tiledlayout(mount(2),mount(1), 'Padding', 'none', 'TileSpacing', 'compact'); 
count = 0;
for row = 1:mount(2)
    for col = 1:mount(1)
        count = count +1;
        h_ax = plot_slice(pos{row,col},img0,img1,view,planes(count),under_limits,over_limits,'gray','hot',1);
    end
end

cb1 = colorbar(h_ax(2),'Position',CBpos.two_bars{2},'Color','w');
cb2 = colorbar(h_ax(3),'Position',CBpos.two_bars{1},'Color','w');

cb1.Label.String = CB_label;
cb1.Label.FontSize = 10;
cb1.Label.Color = 'w';

cb2.Label.String = CB_label;
cb2.Label.FontSize = 10;
cb2.Label.Color = 'w';

h = annotation('textbox', [0 0.95 0 0], 'String', name, 'FitBoxToText', true,'Color','w','edgecolor','none','verticalAlignment','middle','FontSize',17,'Fontweight','bold');


set(gcf, 'InvertHardcopy', 'off')
print('test.png','-dpng','-r500')

return
end


function [h_ax] = plot_slice(pos,img0,img1,plane,coordinates,img0_limits,img1_limits,img0_colormap,img1_colormap,alpha)

ax0 = axes('Position',pos);
draw_layer(plane,img0,coordinates,img0_limits)


%overlay
img1_pos = img1;
img1_neg = img1;
img1_pos(img1 < 0) = 0;
img1_neg(img1 > 0) = 0;

%find pixel to be transpart (either 0 or Nans)
alphadata = alpha.*img1_pos;
alphadata(img1_pos == 0) = 0;
alphadata(isnan(alphadata)) = 0;

ax1 = axes('Position',pos,'Visible','off');
draw_layer(plane,img1_pos,coordinates,img1_limits,alphadata)

%find pixel to be transpart (either 0 or Nans)
alphadata = -1*alpha.*img1_neg;
alphadata(img1_neg == 0) = 0;
alphadata(isnan(alphadata)) = 0;

ax2 = axes('Position',pos,'Visible','off');
draw_layer(plane,img1_neg,coordinates,-1*flip(img1_limits),alphadata)




linkaxes([ax0,ax1,ax2])
% ax1.Visible = 'off';
% ax1.XTick = [];
% ax1.YTick = [];


colormap(ax0,img0_colormap);
colormap(ax1,img1_colormap);
colormap(ax2,'winter');

h_ax = [ax0; ax1; ax2];

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