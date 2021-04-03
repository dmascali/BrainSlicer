function map = colormaps(arg,varargin)
% help to be defined
try 
    [p,~,~] = fileparts(which(mfilename));
    load([p,'/cmaps.mat']);
catch 
    error('Could not find "cmaps.mat" file.');
end

%--------------VARARGIN----------------------------------------------------
params  =  {'print'};
defParms = {     0,};
legalValues{1} = [0 1];
[printMaps] = ParseVarargin(params,defParms,legalValues,varargin,1);
%--------------------------------------------------------------------------

if nargin == 0 || printMaps% just plot colormaps and return help
    % print help 
    help(mfilename);
    
    % prepare figure and find axe locations
    mount = [27,4];
    [hFig,axesPos,~,figPos] = figure_grid(mount,[155,25],[0.01 0.24 0.01 0.01],[0.32 0.005],0,'none',0);

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
            text(1.02,0.5,[cmap(countMap).name,' (',num2str(countMap),')'],'Unit','Normalized','verticalalignment','middle','interpreter','none','fontsize',11,'fontweight','normal');
            set(gca,'Xtick',[]);set(gca,'Ytick',[]);
            countMap = countMap +1;
        end
    end    
    set(hFig,'Name','Colormap List','NumberTitle','off');
    set(gcf,'Position',figPos);
    if printMaps
        set(gcf, 'InvertHardcopy', 'off','PaperPositionMode','auto');
        print('colormapList.png','-dpng','-r100');
    end
    return
end

if ischar(arg) || isstring(arg)
    indx = find(cellfun(@(s) contains(arg, s), {cmap.name}));
    if isempty(indx)
        error('Could not find ''%s'' among the available colormaps.',arg);
    end
    map = cmap(indx).map;
    
elseif isnumeric(arg) && numel(arg) == 1 %select colormap based on index
    if arg > nMaps || arg <= 0
        error('Valid colormap indices range from 1 to %d.',nMaps);
    end
    map = cmap(arg).map;
else 
    map = arg;
end

return
end