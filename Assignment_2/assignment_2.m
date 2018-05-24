% Testscript für Assignment 2
close all;

addpath('../Images');
addpath('../Assignment_1');

Image1 = imread('Scene_L.png');
IGray1 = rgb_to_gray(Image1);

Image2 = imread('Scene_R.png');
IGray2 = rgb_to_gray(Image2);

% Harris-Merkmale berechnen
Merkmale1 = harris_detektor(IGray1, 'segment_length', 9, 'k', 0.05, 'min_dist', 50, 'N', 20, 'do_plot', false);
Merkmale2 = harris_detektor(IGray2, 'segment_length', 9, 'k', 0.05, 'min_dist', 50, 'N', 20, 'do_plot', false);

Korrespondenzen = punkt_korrespondenzen(IGray1, IGray2, Merkmale1, Merkmale2, 'window_length', 25, 'min_corr',  0.90, 'do_plot', true)
