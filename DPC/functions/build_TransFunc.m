function Hi = build_TransFunc(Source, pupil)  
    Hi = zeros(size(Source));
    
    for i = 1:size(Source, 3)
        source = Source(:,:,i);
        source = rot90(padarray(fftshift(source), [1,1], 'post'), 2);
        source = ifftshift(source(1:end-1, 1:end-1));
        TransFun = conj(fft2(source .* pupil)) .* fft2(pupil);
        Hi_temp = 2 * ifft2(1i * imag(TransFun));
        DC = sum(sum(source .* abs(pupil).^2));
        Hi(:,:,i) = 1i * Hi_temp / DC;
    end
end
