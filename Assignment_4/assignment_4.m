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
% [T, R, lambda, M1, M2] = rekonstruktion(T1, T2, R1, R2, Korrespondenzen_robust, K);

% size(lambda)
% size(M1)
% size(M2)

% % Zeige euklidische Transformation
% fprintf('Rotations-Matrix:\n');
% fprintf('%+5.3f %+5.3f %+5.3f\n', R');
% fprintf('\nTranslations-Vektor:\n');
% fprintf('%+4.2f\n', T);

x1 = to_cal_hom(Korrespondenzen_robust(1:2, :), K);
x2 = to_cal_hom(Korrespondenzen_robust(3:4, :), K);

fh = @() zeros(length(Korrespondenzen_robust), 2);
d_cell = {fh(), fh(), fh(), fh()};

%% Tiefeninformationen entsprechend Algorithmus aus der Vorlesung rekonstruieren
% Kreuzproduktmatritzen für Korrespondenzpunkte konstruieren
W1 = make_cross_matrix(x1);
W2 = make_cross_matrix(x2);
% Große diagonal angeordnete Rotationsmatrix konstruieren
R = kron(eye(length(Korrespondenzen_robust)), R1);
% Matritzen konstruieren bei denen die Korrespondenzpunkte jeweils spaltenweise diagonal angeordnet sind
fh = @(x) kron(eye(length(x)), ones(3, 1)) .* x(:);
Dx1 = fh(x1);
Dx2 = fh(x2);
% LGS-Matritzen entsprechend Beschreibung aufstellen
fh = @(T) repmat(T1, length(x1), 1);
Diag1 = W2 * R * Dx1;
Rhs1 = W2 * fh(T1);
M1 = [Diag1, Rhs1];

Diag2 = W1 * R' * Dx2;
Rhs2 = -W1 * R' * fh(T1);
M2 = [Diag2, Rhs2];
% Lösung der LGS durch Lösung des Optimierungsproblems argmin(||M * d||²) über d mithilfe der Singulärwertzerlegung
[~, ~, V1] = svd(M1);
[~, ~, V2] = svd(M2);
% Extraktion der Lösungsvektoren d = [λ1, λ2, ..., γ]
d1 = V1(:, end);
d2 = V2(:, end);
% Lösungsvektoren so normieren, dass γ = 1
d1 = d1 / d1(end);
d2 = d2 / d2(end);
% Lösungsvektoren unter Vernachlässigung von γ in d_cell kopieren
d_cell{1} = [d1(1:end-1), d2(1:end-1)];

function x = to_cal_hom(x, K)
    % Pixelkoordinaten in homogene Darstellung umwandeln und mit Kameraparametern (Matrix K = Ks * Kf) justieren

    % Pixelkoordinaten in homogene Darstellung umwandeln
    x = [x; ones(1, length(x))];
    % Pixelkoordinaten mit Kameraparametern justieren
    x = K \ x;
end

function W = make_cross_matrix(V)
    assert(size(V, 1) == 3, 'V muss die Dimension 3xN haben');

    % Unterschiedliche Behandlung von Vektoren und Spaltenmatritzen für rekursive Funktion
    if size(V, 2) == 1
        % V ist ein Vektor
        W = [   0   -V(3)  V(2)
              V(3)     0  -V(1)
             -V(2)   V(1)    0 ];
    else
        % V ist eine Spaltenmatrix
        % Kreuzproduktmatrix initialisieren
        W = zeros([1 1] * 3 * size(V, 2));
        % Zeilen- und Spaltenindizes in der Kreuzproduktmatrix für den aktuellen Diagonalvektor
        indices = 1:3;
        % for each Spalte von V
        for it_column = 1:size(V, 2)
            % Kreuzproduktmatrix für aktuellen Spaltenvektor bauen und in Ergebnismatrix kopieren
            W(indices, indices) = make_cross_matrix(V(:, it_column));
            % Verschiebung der Indizes
            indices = indices + 3;
        end
    end
end
