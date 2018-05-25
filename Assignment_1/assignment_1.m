% Testskript für Assignment 1
close all;

addpath('../Images');

img = imread('Scene_L.png');
gray = rgb_to_gray(img);

merkmale = harris_detektor(gray, 'segment_length', 9, 'k', 0.06, 'do_plot', true);
