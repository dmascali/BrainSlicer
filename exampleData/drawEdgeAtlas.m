function drawEdgeAtlas(atlas,goodROIs,output_str)

if nargin < 3
    output_str = '';
else
    output_str = [output_str,'_'];
end

hdr = spm_vol(atlas);
img = spm_read_vols(hdr);
nROIs =sum(goodROIs);

s = size(img);

OUT = img.*0;

%let's work slice by slice
for l = 1:s(3)
    slice = img(:,:,l);
    sliceOUT = OUT(:,:,l);
    INDX = [];
    for j = 1:length(goodROIs)
        if ~goodROIs(j)
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
    OUT(:,:,l) = sliceOUT;
end


HDR = hdr;
HDR.fname = ['atlas_edges_',output_str,num2str(nROIs),'.nii'];
HDR.private.dat.fname = ['atlas_edges_',output_str,num2str(nROIs),'.nii'];
spm_write_vol(HDR,OUT);


return
end