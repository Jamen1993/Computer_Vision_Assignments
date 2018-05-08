% Testskript für Assignment 1
close all;

img = imread('Test_Image.jpg');
gray = rgb_to_gray(img);
merkmale = harris_detektor_C(gray, 'segment_length', 9, 'k', 0.06);
H = merkmale{1};
corners = merkmale{2};
merkmale = merkmale{3};

figure();
subplot(1,2,1), imshow(H)
subplot(1,2,2), imshow(corners)

merkmale(:,min(5,size(merkmale,2)));
