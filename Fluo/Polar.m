addpath('.\helpfunction');
close all;
clear;

k(1,:) = [101.980833976944	-23.2801824079412];
k(2,:) = [68.1473392654854	76.2256737906748];
k(3,:) = [33.9202219264067	-99.0942100693865];
theta = atan2(k(:,2),k(:,1))+pi/2;

rawImage = double(imstackread('A_Raw0.tif'));
COR = double(imstackread('COR-spot.tif'));
sim_f = double(imstackread('SIM6.tif'));

w = size(sim_f,2);
h = size(sim_f,1);

COR = COR(1:w,1:h,:);
rawImage = rawImage(1:w,1:h,:);

imgs = zeros(size(rawImage));
for i = 1: 1: 6
    imgs(:,:,i) = fadeBorderCos(rawImage(:,:,i),10);
end

calib1 = (COR(:,:,3)+COR(:,:,4))./(COR(:,:,1)+COR(:,:,2));
calib2 = (COR(:,:,5)+COR(:,:,6))./(COR(:,:,1)+COR(:,:,2));

raw_img(:,:,1) = mean(rawImage(:,:,1:2),3);
raw_img(:,:,2) = mean(rawImage(:,:,3:4),3);
raw_img(:,:,3) = mean(rawImage(:,:,5:6),3);


ld = psim_sim2d_recon1(raw_img);
[ouf_pHiLo, pHiLo, wf, cm] = recon_pm(sim_f,ld, theta, min(ld(:)), max(ld(:)), calib1,calib2);

imwrite(uint8(pHiLo*255), ['pHiLo_',  '.tif'])
imwrite(uint8(fliplr(cm*255)), ['cm_', '.tif'])