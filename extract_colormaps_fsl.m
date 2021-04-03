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
indxBC = cellfun(@(x) strcmpi(x(1:2),'bc'),mapNames,'UniformOutput',0);
StartSections = [1,find([indxBC{:}],1)]; %start of FSL, BC

% add also matlab colormap
matlabColors=dir([matlabroot,'/help/matlab/ref/*colormap_*.png']);
matlabColors={matlabColors.name};
matlabColors=cellfun(@(S)strrep(S,'colormap_',''),matlabColors,'UniformOutput',false);
matlabColors=cellfun(@(S)strrep(S,'_update17a',''),matlabColors,'UniformOutput',false);
matlabColors=cellfun(@(S)strrep(S,'.png',''),matlabColors,'UniformOutput',false);

mapNames = [mapNames;matlabColors'];
nMaps = length(mapNames);
maps = [maps;cell(length(matlabColors),1)];

StartSections = [StartSections,length(indxBC)+1];
SectionNames = {'FSL','BrainColours','Matlab'};

mount = [27,4];

[hFig,axesPos,cbConfig,figPos] = figure_grid(mount,[155,25],[0.01 0.20 0.01 0.01],[0.27 0.005],0,'none',0);

countMap = 0;
count = 0;
for col = 1:mount(2)
    for row = 1:mount(1)
        
        count = count +1;
        if any(count == StartSections)
            %just print section title
            ax = axes('Position',axesPos{row,col});
            text(0,0.5,SectionNames{1},'Unit','Normalized','verticalalignment','middle','interpreter','none','fontsize',12,'fontweight','bold');
            SectionNames = {SectionNames{2:end}};
            StartSections = StartSections(2:end);
            StartSections = StartSections +1;
            set(gca,'Visible','off');
            continue
            
        end
        countMap = countMap +1;
        if countMap > nMaps
            break
        end
        ax = axes('Position',axesPos{row,col});
        if isempty(maps{countMap}) %matlab case
            x = 1:1:255;
            imagesc(x); colormap(ax,mapNames{countMap}); 
        else
            x = 1:1:length(maps{countMap});
            imagesc(x); colormap(ax,maps{countMap});
        end
        text(1.02,0.5,mapNames{countMap},'Unit','Normalized','verticalalignment','middle','interpreter','none','fontsize',11,'fontweight','normal');
        set(gca,'Xtick',[]);set(gca,'Ytick',[]);
    end
end

set(hFig,'Name','Colormap List','NumberTitle','off')

set(gcf, 'InvertHardcopy', 'off','PaperPositionMode','auto');
%try to force again position. It works!
set(gcf,'Position',figPos);
print(['colormapList.png'],'-dpng',['-r300'])

end