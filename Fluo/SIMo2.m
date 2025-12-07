clear all;
close all;
clc;



%% Read Expt. Raw SIM Images
bb = imstackread('Raw_data_6-1.tif');
% bb = bb + 10000*uint16(randn(size(bb)));
% bb = double(bb);
% final_image_notch = uint16(65535*bb./max(bb(:)));
% stackfilename = ['Raw_data_6_noise.tif'];
% for jz = 1:9
%     imwrite(final_image_notch(:,:,jz), stackfilename, 'WriteMode','append') % 写入stack图像
% end


[w,~,~]=size(bb);
wo = w/2;
x = linspace(0,w-1,w);
y = linspace(0,w-1,w);
[X,Y] = meshgrid(x,y);

%% Generation of the PSF with Besselj.
scale = 0.5; % used to adjust PSF/OTF width
[PSFo,OTFo] = PsfOtf(w,scale);

%% Pre-processing of Raw SIM Images
% S1aTnoisy = PreProcessingF(bb(:,:,1)) ;
% S2aTnoisy = PreProcessingF(bb(:,:,2)) ;
% S1bTnoisy = PreProcessingF(bb(:,:,3)) ;
% S2bTnoisy = PreProcessingF(bb(:,:,4)) ;
% S1cTnoisy = PreProcessingF(bb(:,:,5)) ;
% S2cTnoisy = PreProcessingF(bb(:,:,6)) ;


S1aTnoisy =(bb(:,:,1)) ;
S2aTnoisy = (bb(:,:,2)) ;
S1bTnoisy = (bb(:,:,3)) ;
S2bTnoisy = (bb(:,:,4)) ;
S1cTnoisy = (bb(:,:,5)) ;
S2cTnoisy = (bb(:,:,6)) ;

S1aTnoisy = single( S1aTnoisy );
S2aTnoisy = single( S2aTnoisy );
S1bTnoisy = single( S1bTnoisy );
S2bTnoisy = single( S2bTnoisy );
S1cTnoisy = single( S1cTnoisy );
S2cTnoisy = single( S2cTnoisy );

%% 6-frame
n = 6;
ModFacEst = 0.1.*ones(n,1);
Snoisy = zeros(w,w,n);
Snoisy(:,:,1) = S1aTnoisy;
Snoisy(:,:,2) = S2aTnoisy;
Snoisy(:,:,3) = S1bTnoisy;
Snoisy(:,:,4) = S2bTnoisy;
Snoisy(:,:,5) = S1cTnoisy;
Snoisy(:,:,6) = S2cTnoisy;

clear S1aTnoisy S2aTnoisy
clear S1bTnoisy S2bTnoisy
clear S1cTnoisy S2cTnoisy

k2a = zeros(n,2);
PhaseA = zeros(n,1);
Spattern = single(zeros(w,w,n));
PSFe = fspecial('gaussian',14,1.7);
for i = 1:n
    S1aTnoisy = Snoisy(:,:,i);
    [k2a(i,:),PhaseA(i)] = PCMseparateF(S1aTnoisy,OTFo,PSFe);
    Spattern(:,:,i) = single(PatternCheckF(Snoisy(:,:,i),k2a(i,:),PhaseA(i),ModFacEst(i)));
end


% load("matlab.mat");
% kk

% %% Pattern
% final_image_notch = uint16(65535*Spattern./max(Spattern(:)));
% for jz = 1:6
%     imwrite(final_image_notch(:,:,jz), 'Pattern.tif', 'WriteMode','append') % 写入stack图像
% end

u = 132; % selecting width of the sub-image
uo = u/2;
OTFo = OTFresize(OTFo,u);
k2a = k2a.*(u/w);
[ MaskPetals, doubleSize ] = MaskPetalsF(OTFo,k2a);

if ( u > 180 )
    PSFe = fspecial('gaussian',16,2.0);
else
    PSFe = fspecial('gaussian',7,0.7);
end


for jx = 1:80:500
    for jy = 1:80:500
        % coordinates for selecting the region from raw SIM images
        xLeft = jx;
        yTop = jy;

        %% obtaining the least square solution
        [fG1, fG3]  = SIMfreqDeconvAngF(n,ModFacEst, ...
            OTFo, Snoisy(xLeft+1:xLeft+u,yTop+1:yTop+u,:),...
            Spattern(xLeft+1:xLeft+u,yTop+1:yTop+u,:), PSFe,...
            MaskPetals, doubleSize);

        OBJparaA = 0.7*[152292720.822271	-2.23630168691126];
        co = 1;
        [fG1f] = W4FilterCenter(fG1,fG3,co,OBJparaA);
        G1f = real( ifft2(fftshift(fG1f)) );

        h = 25;
        WF_temp = sum(Snoisy(xLeft+1:xLeft+u,yTop+1:yTop+u,:),3);
        raw_temp = bb(xLeft+1:xLeft+u,yTop+1:yTop+u,:);
        figure(1);
        imshow(G1f,[])
        figure(2);
        imshow(WF_temp,[])
        figure(3);
        imshow(1+log(abs(fG1f)),[])

        Raw(jx:jx+79,jy:jy+79,:) = raw_temp(h+2:u-h-1,h+2:u-h-1,:);
        WF(jx:jx+79,jy:jy+79) = WF_temp(h+2:u-h-1,h+2:u-h-1);
        SR(jx:jx+79,jy:jy+79) = G1f(h+2:u-h-1,h+2:u-h-1);
    end
end
imwrite(uint16(65535*SR./max(SR(:))),'A_SR14.tif');
imwrite(uint16(65535*WF./max(WF(:))),'A_WF14.tif');
WF_raw = double(WF_raw);
WF_raw = uint16(655358*WF_raw./max(WF_raw(:)));
for jz = 1:6
    imwrite(COR(:,:,jz),'A_COR2.tif', 'WriteMode','append');
end
for jz = 1:6
    imwrite(Raw(:,:,jz),'A_Raw.tif', 'WriteMode','append');
end
for jz = 1:6
    imwrite(WF_raw(:,:,jz),'A_Raw_Raw.tif', 'WriteMode','append');
end
FFT_SR = fftshift(fft2(SR));
figure;imshow(1+log(abs(FFT_SR)),[])
[Nx,Ny] = size(SR);
k2a2 = k2a.*(w/u).*(Nx/w);

FFT_SR1 = FFT_SR;
for jj = 1:3
    FFT_SR1 = notch1(FFT_SR1,2*k2a2(2*jj-1,:));
end
for jj = 1:3
    FFT_SR1 = notch2(FFT_SR1,2*k2a2(2*jj,:));
end
figure;imshow(1+log(abs(FFT_SR1)),[])

SR1 = abs(ifft2(FFT_SR1));

imwrite(uint8(255*SR1./max(SR1(:))),'SR2-1.tif');

