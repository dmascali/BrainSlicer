function [axesPos,cbConfig,figPos] = figure_grid(mount,subplot_size,margins,innerMargins,colorbarN,colorbarLocation)

s = subplot_size;

% mount = [2,8]; %rows, cols
% s = [50,100];
% margins = [0 0 0 0]; %left right top bottom
% InnerMargins = [0 0]; %x y

%------------------- This variables are in pixel units---------------------
delta_x = s(1);
figureWidth = mount(2)*delta_x;
delta_y = s(2);
figureHigh  = mount(1)*delta_y;

%convert margins from percentage to pixel 
margins(1) = margins(1)*figureWidth/100;
margins(2) = margins(2)*figureWidth/100;
margins(3) = margins(3)*figureHigh/100;
margins(4) = margins(4)*figureHigh/100;

innerMargins(1) = innerMargins(1)*figureWidth/100;
innerMargins(2) = innerMargins(2)*figureHigh/100;

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
figure('Position',figPos,'color','k');

count = 0;
row_offset = margins(4)./figureHigh;
for row = mount(1):-1:1 %rows
    col_offset = margins(1)./figureWidth;
    for col = 1:mount(2) %col
        count = count +1;
        axesPos{row,col} = [col_offset,row_offset,dx,dy];
        col_offset = col_offset + dx + innerMargins(1)./figureWidth;
%         ax = axes;
%         set(ax,'Position',pos{row,col});
%         set(gca,'Xtick',[]);
%         set(gca,'Ytick',[]);
%         text(0.5,0.5, [num2str(row),',',num2str(col)]);
        
    end
row_offset = row_offset + dy + innerMargins(2)./figureHigh;
end

% locate colorbar on longest side. 
figureWidthNoMargins = figureWidth - (margins(1) + margins(2)); %pixel units
figureHighNoMargins  = figureHigh  - (margins(3) + margins(4));
switch lower(colorbarLocation)
    case {'best','auto'}
        if figureWidthNoMargins > figureHighNoMargins
            colorbarLocation = 'South';
        else
            colorbarLocation = 'East';
        end
    case {'east'} %do nothing
    case {'south'} %do nothing
    otherwise
        error('Not recognized colorbar location.')
end

%make all computation in pixel units then covert them to normalized units
switch colorbarLocation
    case {'East'}
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
    case {'South'}
        %space_occupied_by_slices_y = figureWidth - (margins(1) + margins(2));
        %------------------define fix sizes--------------------------------
        fracOfHigh        = 0.12; %defines cbWidth
        fracOfWidth_r1      = 0.85; %defines cbHigh in case single row
        fracOfWidth_rm      = 0.60; %defines cbHigh in case of multiple rows
        fracOfSpaceBetween = 0.10; %defines space between colorbars
        fracOfDistanceY    = 0.05; %defines X distance from slices
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

%colorbar position: just one
%find out slice dimension (i.e, exlcuding margins, but including
%InnerMargins)
space_occupied_by_slices_y = figureHigh -  (margins(3) + margins(4));
cb_width = 0.12*dx;
cb_high = 0.9*dy;
cb_y = (margins(4) + space_occupied_by_slices_y./2)./figureHigh; cb_y = cb_y - cb_high/2;
cb_x = (figureWidth - margins(2))./figureWidth + 0.05*dx;
CBpos.one_bar = [cb_x,cb_y,cb_width,cb_high];

%colorbar positions: two colorbars one
%find out slice dimension (i.e, exlcuding margins, but including
%InnerMargins)
space_occupied_by_slices_y = figureHigh -  (margins(3) + margins(4));
cb_width = 0.12*dx;
if mount(1) == 1 %just one row
    cb_high = 0.9*dy/2;
else
    cb_high = 0.8*dy;
end
cb_y_1 = (margins(4) + space_occupied_by_slices_y./2)./figureHigh; cb_y_1 = cb_y_1 - cb_high -0.04*dy;
cb_y_2 = (margins(4) + space_occupied_by_slices_y./2)./figureHigh; cb_y_2 = cb_y_2 + 0.04*dy;
cb_x = (figureWidth - margins(2))./figureWidth + 0.05*dx;
CBpos.two_bars{1} = [cb_x,cb_y_1,cb_width,cb_high];
CBpos.two_bars{2} = [cb_x,cb_y_2,cb_width,cb_high];
return
end





