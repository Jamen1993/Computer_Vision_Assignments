% Testskript für Assignment 1
close all;

img = imread('Test_Image.jpg');
gray = rgb_to_gray(img);
tic;
merkmale = harris_detektor(gray, 'segment_length', 9, 'k', 0.06, 'do_plot', true);
t = toc;
fprintf('Die Laufzeit war %f s\n', t);
