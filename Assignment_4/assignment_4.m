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
[T, R, lambda, M1, M2] = rekonstruktion(T1, T2, R1, R2, Korrespondenzen_robust, K);

s_lambda = size(lambda)
s_M1 = size(M1)
s_M2 = size(M2)

% Zeige euklidische Transformation
R
T
