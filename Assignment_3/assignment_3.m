% Testscript for Assignment 3
close all;

addpath('../Images');
addpath('../Assignment_1');
addpath('../Assignment_2');

%% Bilder laden
Image1 = imread('Scene_L.png');
IGray1 = rgb_to_gray(Image1);

Image2 = imread('Scene_R.png');
IGray2 = rgb_to_gray(Image2);

%% Harris-Merkmale berechnen
Merkmale1 = harris_detektor(IGray1, 'segment_length', 9, 'k', 0.05, 'min_dist', 40, 'N', 50, 'do_plot', false);
Merkmale2 = harris_detektor(IGray2, 'segment_length', 9, 'k', 0.05, 'min_dist', 40, 'N', 50, 'do_plot', false);

%% Korrespondenzschätzung
Korrespondenzen = punkt_korrespondenzen(IGray1,IGray2,Merkmale1,Merkmale2,'window_length',25,'min_corr',0.9,'do_plot',false);

%% Fundamentalmatrix
F = achtpunktalgorithmus(Korrespondenzen)

%% Essentielle Matrix
% load('K.mat');
% E = achtpunktalgorithmus(Korrespondenzen, K);
