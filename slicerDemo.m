% Let's start by simply printing a standard brain (in MNI space)
%slicer({2},'output','standard_2mm')

% find the folder where example data are stored:
data_folder = [fileparts(which('slicer')),'/exampleData/'];

% We now overlay a Tmap over the standard image, using [3.5 6] as limits
% and a minimum cluster size of 50 voxels
slicer({2,[data_folder,'spmT_0001.nii']},...
    'limits',{[],[3.5 6]},... % when a layer's limit is empty, limits will be adjusted automatically
    'minClusterSize',{0,50},...
    'output','standard_2mm_plus_Tmap')

% It's already a good starting point, but we can make the figure a little
% fancier. For instance, we don't need the colorbar for the standard image, so
% we can modify the default behaviour using the property "labels". We can also move
% the Tmap's colorbar to the east side and add a proper figure title.
slicer({2,[data_folder,'spmT_0001.nii']},...
    'limits',{[],[3.5 6]},...
    'minClusterSize',{0,50},...
    'labels',{[],'T-value'},... % when a layer's label is empty no colorbar will be printed.
    'cbLocation','east',... % colorbar location can be south or east
    'title','Just a Random T-map',...
    'titleLocation','center',...
    'output','standard_2mm_plus_Tmap_fancier')

% Wow! You got a prety cool figure, and it's ready for publication!
% However, depending on your taste you might want to experiment a bit with
% other options, such as the number of slices or the white theme:
slicer({2,[data_folder,'spmT_0001.nii']},...
    'limits',{[],[3.5 6]},...
    'minClusterSize',{0,50},...
    'labels',{[],'T-value'},... % when a layer's label is empty no colorbar will be printed.
    'cbLocation','east',... % colorbar location can be south or east
    'title','Just a Random T-map',...
    'titleLocation','center',...
    'mount', [1 8],... % print one row with 8 slices equally spaced
    'colorMode','w',... % two background modalities: black ('k') or white ('w') 
    'output','standard_2mm_plus_Tmap_fancier_2')

% You might further improve the figure adjusting the following properties:
% ---

%%
