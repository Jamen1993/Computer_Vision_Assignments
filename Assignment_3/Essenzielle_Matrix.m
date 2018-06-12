% Skript für Aufgabe 3.7
close all;

addpath('../Images');
addpath('../Assignment_1');
addpath('../Assignment_2');

%% Bilder laden
% Image1 = rgb_to_gray(imread('szeneL.png'));
Image1 = rgb_to_gray(imread('Scene_L.png'));
% Image2 = rgb_to_gray(imread('szeneR.png'));
Image2 = rgb_to_gray(imread('Scene_R.png'));

%% Harris-Merkmale berechnen
Merkmale1 = harris_detektor(Image1, 'segment_length', 9, 'k', 0.05, 'min_dist', 40, 'N', 50);
Merkmale2 = harris_detektor(Image2, 'segment_length', 9, 'k', 0.05, 'min_dist', 40, 'N', 50);

%% Korrespondenzschätzung
Korrespondenzen = punkt_korrespondenzen(Image1, Image2, Merkmale1, Merkmale2, 'window_length', 25, 'min_corr', 0.9);

%%  Finde robuste Korrespondenzpunktpaare mit Hilfe des RANSAC-Algorithmus
Korrespondenzen_robust = F_ransac(Korrespondenzen, 'tolerance', 0.1);

assert(~isempty(Korrespondenzen_robust), 'Es wurden keine robusten Korrespondenzen gefunden');

%% Zeige die robusten Korrespondenzpunktpaare
figure('name', 'Robuste korrespondierende Merkmale');
% Beide Graustufenbilder mit 50 % Alpha übereinanderlegen
h_I1 = imshow(Image1);
h_I1.AlphaData = 0.5;
hold on;
h_I2 = imshow(Image2);
h_I2.AlphaData = 0.5;
% Korrespondierende Punkte markieren
plot(Korrespondenzen_robust(1, :), Korrespondenzen_robust(2, :), 'ob');
plot(Korrespondenzen_robust(3, :), Korrespondenzen_robust(4, :), 'or');
% Korrespondierende Punkte mit Linien verbinden
plot(Korrespondenzen_robust([1, 3], :), Korrespondenzen_robust([2, 4], :), 'g');
% Beschriftung
title('Robuste korrespondierende Merkmale')
legend('Merkmale aus Bild 1', 'Merkmale aus Bild 2', 'Paar');

%% Berechne die Essentielle Matrix
% load('K.mat');
K = 1e3 * [8.2853,      0, 1.5412;...
                0, 8.3024, 1.4397;...
                0,      0, 0.0010];
E = achtpunktalgorithmus(Korrespondenzen_robust, K)
