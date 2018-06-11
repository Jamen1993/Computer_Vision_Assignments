function EF = achtpunktalgorithmus(Korrespondenzen, K)
    % Diese Funktion berechnet die Essentielle Matrix oder Fundamentalmatrix mittels 8-Punkt-Algorithmus, je nachdem, ob die Kalibrierungsmatrix 'K' gegeben ist oder nicht.

    % Standardwert für K setzen
    if nargin == 1
        K = 1;
        K_given = false;
    else
        K_given = true;
    end

    % Punkte aus Korrespondenzpunktpaaren extrahieren und in homogene Koordinaten umwandeln
    x1 = Korrespondenzen(1:2, :);
    x1 = [x1; ones(1, length(x1))];
    x2 = Korrespondenzen(3:4, :);
    x2 = [x2; ones(1, length(x2))];

    % Punkte kalibrieren
    if K_given
        x1 = K \ x1;
        x2 = K \ x2;
    end

    % Koeffizientenmatrix für vektorisierte Epipolargleichung berechnen
    A = zeros(length(Korrespondenzen), 9);

    for it = 1:length(Korrespondenzen)
        A(it, :) = kron(x1(:, it), x2(:, it));
    end

    [U, S, V] = svd(A);

    EF = {x1, x2, A, V};
end
