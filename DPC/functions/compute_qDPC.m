function phase_recon = compute_qDPC(FImage, Hi, reg_tik)
    cells_Hi = squeeze(num2cell(Hi, [1 2]));  
    M = cells_Hi;  

    MconjT = cellfun(@(x) conj(x), M.', 'UniformOutput', false);
    R = zeros(size(FImage,1),size(FImage,2));

    for k = 1:4
        R = R +  MconjT{k} .* M{k};
    end

    denominator     = R+ reg_tik;
    I              = sum(FImage.*conj(Hi), 3);
    phase_recon     = real(ifft2(I./denominator));


end