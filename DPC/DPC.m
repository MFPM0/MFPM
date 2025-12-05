clear; close all;
addpath('functions');

%% Seclect a reconstruction method
fDPCFlag = 0;
qDPCFlag = 1;

%% load image and parameters
Image = load_images(fDPCFlag,qDPCFlag);
params = struct();
params.sigma       = 1.0;        % partial coherence factor
params.na          = 0.30;       % objective NA
params.mag         = 10;         % magnification
params.lambda      = 0.514;      % wavelength (um)
params.ps          = 4/params.mag; % pixel size (um)
params.illu_angles = [0, 180, 90, 270];
params.na_inner    = 0;
grid = prepare_grids(size(Image,1), size(Image,2), params.ps);

if fDPCFlag == 1
%% Reconstruction of fDPC
    fDPCImage = compute_fDPC(Image, fDPCFlag);
    figure('Name', 'Reconstructed results of fDPC');
    if size(fDPCImage,3) == 1
        imshow(fDPCImage, []); title('Result of fDPC', 'FontSize', 16);
    else
        for i = 1:size(fDPCImage,3)
            subplot(1,2,i); imshow(fDPCImage(:,:,i), []); 
            title(sprintf('Result of fDPC%d', i),'FontSize', 16);
        end
    end 
else
%% Reconstruction of qDPC
    na_illum = params.sigma * params.na;
    numRot = numel(params.illu_angles);
    Source = build_source(params.illu_angles, na_illum, params.na_inner, params.lambda, numRot, grid.Fx, grid.Fy);
    pupil = (grid.Fx.^2 + grid.Fy.^2 <= (params.na/params.lambda)^2);
    Hi = build_TransFunc(Source, pupil);
    FImage = fft2(Image);
    reg_tik = 5e-3;
    qDPCImage = compute_qDPC(FImage, Hi, reg_tik);
    figure('Name', 'Reconstructed results of qDPC');
    imagesc(qDPCImage); axis image; axis off; colormap('gray'); colorbar;
    title('recovered \phi', 'FontSize', 16);
end
