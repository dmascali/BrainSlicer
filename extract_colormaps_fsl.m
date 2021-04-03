function extract_colormaps_fsl(varargin)
% This function needs to be run just once to create "cmaps.mat" that stores
% various colormaps, including those from FSL, Brain Colours and also those
% from matlab (yet, created at high resolution: 256 levels). 

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

save('cmaps','cmap','nMaps');
end