% Testskript für Assignment 1
close all;

img = imread('Test_Image.jpg');
gray = rgb_to_gray(img);
merkmale = harris_detektor_G(gray, 'segment_length', 9, 'k', 0.06);

% Akkumulatorfeld
AKKA = merkmale{1};

% Merkmale
merkmale = merkmale{2};
