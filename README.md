[![View BrainSlicer on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://it.mathworks.com/matlabcentral/fileexchange/96792-brainslicer)
# Brain Slicer
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

## INSTALLATION
   BrainSlicer needs to be added to the matlab path. 

## REQUIREMENTS
BrainSlicer requires:
- SPM to be installed
- MATLAB version >= R2014b 