function drawAtlasEdges(atlas,varargin)
%DRAWATLASEDGES Draw edges of an atlas volume.
%  DRAWATLASEDGES(ATLAS) draws the edges of the ATLAS, where ATLAS is the path
%  to a nifti file. Edges are drawn slice by slice. By default, edges are
%  extracted for the axial view.
%
%  The default behaviour can be modified using the following parameters 
%   (each parameter must be followed by its value ie, 'param1',value1, 
%   'param2',value2):  
%
%   view        - ['ax','sag',cor'] Select the dimension along which
%                 computing edges. Default = 'ax'
%   selector    - If you want to exclude edges belonging to some ROIS you
%                 can provide a logical vector indicating which edges to
%                 draw.
%   output      - output name. Default = 'edges_[view]_[atlas_name]'
%
%   See also SLICER, SLICERCOLLAGE

%__________________________________________________________________________
% Daniele Mascali
% ITAB, UDA, Chieti - 2021
% danielemascali@gmail.com

%--------------VARARGIN----------------------------------------------------
params  =  {'selector', 'output',   'view'};
defParms = {        [],       [],     'ax'};
legalValues{1} = [];
legalValues{2} = [];
legalValues{3} = {'ax','sag','cor'};
[selector,output,view] = ParseVarargin(params,defParms,legalValues,varargin,1);
%--------------------------------------------------------------------------

hdr = spm_vol(atlas);
img = spm_read_vols(hdr);
nROIs = length(unique(img(:)))-1;

if isempty(output)
    [~,atlas_name,ext] = fileparts(hdr.fname); 
    output = ['edges_',upper(view),'_',atlas_name,ext];
end

if isempty(selector)
    selector = ones(nROIs,1);
end

s = size(img);
OUT = img.*0;

switch view
    case 'ax'
        n_slice = s(3);
    case 'sag'
        n_slice = s(1);
    case 'cor'
        n_slice = s(2);
end

%let's work slice by slice
for l = 1:n_slice
    switch view
        case 'ax'
            slice = img(:,:,l);
            sliceOUT = OUT(:,:,l);
        case 'sag'
            slice = squeeze(img(l,:,:));
            sliceOUT = squeeze(OUT(l,:,:));
        case 'cor'
            slice = squeeze(img(:,l,:));
            sliceOUT = squeeze(OUT(:,l,:));
    end
    INDX = [];
    for j = 1:length(selector)
        if ~selector(j)
            continue
        end
        indx = find(slice==j);
        if isempty(indx)
            continue
        end
        tmp = slice.*0;
        tmp(indx) =1;
        EDGE = edge(tmp);
        INDX =  [INDX;find(EDGE)];
    end
    sliceOUT(INDX) = 1;
    switch view
        case 'ax'
            OUT(:,:,l) = sliceOUT;
        case 'sag'
            OUT(l,:,:) = sliceOUT;
        case 'cor'
            OUT(:,l,:) = sliceOUT;
    end
    
end


HDR = hdr;
HDR.fname = output;
HDR.private.dat.fname = output;
spm_write_vol(HDR,OUT);


return
end