mount = [2,8]; %rows, cols
s = [50,100];
margins = [0 0 0 0]; %left right top bottom
InnerMargins = [0 0]; %x y

delta_x = s(1);
figure_width = mount(2)*delta_x;
delta_y = s(2);
figure_high  = mount(1)*delta_y;

%convert margins from percentage to pixel 
margins(1) = margins(1)*figure_width/100;
margins(2) = margins(2)*figure_width/100;
margins(3) = margins(3)*figure_high/100;
margins(4) = margins(4)*figure_high/100;

InnerMargins(1) = InnerMargins(1)*figure_width/100;
InnerMargins(2) = InnerMargins(2)*figure_high/100;

%update figure dimesion with margins
figure_width = figure_width + margins(1) + margins(2) + InnerMargins(1)*(mount(2)-1);
figure_high  = figure_high + margins(3) + margins(4) + InnerMargins(2)*(mount(1)-1);

pos = cell(mount);

dx = delta_x./figure_width;
dy = delta_y./figure_high;

%pos = [x,y,deltax,deltay]
figure('Position',[10 50 figure_width figure_high]);

count = 0;
row_offset = margins(4)./figure_high;
for row = mount(1):-1:1 %rows
    col_offset = margins(1)./figure_width;
    for col = 1:mount(2) %col
        count = count +1;
        pos{row,col} = [col_offset,row_offset,dx,dy];
        col_offset = col_offset + dx + InnerMargins(1)./figure_width;
        ax = axes;
        set(ax,'Position',pos{row,col});
        set(gca,'Xtick',[]);
        set(gca,'Ytick',[]);
        text(0.5,0.5, [num2str(row),',',num2str(col)]);
        
    end
row_offset = row_offset + dy + InnerMargins(2)./figure_high;
end






