% Testskript für Assignment 1
close all;

img = imread('Test_Image.jpg');
gray = rgb_to_gray(img);
merkmale = harris_detektor_B(gray, 'segment_length', 9, 'k', 0.06);
Ix = merkmale{1};
Iy = merkmale{2};

figure('name', 'Sobelfilter');
subplot(1,2,1), imshow(Ix)
subplot(1,2,2), imshow(Iy)

G11 = merkmale{4};
G22 = merkmale{5};
G12 = merkmale{6};

figure('name', 'Harrisdetektor');
subplot(1,3,1), imshow(G11)
subplot(1,3,2), imshow(G22)
subplot(1,3,3), imshow(G12)

w = merkmale{3}
