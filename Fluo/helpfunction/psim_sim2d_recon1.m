function ld = psim_sim2d_recon1(raw_sim2d)

[M,N,t]=size(raw_sim2d);
ld=zeros(M,N,3);
ld(:,:,1) = raw_sim2d(:,:,1); 
ld(:,:,2)  = raw_sim2d(:,:,2); 
ld(:,:,3) = raw_sim2d(:,:,3);

end