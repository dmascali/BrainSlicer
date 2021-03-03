function print_maps(underlay,varargin)

underlay = '/storage/daniele/CBF/voxelwise/MNI152_T1_2mm.nii';
overlay = '/storage/daniele/CBF/voxelwise/ALL_CBF_TAN_GM/spmT_0001.nii';
name = 'Test HC > HC';
CB_label = 'T-value';

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
over_limits = [2 5];
view = 'ax';

mount = [7,2,10,1];

img0 = spm_read_vols(spm_vol(underlay));
img1 = spm_read_vols(spm_vol(overlay));

img0(img0 < 1000) = 0;

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

[pos,CBpos] = figure_grid([mount(2), mount(1)],slice_dim,[0 15 15 1],[1 1]); %left right top bottom %x,y


%tiledlayout(mount(2),mount(1), 'Padding', 'none', 'TileSpacing', 'compact'); 
count = 0;
for row = 1:mount(2)
    for col = 1:mount(1)
        count = count +1;
        plot_slice(pos{row,col},img0,img1,view,planes(count),under_limits,over_limits,'gray','hot',1);
    end
end

cb = colorbar('Position',CBpos,'Color','w');
cb.Label.String = CB_label;
cb.Label.FontSize = 10;
cb.Label.Color = 'w';

h = annotation('textbox', [0 0.95 0 0], 'String', name, 'FitBoxToText', true,'Color','w','edgecolor','none','verticalAlignment','middle','FontSize',17,'Fontweight','bold');


set(gcf, 'InvertHardcopy', 'off')
print('test.png','-dpng','-r500')

return
end


function plot_slice(pos,img0,img1,plane,cordinate,img0_limits,img1_limits,img0_colormap,img1_colormap,alpha)

ax0 = axes('Position',pos);
switch plane
    case {'ax'}
        imagesc(squeeze(img0(:,:,cordinate))',img0_limits);
        xlim([1 size(img0,1)]);
        ylim([1 size(img0,2)]);
    case {'sag'}
        imagesc(flipdim(squeeze(img0(cordinate,:,:))',1),img0_limits);
    case {'cor'}
        imagesc(flipdim(squeeze(img0(:,cordinate,:))',1),img0_limits);
end


set(gca,'Visible','off');

%find pixel to be transpart (either 0 or Nans)
alphadata = alpha.*img1;
alphadata(img1 == 0) = 0;
alphadata(isnan(alphadata)) = 0;


ax1 = axes('Position',pos,'Visible','off');
switch plane
    case {'ax'}
        imagesc(squeeze(img1(:,:,cordinate))','AlphaData',alphadata(:,:,cordinate)');
        ax1.CLim = img1_limits;
        xlim([1 size(img0,1)]);
        ylim([1 size(img0,2)]);
    case {'sag'}
        imagesc(flipdim(squeeze(img1(cordinate,:,:))',1),img1_limits);
        ax1.CLim = img1_limits;
    case {'cor'}
        imagesc(flipdim(squeeze(img1(:,cordinate,:))',1),img1_limits);
        ax1.CLim = img1_limits;
end

linkaxes([ax0,ax1])
ax1.Visible = 'off';
ax1.XTick = [];
ax1.YTick = [];


colormap(ax0,img0_colormap)
colormap(ax1,img1_colormap)

set(gca,'Xtick',[]);
set(gca,'Ytick',[]);
return
end