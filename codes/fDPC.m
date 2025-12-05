clear;close;

I1 = imread("...\datasets\exp1\1.tif");
I2 = imread("...\datasets\exp1\2.tif");

I_bf = (I1+I2)/2;
I_ph = (I1-I2)./I_bf;

subplot(2,2,1);imshow(I1);
subplot(2,2,2);imshow(I2);
subplot(2,2,3);imshow(I_bf,[]);
subplot(2,2,4);imshow(I_ph,[]);