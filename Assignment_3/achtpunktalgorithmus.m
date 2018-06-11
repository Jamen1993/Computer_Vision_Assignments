function EF = achtpunktalgorithmus(Korrespondenzen, K)
    % Diese Funktion berechnet die essenzielle Matrix oder Fundamentalmatrix mittels des 8-Punkt-Algorithmus je nachdem, ob die Kalibrierungsmatrix K gegeben ist oder nicht.

    % Standardwert für K setzen
    if nargin == 1
        K = 1;
        K_given = false;
    else
        K_given = true;
    end

    %% Vorbereitung
    function x = punkte_vorbereiten(x)
        % Bildkoordinaten in homogene Darstellung umwandeln und bei gegebenen Kameraparametern (Matrix K = Ks * Kf) justieren

        % Bildkoordinaten in homogene Darstellung umwandeln
        x = [x; ones(1, length(x))];
        % Bildkoordinaten mit Kameraparametern justieren, falls diese gegeben sind.
        if K_given
            x = K \ x;
        end
    end

    % Punkte für Schätzung der essenziellen oder Fudamentalmatrix vorbereiten
    x1 = punkte_vorbereiten(Korrespondenzen(1:2, :));
    x2 = punkte_vorbereiten(Korrespondenzen(3:4, :));

    % Koeffizientenmatrix für vektorisierte Epipolargleichung berechnen
    % Ich verwende hier eine Schleife, weil es keine Funktion für die Berechnung eines spaltenweise Kroneckerprodukts gibt.
    A = zeros(length(Korrespondenzen), 9);
    % for each Spalte
    for n = 1:length(Korrespondenzen)
        A(n, :) = kron(x1(:, n), x2(:, n));
    end
    % Singulärwertzerlegung der Koeffizientenmatrix
    [~, ~, V] = svd(A);

    %% Schätzung der Matrizen
    % Die rechte Spalte von V ist das Ergebnis des Minimierungsproblems Gs = argmin (||A * Es||²) über Es mit Es als vektorisierter Form der essentiellen Matrix und Gs als geschätzter, essenzieller Matrix in vektorisierter Form.
    % Das so gewonnene G ist in der Regel jedoch keine gültige essenzielle Matrix und muss daher auf die Menge aller gültigen essenziellen Matrizen projiziert werden. Zur Lösung des dafür benötigten Minimierungsproblems E = argmin(||E - G||F²) über E, kann wieder die Singulärwertzerlegung herangezogen werden.

    % Gs aus V extrahieren
    Gs = V(:, end);
    % Gs devektorisieren
    G = reshape(Gs, [3, 3]);
    % Singulärwertzerlegung von G durchführen
    [Ug, ~, Vg] = svd(G);
    % Projektion von G auf den Raum aller essenziellen Matrizen
    E = Ug * diag([1, 1, 0]) * Vg';

    EF = E;
end
