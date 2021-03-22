function [pos,colorbarPos,figPos] = figure_grid(mount,subplot_size,margins,innerMargins,colorbarN)

s = subplot_size;

% mount = [2,8]; %rows, cols
% s = [50,100];
% margins = [0 0 0 0]; %left right top bottom
% InnerMargins = [0 0]; %x y

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

pos = cell(mount);

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
        pos{row,col} = [col_offset,row_offset,dx,dy];
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
figureWidthNoMargins = figureWidth -(margins(1) + margins(2));
figureHighNoMargins  = figureHigh - (margins(3) + margins(4));
if figureWidthNoMargins > figureHighNoMargins
    colorbarLocation = 'East';  %South just for testing
else
    colorbarLocation = 'East';
end

figureWidthNoMarginsNorm = figureWidthNoMargins./figureWidth;
figureHighNoMarginsNorm  = figureHighNoMargins./figureHigh;
switch colorbarLocation
    case {'East'}
        cbWidth = 0.12*dx;  cbHigh = 0.9*dy/colorbarN;
        cbX = (figureWidth - margins(2))./figureWidth + 0.05*dx;
        cbYStarts = linspace(margins(4),figureHighNoMargins+margins(4)-colorbarN*(cbHigh + 0.04*delta_y) ,colorbarN)./figureHigh;
        for l = 1:colorbarN
           colorbarPos{l} = [cbX,cbYStarts(l),cbWidth,cbHigh];
        end
    case {'South'}
        space_occupied_by_slices_y = figureWidth - (margins(1) + margins(2));
end

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





