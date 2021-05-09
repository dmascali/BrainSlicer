function map = colormaps(arg,varargin)
%COLORMAPS View or get Slicer's colormaps.
%  COLORMAPS() shows the available colormaps, which include FSL colormaps
%   (including the isoluminant Brain Colours maps) and the built-in Matlab's 
%   colormaps. Each map is associated with a unique name and integer.  
%  COLORMAPS(ARG) returns the selected colormap in matrix form (N-by-3)
%   that can be fed to matlab's colormap function to modify the axes/figure
%   map. ARG can be either a char/string or a positive integer, so that the 
%   maps can be selected either by name or by number.
%
%   See also SLICER, SLICERCOLLAGE

%__________________________________________________________________________
% Daniele Mascali
% ITAB, UDA, Chieti - 2021
% danielemascali@gmail.com

try 
    [p,~,~] = fileparts(which(mfilename));
    load([p,'/subfunc/cmaps.mat']);
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
    
    if exist('colormapList.png','file') && ~printMaps
        figure('MenuBar', 'None','Name','Slicer - Colormap List','NumberTitle','off');
        imshow('colormapList.png','border','tight');
        return
    end
    
    % prepare figure and find axe locations
    mount = [27,4];
    [hFig,axesPos,~,figPos] = figureGrid(mount,[155,25],[0.01 0.24 0.01 0.01],[0.32 0.005],0,'none',0,1);

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
    set(hFig,'Name','Slicer - Colormap List','NumberTitle','off');
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