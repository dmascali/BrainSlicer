function createDemoMaps(atlas,nu)

hdr = spm_vol(atlas);
img = spm_read_vols(hdr);
nROIs =length(unique(img(:)))-1;

t = abs(trnd(nu,1,nROIs));
thr = tinv(1-0.05,nu);
p = 1-tcdf(t,nu-1);

T = img;
P = img;
for l = 1:nROIs
    T(img == l) = t(l);
    P(img == l) = p(l);
end

HDR = hdr;
HDR.dt = [16 0];
HDR.fname = ['t-map_',num2str(thr,4),'.nii'];
HDR.private.dat.fname = ['t-map_',num2str(thr,4),'.nii'];
spm_write_vol(HDR,T);

HDR = hdr;
HDR.dt = [16 0];
HDR.fname = ['p-map.nii'];
HDR.private.dat.fname = ['p-map.nii'];
spm_write_vol(HDR,P);


return
end