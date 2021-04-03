function extract_colormaps_fsl(varargin)


% %--------------VARARGIN----------------------------------------------------
% params  =  {'extract'};
% defParms = {cellfun(@(x) ['img',x],layerStrings,'UniformOutput',0)', ...
%             cellfun(@(x) [min(x(:)) max(x(:))],img,'UniformOutput',0),... % use min and max in each image as limits
%             cell(1,nLayers),...
%             colorbarDefaultList(1:nLayers),...
%             num2cell(ones(1,nLayers)),...
%             'best', [0 0 0 0], [0 0],  [2 6],   'ax', '300',cell(1,nLayers), 'auto', [0.2 0.2], 'k'};
% legalValues{1} = [];
% legalValues{2} = [];
% legalValues{3} = [];
% legalValues{4} = [];
% legalValues{5} = [];
% legalValues{6} = {'best','south','east'};
% legalValues{7} = [];
% legalValues{8} = [];
% legalValues{9} = [];
% legalValues{10} = {'ax','sag','cor'};
% legalValues{11} =[];
% legalValues{12} =[];
% legalValues{13} =[];
% legalValues{14} =[];
% legalValues{15} = {'k','black','w','white'};
% [labels,limits,minClusterSize,colormaps,alpha,cbLocation,margins,innerMargins,mount,view,resolution,zScore,slices,skip,colorMode] = ParseVarargin(params,defParms,legalValues,varargin,1);
% %--------------------------------------------------------------------------


%------- load FSL colormaps (include braincolours)-------------------------
location = '/usr/local/fsl/fslpython/envs/fslpython/lib/python3.7/site-packages/fsleyes/assets/colourmaps';
%load order file
order = importdata([location,'/order.txt']);
for l = 1:length(order)
    a = split(order{l}); % filename, colormap name
    %load colormap
    if isempty(strfind(a{1},'brain_colours'))
        map = load([location,'/',a{1},'.cmap']);
        mapName = ['fsl:',a{1}];
        source = 'FSL';
    else
        map= load([location,'/brain_colours/',a{1}(15:end),'.cmap']);
        mapName = ['bc:',a{1}(15:end)];
        source = 'BrainColours';
    end
    cmap(l).name = mapName;
    cmap(l).source = source;
    cmap(l).map = map;
end
%--------------------------------------------------------------------------


%------- load builtin matlab color maps------------------------------------
% add also matlab colormap
% matlabColors=dir([matlabroot,'/help/matlab/ref/*colormap_*.png']);
% matlabColors={matlabColors.name};
% matlabColors=cellfun(@(S)strrep(S,'colormap_',''),matlabColors,'UniformOutput',false);
% matlabColors=cellfun(@(S)strrep(S,'_update17a',''),matlabColors,'UniformOutput',false);
% matlabColors=cellfun(@(S)strrep(S,'.png',''),matlabColors,'UniformOutput',false);
matlabColors = {'parula','turbo','hsv','hot','cool','spring','summer','autumn','winter','gray','bone','copper','pink','jet','lines','colorcube','prism','flag','white'};
count = 0;
for j = 1:length(matlabColors)
    try % in case the map were missing
        eval(['a = ',matlabColors{j},'(256);']);
        count = count +1;
        cmap(l+count).name = matlabColors{j};
        cmap(l+count).source = 'Matlab';
        cmap(l+count).map = a;
    end
end
%--------------------------------------------------------------------------

% total number of maps
nMaps = length(cmap);

% prepare figure and find axe locations
mount = [27,4];
[hFig,axesPos,~,figPos] = figure_grid(mount,[155,25],[0.01 0.20 0.01 0.01],[0.27 0.005],0,'none',0);


countMap = 1; %counter for maps
count = 0;  %counter for axes
for col = 1:mount(2)
    for row = 1:mount(1)
        % exit the loop if no more maps
        if countMap > nMaps
            break
        end
       
        %---print section title--------------------------------------------
        count = count +1;
        if count == 1 || (skip == 0 && ~(strcmp(cmap(countMap).source,cmap(countMap-1).source))) %any(count == StartSections)
            %just 
            ax = axes('Position',axesPos{row,col});
            text(0,0.5,cmap(countMap).source,'Unit','Normalized','verticalalignment','middle','interpreter','none','fontsize',12,'fontweight','bold');
            set(gca,'Visible','off');
            skip = 1;
            continue
        end
        skip = 0;
        %------------------------------------------------------------------
        
        ax = axes('Position',axesPos{row,col});
        x = 1:1:length(cmap(countMap).map);
        imagesc(x); colormap(ax,cmap(countMap).map);
        text(1.02,0.5,cmap(countMap).name,'Unit','Normalized','verticalalignment','middle','interpreter','none','fontsize',11,'fontweight','normal');
        set(gca,'Xtick',[]);set(gca,'Ytick',[]);
        countMap = countMap +1;
    end
end

set(hFig,'Name','Colormap List','NumberTitle','off')

set(gcf, 'InvertHardcopy', 'off','PaperPositionMode','auto');
%try to force again position. It works!
set(gcf,'Position',figPos);
print('colormapList.png','-dpng','-r300')

end