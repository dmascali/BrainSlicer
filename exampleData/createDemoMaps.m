function createDemoMaps(atlas,mu,sigma,name)

hdr = spm_vol(atlas);
img = spm_read_vols(hdr);
nROIs =length(unique(img(:)))-1;

y = abs(mu + sigma*(randn(1,nROIs)));

for l = 1:nROIs
    img(img == l) = y(l);
end

HDR = hdr;
HDR.fname = [name,'.nii'];
HDR.private.dat.fname = [name,'.nii'];
spm_write_vol(HDR,img);


return
end