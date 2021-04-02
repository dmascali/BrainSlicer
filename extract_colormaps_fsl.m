function extract_colormaps_fsl

location = '/usr/local/fsl/fslpython/envs/fslpython/lib/python3.7/site-packages/fsleyes/assets/colourmaps';

%load order file
order = importdata([location,'/order.txt']);
nMaps = length(order);
maps = cell(nMaps,1);
mapNames = cell(nMaps,1);
for l = 1:nMaps
   
    a = split(order{l}); % filename, colormap name
    
    %load colormap
    if isempty(strfind(a{1},'brain_colours'))
        maps{l} = load([location,'/',a{1},'.cmap']);
        mapNames{l} = ['fsl:',a{1}];
    else
        maps{l} = load([location,'/brain_colours/',a{1}(15:end),'.cmap']);
        mapNames{l} = ['bc:',a{1}(15:end)];
    end
    
    
end

mount = [21,4];

[hFig,axesPos,cbConfig,figPos] = figure_grid(mount,[155,25],[0.01 0.20 0.01 0.01],[0.27 0.015],0,'none',0);

count = 0;
for col = 1:mount(2)
    for row = 1:mount(1)
        count = count +1;
        if count > nMaps
            break
        end
        ax = axes('Position',axesPos{row,col});
        x = 1:1:length(maps{count});
        imagesc(x); colormap(ax,maps{count});
        text(1.02,0.5,mapNames{count},'Unit','Normalized','verticalalignment','middle','interpreter','none','fontsize',11,'fontweight','normal');
        %set(gca,'Visible','off');
        set(gca,'Xtick',[]);
        set(gca,'Ytick',[]);
    end
end

set(gcf, 'InvertHardcopy', 'off','PaperPositionMode','auto');
%try to force again position. It works!
set(gcf,'Position',figPos);
print(['colormapList.png'],'-dpng',['-r300'])

end