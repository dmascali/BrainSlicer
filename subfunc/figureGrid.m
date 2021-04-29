function [hFig,axesPos,cbConfig,figPos] = figureGrid(mount,sliceDim,margins,innerMargins,colorbarN,colorbarLocation,titleHighInPixel,visible)

s = sliceDim;

% margins = [0 0 0 0]; %left right top bottom
% InnerMargins = [0 0]; %x y

%------------------- These variables are in pixel units---------------------
delta_x = s(1);
figureWidth = mount(2)*delta_x;
delta_y = s(2);
figureHigh  = mount(1)*delta_y;

% we need to locate where the colorbar will be so that we can increase
% margins appropriately
switch lower(colorbarLocation)
    case {'best','auto'}
        if figureWidth > figureHigh
            colorbarLocation = 'south';
        else
            colorbarLocation = 'east';
        end
    case {'east'} %do nothing
    case {'south'} %do nothing
end
%increase margins to accomodate colorbars (these are defined in pixels) 
% and covert margins from percentage to pixel %units
margins(1) = margins(1)*figureWidth;
switch lower(colorbarLocation)
    case {'east'}
        accomodateColorbar = delta_x*0.7; 
        margins(2) = margins(2)*figureWidth + accomodateColorbar;
        margins(4) = margins(4)*figureHigh;
    case {'south'}
        accomodateColorbar = delta_y*0.5; 
        margins(4) = margins(4)*figureHigh + accomodateColorbar;
        margins(2) = margins(2)*figureWidth;
    otherwise
        margins(2) = margins(2)*figureWidth;
        margins(4) = margins(4)*figureHigh;
end
%accomodate title
if ~(isempty(titleHighInPixel))
    extraSpaceTitle = 0;
   % add extra space
   titleHighInPixel = titleHighInPixel + extraSpaceTitle*delta_y;
else
    titleHighInPixel = 0;
end
margins(3) = margins(3)*figureHigh + titleHighInPixel;

innerMargins(1) = innerMargins(1)*figureWidth;
innerMargins(2) = innerMargins(2)*figureHigh;

%update figure dimesion with margins
figureWidth = figureWidth + margins(1) + margins(2) + innerMargins(1)*(mount(2)-1);
figureHigh  = figureHigh + margins(3) + margins(4) + innerMargins(2)*(mount(1)-1);
%--------------------------------------------------------------------------

axesPos = cell(mount);

%normlized units
dx = delta_x./figureWidth;
dy = delta_y./figureHigh;

%pos = [x,y,deltax,deltay]
figPos = [100 100 figureWidth figureHigh];
hFig = figure('Position',figPos,'MenuBar', 'None','visible','off');
movegui(hFig,'center');
%update figPos
figPos = get(hFig,'Position');
%make it visible
set(hFig,'visible',visible);

count = 0;
row_offset = margins(4)./figureHigh;
for row = mount(1):-1:1 %rows
    col_offset = margins(1)./figureWidth;
    for col = 1:mount(2) %col
        count = count +1;
        axesPos{row,col} = [col_offset,row_offset,dx,dy];
        col_offset = col_offset + dx + innerMargins(1)./figureWidth;       
    end
row_offset = row_offset + dy + innerMargins(2)./figureHigh;
end


figureWidthNoMargins = figureWidth - (margins(1) + margins(2)); %pixel units
figureHighNoMargins  = figureHigh  - (margins(3) + margins(4));

%make all computation in pixel units then covert them to normalized units
switch colorbarLocation
    case {'east'}
        %------------------define fix sizes--------------------------------
        fracOfWidth        = 0.12; %defines cbWidth
        fracOfHigh_r1      = 0.85; %defines cbHigh in case single row
        fracOfHigh_rm      = 0.60; %defines cbHigh in case of multiple rows
        fracOfSpaceBetween = 0.10; %defines space between colorbars
        fracOfDistanceX    = 0.05; %defines X distance from slices
        %------------------------------------------------------------------
        cbWidth = fracOfWidth*delta_x;  
        if mount(1) == 1 %just one row
            cbHigh = fracOfHigh_r1*delta_y/colorbarN;
        else
            cbHigh = fracOfHigh_rm*figureHighNoMargins/colorbarN;
        end
        cbX = (figureWidth - margins(2)) + fracOfDistanceX*delta_x;
        %calculate the total space occupied by the colorbars so that we can
        %center them.
        spaceBetweenBars = fracOfSpaceBetween*delta_y;
        cbTotalLength = colorbarN*cbHigh + (colorbarN-1)*spaceBetweenBars;
        discardedSpace = (figureHighNoMargins - cbTotalLength)/2; %this value might be negative, pay attention
        cbYStarts = (margins(4)+discardedSpace):(cbHigh + spaceBetweenBars):figureHighNoMargins;
        for l = 1:colorbarN
            %store and normalize position
            cbConfig.colorbarPos{l} = [cbX/figureWidth,cbYStarts(l)/figureHigh,cbWidth/figureWidth,cbHigh/figureHigh];
        end
    case {'south'}
        %space_occupied_by_slices_y = figureWidth - (margins(1) + margins(2));
        %------------------define fix sizes--------------------------------
        fracOfHigh         = 0.12; %defines cbWidth
        fracOfWidth_r1     = 0.85; %defines cbHigh in case single row
        fracOfWidth_rm     = 0.60; %defines cbHigh in case of multiple rows
        fracOfSpaceBetween = 0.10; %defines space between colorbars
        fracOfDistanceY    = 0.15; %defines Y distance from slices
        %------------------------------------------------------------------
        cbHigh = fracOfHigh*delta_y;  
        if mount(2) == 1 %just one column
            cbWidth = fracOfWidth_r1*delta_x/colorbarN;
        else
            cbWidth = fracOfWidth_rm*figureWidthNoMargins/colorbarN;
        end
        cbY = margins(4) - fracOfDistanceY*delta_y;
        %calculate the total space occupied by the colorbars so that we can
        %center them.
        spaceBetweenBars = fracOfSpaceBetween*delta_x;
        cbTotalLength = colorbarN*cbWidth + (colorbarN-1)*spaceBetweenBars;
        discardedSpace = (figureWidthNoMargins - cbTotalLength)/2; %this value might be negative, pay attention
        cbXStarts = (margins(1)+discardedSpace):(cbWidth + spaceBetweenBars):figureWidthNoMargins;
        for l = 1:colorbarN
            %store and normalize position
            cbConfig.colorbarPos{l} = [cbXStarts(l)/figureWidth,cbY/figureHigh,cbWidth/figureWidth,cbHigh/figureHigh];
        end       
end
cbConfig.location = colorbarLocation;
return
end





