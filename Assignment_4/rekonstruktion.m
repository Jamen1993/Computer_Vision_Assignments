function [T_cell, R_cell, d_cell, x1, x2] = rekonstruktion(T1, T2, R1, R2, Korrespondenzen, K)
    % Rekonstruktion der Tiefeninformationen aus den Korrespondenzpunkpaaren.
    %
    % Tx - Lösungen für Translation
    % Rx - Lösungen für Rotation
    % Korrespondenzen - Matrix in der spaltenweise die Pixelkoordinaten von Korrespondenzpunktpaaren in der Form [x1; y1; x2; y2] abgelegt sind
    % K - Matrix der intrinsischen Kameraparameter K = Ks * Kf
    %
    % T_cell und R_cell bilden bei Iteration über den Index alle Kombinationsmöglichkeiten von R und T zu einer euklidischen Transformation
    % d_cell - Hier sollen später die Werte für die Tiefeninformationen [d1 d2] bezogen auf beide Kameras gespeichert werden
    % xx - Korrespondenzpunkte aus Bild x in homogenen, kalibrierten Pixelkoordinaten

    %% Vorbereitung
    % Cellarrays für T und R erstellen, die bei Iteration über den Index alle Kombinationen von T und R bilden.
    T_cell = {T1, T2, T1, T2};
    R_cell = {R1, R1, R2, R2};
    % Korrespondenzpunkte aus Korrespondenzen extrahieren, in homogene Pixelkoordinaten umwandeln und justieren
    x1 = to_cal_hom(Korrespondenzen(1:2, :), K);
    x2 = to_cal_hom(Korrespondenzen(3:4, :), K);

    fh = @() zeros(length(Korrespondenzen), 2);
    d_cell = {fh(), fh(), fh(), fh()};
end

function x = to_cal_hom(x, K)
    % Pixelkoordinaten in homogene Darstellung umwandeln und mit Kameraparametern (Matrix K = Ks * Kf) justieren

    % Pixelkoordinaten in homogene Darstellung umwandeln
    x = [x; ones(1, length(x))];
    % Pixelkoordinaten mit Kameraparametern justieren
    x = K \ x;
end
