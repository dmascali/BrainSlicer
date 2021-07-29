# Brain Slicer
Brain Slicer is a MATLAB-based visualization tool for volumetric brain data. Its main puropese is to produce publication-level figure.

Brain Slicer main functionalities include:
- possibility of overlaying multiple images with tunable opacity.
- thresholding and clusterization of each layer
- visualize colorbar for each desired layer
- handy visualization of p-value maps as (1-p)
- ~ 100 colormaps available (including FSL and brain colours maps) 

Brain Slicer is composed of three main programs:

- `slicer.m` - the main tool, visualizes and prints nifti images.  
- `slicerCollage.m` - combines several images produced by `slicer.m` in a single figure.
- `colormaps.m` - shows all the available colormaps and their code for ease of selection.   

## INSTALLATION
   Brain Slicer needs to be added to the matlab path. 
   It also requires SPM to be installed. 
