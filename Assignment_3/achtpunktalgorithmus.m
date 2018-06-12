function EF = achtpunktalgorithmus(Korrespondenzen, K)
    % Diese Funktion berechnet die essenzielle Matrix oder Fundamentalmatrix mittels des 8-Punkt-Algorithmus je nachdem, ob die Kalibrierungsmatrix K gegeben ist oder nicht.
    %
    % Korrespondenzen - Matrix in der spaltenweise die Pixelkoordinaten von Korrespondenzpunktpaaren in der Form [x1; y1; x2; y2] abgelegt sind
    % K - Matrix der intrinsischen Kameraparameter K = Ks * Kf
    %
    % EF - Geschätzte essenzielle Matrix oder Fundamentalmatrix, je nachdem, ob K gegeben wurde

    % Prüfen, ob K übergeben wurde und in einem boolean vermerken
    K_given = logical(nargin - 1);

    %% Vorbereitung
    function x = punkte_vorbereiten(x)
        % Pixelkoordinaten in homogene Darstellung umwandeln und bei gegebenen Kameraparametern (Matrix K = Ks * Kf) justieren

        % Pixelkoordinaten in homogene Darstellung umwandeln
        x = [x; ones(1, length(x))];
        % Pixelkoordinaten mit Kameraparametern justieren, falls diese gegeben sind.
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
    [~, ~, Va] = svd(A);

    %% Schätzung der Matrizen
    % Die rechte Spalte von V ist das Ergebnis des Minimierungsproblems Gs = argmin (||A * EFs||²) über EFs mit EFs als vektorisierter Form der EF-Matrix (essenzielle oder Fundamentalmatrix, je nachdem, ob mit justierten Pixelkoordinaten gearbeitet wurde) und Gs als geschätzter EF-Matrix in vektorisierter Form.
    % Das so gewonnene G ist in der Regel jedoch keine gültige EF-Matrix und muss daher auf die Menge aller gültigen EF-Matrizen projiziert werden. Zur Lösung des dafür benötigten Minimierungsproblems EF = argmin(||EF - G||F²) über EF, kann wieder die Singulärwertzerlegung herangezogen werden.
    % Da schlussendlich eine essenzielle Matrix oder eine Fundamentalmatrix gefunden werden soll, muss an dieser Stelle eine Fallunterscheidung durchgeführt werden, da die Funktionsvorschriften für die Projektion in den E- oder F-Raum unterschiedlich sind.

    % Gs aus V extrahieren
    Gs = Va(:, end);
    % Gs devektorisieren
    G = reshape(Gs, [3, 3]);
    % Singulärwertzerlegung von G durchführen
    [Ug, Sg, Vg] = svd(G);
    % Projektion von G auf den Raum aller EF-Matrizen
    % Fallunterscheidung bezüglich E oder F und modifizierte Singulärwertmatrix entsprechend konstruieren
    if K_given
        % Es wird eine essenzielle Matrix geschätzt
        % Die Bedingung für eine essenzielle Matrix ist σ1 = σ2 ≠ 0
        Sg_mod = diag([1, 1, 0]);
    else
        % Es wird eine Fundamentalmatrix geschätzt
        % Die Bedingung für eine Fundamentalmatrix ist σ1 ≠ σ2 ≠ 0
        Sg_mod = Sg;
        Sg_mod(3, 3) = 0;
    end
    % Projektion durchführen
    EF = Ug * Sg_mod * Vg';
end
