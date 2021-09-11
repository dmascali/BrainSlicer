%% BrainSlicer Demo
%%
%  This document will demostrate the major functionalities of slicer and slicerCollage using common usage examples. 
%  Before jumping into the examples, make sure _slicer_ is in your matlab's path. 
%
%  Next, we need to retrive the location where example data are stored:
data_folder = [fileparts(which('slicer')),'/exampleData/'];
% Also, close open figures, if any:
close all
%%
%  Now, we are ready to start!

%% Example 1: standard + one-side t-map
% Let's start with a very simple figure: just one layer occupied by a standard brain.
% Layers are specified in the first input to slicer as elements of a cell. 
% You can specify the path to your favourite standard image. However, for your
% convinience, we have stored some popular FSL standard images (in MNI space)
% and reserved them handy aliases:
%%
% 
% * 0 -> MNI152_T1_0.5mm
% * 1 -> MNI152_T1_1mm
% * 2 -> MNI152_T1_2mm
% * 3 -> MNI152_T1_0.5mm_brain
% * 4 -> MNI152_T1_1mm_brain
% * 5 -> MNI152_T1_2mm_brain
%
% Thus, to print the FSL's MNI152_T1_2mm image just run:
slicer({2},'output','example_1')
%%
% That's cool, but it's not very helpfull if we don't overlay something 
% interesting. So, let's add a layer with a T-map. Default values won't probably
% work this time, so we manually specify the t-map limits and the t-map minimum 
% cluster size.
slicer({2,[data_folder,'spmT_0001.nii']},...
    'limits',{[],[3.5 6]},... % when a layer's limit is empty, limits will be adjusted automatically
    'minClusterSize',{0,50},....
    'output','example_1')
%%
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
    'output','example_1')
%%
% Wow! You got a prety cool figure, and it's ready for publication!
% However, depending on your taste you might want to experiment a bit with
% other options, such as the number of slices:
slicer({2,[data_folder,'spmT_0001.nii']},...
    'limits',{[],[3.5 6]},...
    'minClusterSize',{0,50},...
    'labels',{[],'T-value'},... % when a layer's label is empty no colorbar will be printed.
    'cbLocation','east',... % colorbar location can be south or east
    'title','Just a Random one-side T-map',...
    'mount', [1 8],... % print one row with 8 slices equally spaced
    'output','example_1_fancier')

%% Or the background color:
slicer({2,[data_folder,'spmT_0001.nii']},...
    'limits',{[],[3.5 6]},...
    'minClusterSize',{0,50},...
    'labels',{[],'T-value'},... % when a layer's label is empty no colorbar will be printed.
    'cbLocation','east',... % colorbar location can be south or east
    'title','Just a Random one-side T-map',...
    'mount', [1 8],... % print one row with 8 slices equally spaced
    'colorMode','w',... % two background modalities: black ('k') or white ('w') 
    'output','example_1_fancier_white')

%% Example 2: standard + two-side t-map
% The previous example printed a one-side t-map on top of a standard image.
% In the following example we will make a couple of adjustments to print a
% two-side t-map. The trick consists in adding a third layer with the same
% t-map but this time with limits for the negative tail.
slicer({2,[data_folder,'spmT_0001.nii'], [data_folder,'spmT_0001.nii']},...
    'limits',{[],[-6 -3.5], [3.5 6]},...
    'minClusterSize',{0,50,0},...
    'labels',{[],'T-value','T-value'},... % when a layer's label is empty no colorbar will be printed.
    'cbLocation','east',... % colorbar location can be south or east
    'title','Just a Random two-side T-map',...
    'mount', [1 8],... % print one row with 8 slices equally spaced
    'output','example_2')
%% Note that we put the negative layer before the positive layer, so to get 
% the negative colorbar below the positive one.
% We are close to the solution, yet you might have noticed that the default
% colormaps looks odd. It's time to tweak the property 'colormaps'. You can
% get the full list of available colormaps with associated labels and codes
% by running the command:
colormaps
%% To get a more common

%%
slicer({2,[data_folder,'t-map_1.66.nii'],[data_folder,'atlas_edges_120.nii']},...
    'limits',{[],[1.7 4],[0 1]},...
    'minClusterSize',{0,0,0},...
    'labels',{[],'T-value',[]},... % when a layer's label is empty no colorbar will be printed.
    'cbLocation','east',... % colorbar location can be south or east
    'title','Just a Random T-map',...
    'titleLocation','center',...
    'mount', [1 8],... % print one row with 8 slices equally spaced
    'colormaps',{1,2,64},...
    'output','standard_2mm_plus_Tmap_fancier')

slicer({2,[data_folder,'p-map.nii'],[data_folder,'atlas_edges_120.nii']},...
    'limits',{[],[0.95 1],[0 1]},...
    'minClusterSize',{0,0,0},...
    'labels',{[],'P-value',[]},... % when a layer's label is empty no colorbar will be printed.
    'cbLocation','east',... % colorbar location can be south or east
    'title','Just a Random P-map',...
    'titleLocation','center',...
    'mount', [1 8],... % print one row with 8 slices equally spaced
    'colormaps',{1,3,64},...
    'p-map',{0,1,0},...
    'output','standard_2mm_plus_Pmap_fancier')

slicerCollage