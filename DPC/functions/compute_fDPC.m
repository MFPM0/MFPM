function fDPC = compute_fDPC(imgStack, fDPCFlag)
    [ny, nx, nz] = size(imgStack);
    nPairs = nz/2;
    fDPC = zeros(ny, nx, nPairs);
    if fDPCFlag == 1
        BF = (imgStack(:,:,1) + imgStack(:,:,2)) / 2; 
        for k = 1:nPairs
            numerator = imgStack(:,:,2*k-1) - imgStack(:,:,2*k);
            fDPC(:,:,k) = numerator ./ BF;
        end
    end
end