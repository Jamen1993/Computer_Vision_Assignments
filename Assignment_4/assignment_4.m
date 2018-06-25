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

[T_cell, R_cell, d_cell, x1, x2] = rekonstruktion(T1, T2, R1, R2, Korrespondenzen_robust, K);
disp(T_cell);
disp(R_cell);
disp(d_cell);
size(d_cell{1})
size(x1)
size(x2)
