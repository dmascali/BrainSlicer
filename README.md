[![View BrainSlicer on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://it.mathworks.com/matlabcentral/fileexchange/96792-brainslicer)
# BrainSlicer
BrainSlicer is a MATLAB-based visualization tool for volumetric brain data. Its main purpose is to produce publication-level figures.

BrainSlicer main functionalities include:
- possibility of overlaying multiple images with tunable opacity.
- thresholding and clusterization of each layer
- visualize colorbar for each desired layer
- handy visualization of p-value maps as (1-p)
- ~ 100 colormaps available (including FSL and brain colours maps) 

BrainSlicer is composed of three main programs:

- `slicer.m` - the main tool, visualizes and prints nifti images.  
- `slicerCollage.m` - combines several images produced by `slicer.m` in a single figure.
- `colormaps.m` - shows all the available colormaps and their code for ease of selection.   

## REQUIREMENTS
BrainSlicer requires:
- SPM
- MATLAB version >= R2014b 

## EXAMPLES
[SlicerDemo.m](https://github.com/dmascali/BrainSlicer/blob/master/examples/slicerDemo.m) demostrates the major functionalities of the toolbox using common usage examples.

- Figure showing a t-map and 1-p-map:
&nbsp;![Example 2](https://github.com/dmascali/BrainSlicer/blob/master/examples/highRes/example_3_combined.png)&nbsp;
- Figure showing the 10 networks from Smith et al. 2009 (PNAS):
&nbsp;![Example 3](https://github.com/dmascali/BrainSlicer/blob/master/examples/highRes/example_4_combined.png)&nbsp;
- Figure showing the 7 networks from Yeo et al. 2011 (J Neurophysiol) parcellated according to Schaefer et al 2018 (Cortex):
&nbsp;![Example 3](https://github.com/dmascali/BrainSlicer/blob/master/examples/highRes/example_5.png)&nbsp;
