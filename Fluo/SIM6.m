clear all
close all
clc



%% Read Expt. Raw SIM Images
bb = imstackread('A_Raw_dark.tif');
[w,~,~]=size(bb);
wo = w/2;
x = linspace(0,w-1,w);
y = linspace(0,w-1,w);
[X,Y] = meshgrid(x,y);

%% Generation of the PSF with Besselj.
scale = 1;                      % used to adjust PSF/OTF width 0.9
[PSFo,OTFo] = PsfOtf(w,scale);

%% Pre-processing of Raw SIM Images
S1aTnoisy = PreProcessingF(bb(:,:,1)) ;
S2aTnoisy = PreProcessingF(bb(:,:,2)) ;
S1bTnoisy = PreProcessingF(bb(:,:,3)) ;
S2bTnoisy = PreProcessingF(bb(:,:,4)) ;
S1cTnoisy = PreProcessingF(bb(:,:,5)) ;
S2cTnoisy = PreProcessingF(bb(:,:,6)) ;

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

%% Pattern
final_image_notch = uint16(65535*Spattern./max(Spattern(:)));
for jz = 1:6
    imwrite(final_image_notch(:,:,jz), 'Pattern.tif', 'WriteMode','append') % 写入stack图像
end

u = 112;     % selecting width of the sub-image
uo = u/2;
OTFo = OTFresize(OTFo,u);
k2a = k2a.*(u/w);
[ MaskPetals, doubleSize ] = MaskPetalsF(OTFo,k2a);

if ( u > 180 )
    PSFe = fspecial('gaussian',16,2.0);
else
    PSFe = fspecial('gaussian',10,0.2);
end


for jx = [1:100:420,494]
    for jy = [1:100:420,494]
        % coordinates for selecting the region from raw SIM images
        xLeft = jx;
        yTop = jy;

        %% obtaining the least square solution
        [fG1, fG3]  = SIMfreqDeconvAngF(n,ModFacEst, ...
            OTFo, Snoisy(xLeft+1:xLeft+u,yTop+1:yTop+u,:),...
            Spattern(xLeft+1:xLeft+u,yTop+1:yTop+u,:), PSFe,...
            MaskPetals, doubleSize);

%         OBJparaA = 1.8*OBJ4powerPara(fG1,fG3,OTFo, doubleSize)*1;
        OBJparaA = [32532489.4670576	-1.66212937484199]*0.9;
        co = 1;
        [fG1f] = W4FilterCenter(fG1,fG3,co,OBJparaA);
        G1f = real( ifft2(fftshift(fG1f)) );

        h = 5;
        figure(1);
        imshow(G1f,[])
        WF_temp = sum(Snoisy(xLeft+1:xLeft+u,yTop+1:yTop+u,:),3);
        raw_temp = bb(xLeft+1:xLeft+u,yTop+1:yTop+u,:);

        figure(2);
        imshow(WF_temp,[])

        figure(3);
        imshow(1+log(abs(fG1f)),[])

        Raw(jx:jx+99,jy:jy+99,:) = raw_temp(h+2:u-h-1,h+2:u-h-1,:);
        WF(jx:jx+99,jy:jy+99) = WF_temp(h+2:u-h-1,h+2:u-h-1);
        SR(jx:jx+99,jy:jy+99) = G1f(h+2:u-h-1,h+2:u-h-1);
    end
end

SR0 = SR-min(SR(:));
tmp = SR-0.2*WF;
imwrite(uint16(65535*tmp./max(tmp(:))),'SIM6.tif');
