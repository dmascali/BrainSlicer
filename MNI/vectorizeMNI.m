%vectorize MNI images to save space
list = dir('*.gz');

for l = 1:length(list)
   
    clear standard;
    
    name = list(l).name(1:end-7);
    hdr = spm_vol(list(l).name);
    img = spm_read_vols(hdr);
      
    standard.size = size(img);
    standard.indices = find(img);
    standard.img = img(img > 0);
    standard.hdr = hdr;
    
    save([name,'.mat'],'standard'); 
end
