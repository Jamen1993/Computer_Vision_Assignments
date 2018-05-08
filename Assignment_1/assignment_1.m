% Testskript für Assignment 1
close all;

img = imread('Test_Image.jpg');
gray = rgb_to_gray(img);
merkmale = harris_detektor_E(gray, 'min_dist', 10, 'N', 30, 'tile_size', [200, 100]);

% Ausgabe der Parameter
min_dist = merkmale{1}
tile_size = merkmale{2}
N = merkmale{3}
