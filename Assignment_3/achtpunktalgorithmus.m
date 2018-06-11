function EF = achtpunktalgorithmus(Korrespondenzen, K)
    % Diese Funktion berechnet die Essentielle Matrix oder Fundamentalmatrix mittels 8-Punkt-Algorithmus, je nachdem, ob die Kalibrierungsmatrix 'K' gegeben ist oder nicht.

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

    % Punkte für Schätzung der Essentiellen oder Fudamentalmatrix vorbereiten
    x1 = punkte_vorbereiten(Korrespondenzen(1:2, :));
    x2 = punkte_vorbereiten(Korrespondenzen(3:4, :));

    % Koeffizientenmatrix für vektorisierte Epipolargleichung berechnen
    A = zeros(length(Korrespondenzen), 9);

    for it = 1:length(Korrespondenzen)
        A(it, :) = kron(x1(:, it), x2(:, it));
    end

    [~, ~, V] = svd(A);

    EF = {x1, x2, A, V};
end
