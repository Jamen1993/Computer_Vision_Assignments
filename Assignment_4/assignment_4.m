% Testscript for Assignment 4
close all;

%% Funktionen der vorhergehenden Aufgaben laden
addpath('../Images');
addpath('../Assignment_1');
addpath('../Assignment_2');
addpath('../Assignment_3');

%% Kameraparameter und mit RanSaC ausgewählte Korresponzpunkte laden
load K;
load Korrespondenzen_robust;

%% Assignment 4
% Essenzielle Matrix der Szene mit Achtpunktalgorithmus schätzen
E = achtpunktalgorithmus(Korrespondenzen_robust, K);
% T und R aus E rekonstruieren
[T1, R1, T2, R2] = TR_aus_E(E);
% Rekonstruktion der Tiefeninformationen
[Tr, Rr, lambda] = rekonstruktion(T1, T2, R1, R2, Korrespondenzen_robust, K);
% Gleiche Skalierung von X- und Y-Achse
h = get(gca,'DataAspectRatio');
set(gca,'DataAspectRatio',[1 1 h(3)]);
% Neue Daten für 4.5 laden
load R;
load T;
load P1;
load Korrespondenzen_robust_2;
% Rechtes Bild laden
Image2 = imread('Scene_R.png');
IGray2 = rgb_to_gray(Image2);
% Rückprojektionsfehler berechnen
[repro_error, x2_prime_hom] = rueckprojektion(Korrespondenzen_robust_2, P1, IGray2, T, R, K);
