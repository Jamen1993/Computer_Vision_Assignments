% Testskript für Assignment 1
close all;

img = imread('Test_Image.jpg');
gray = rgb_to_gray(img);
merkmale = harris_detektor_H(gray, 'segment_length', 9, 'k', 0.06, 'do_plot', true);
