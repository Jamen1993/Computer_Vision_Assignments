% Testskript für Assignment 1
close all;

img = imread('Test_Image.jpg');
gray = rgb_to_gray(img);
merkmale = harris_detektor_F(gray, 'segment_length', 9, 'k', 0.06);

% corners
corners = merkmale{1};

% sorted indey
sorted_index = merkmale{2};
