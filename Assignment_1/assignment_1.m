% Testskript für Assignment 1
close all;

img_1 = imread('Test_Image_1.jpg');
img_2 = imread('Test_Image_2.jpg');
gray_1 = rgb_to_gray(img_1);
gray_2 = rgb_to_gray(img_2);
tic;
merkmale_1 = harris_detektor(gray_1, 'segment_length', 9, 'k', 0.06, 'do_plot', true);
t_1 = toc;
merkmale_2 = harris_detektor(gray_2, 'segment_length', 9, 'k', 0.06, 'do_plot', true);
t_2 = toc - t_1;
