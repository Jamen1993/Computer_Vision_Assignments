function [repro_error] = rueckprojektion(Korrespondenzen, P1, Image2, T, R, K)
    % Diese Funktion berechnet den mittleren Rückprojektionsfehler der Weltkoordinaten P1 aus Bild 1 im Kamerakoordinatensystem 2 und stellt sowohl die korrekten als auch die rückprojizierten Merkmalskoordinaten grafisch dar.
    %
    % Korrespondenzen - Matrix in der spaltenweise die Pixelkoordinaten von Korrespondenzpunktpaaren in der Form [x1; y1; x2; y2] abgelegt sind
    % P1 - Merkmalspunkte in Raumkoordinaten in Bezug auf Kamera 1
    % Image2 - Rechtsseitige Abbildung der Szene
    % T und R - Euklidische Bewegung zwischen Kamera 1 und Kamera 2
    % K - Matrix der intrinsischen Kameraparameter K = Ks * Kf
    %
    % repro_error - Mittlerer Rückprojektionsfehler von P1 nach Projektion auf die Bildebene von Kamera 2

    %% Projektion von P1 in Bildebene von Kamera 2
    %
    % P1 in homogenen Raumkoordinaten
    to_hom = @(x) [x; ones(1, length(x))];
    P1_hom = to_hom(P1);
    % Koordinatentransformation zwischen Kamera 1 und Kamera 2
    M = [     R      T
         zeros(1, 3) 1];
    P2_hom = M * P1_hom;
    % Projektion durch Kamera auf Bildebene - vierte Koordinate verschwindet
    to_inhom = @(x) x(1:(end - 1), :);
    P2 = to_inhom(P2_hom);
    % Verzerrung und Abbildung in Pixelkoordinaten durch Kamera berücksichtigen
    x2_prime = K * P2;
    % Normieren für homogene Pixelkoordinaten
    x2_repro = x2_prime ./ x2_prime(3, :);

    %% Rückprojektionsfehler berechnen
    %
    % Korrespondenzpunkte für Kamera 2
    x2_ref = to_hom(Korrespondenzen(3:4, :));
    % Reprojektionsfehler als Mittelwert der 2-normierten Fehlervektoren
    repro_error = mean(vecnorm(x2_repro - x2_ref));

    %% Grafische Darstellung
    %
    figure('name', 'Rueckprojektion');
    % Rechtes Bild der Szene als Hintergrund
    imshow(Image2);
    % Darstellung von Korrespondenzpunkten und rückprojizierten Punkten
    hold on;
    get_x2_ref_row = @(row) x2_ref(row, :);
    plot(get_x2_ref_row(1), get_x2_ref_row(2), 'bo');
    get_x2_repro_row = @(row) x2_repro(row, :);
    plot(get_x2_repro_row(1), get_x2_repro_row(2), 'ro');
    % Verbindungslinien zwischen Original und Rückprojektion
    plot([get_x2_ref_row(1); get_x2_repro_row(1)], [get_x2_ref_row(2); get_x2_repro_row(2)], 'g');
    legend('Original Korrespondenzpunkt', 'Rueckprojektion', 'Paar');
end
