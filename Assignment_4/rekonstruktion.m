function [T, R, lambda, M1, M2] = rekonstruktion(T1, T2, R1, R2, Korrespondenzen, K)
    % Rekonstruktion der Tiefeninformationen aus den Korrespondenzpunkpaaren.
    %
    % Tx - Lösungen für Translation
    % Rx - Lösungen für Rotation
    % Korrespondenzen - Matrix in der spaltenweise die Pixelkoordinaten von Korrespondenzpunktpaaren in der Form [x1; y1; x2; y2] abgelegt sind
    % K - Matrix der intrinsischen Kameraparameter K = Ks * Kf
    %
    % T - Translationsvektor für den die Lösung mit den meisten positiven Tiefeninformationen gefunden wurde
    % R - Rotationsmatrix für die die Lösung mit den meisten positiven Tiefeninformationen gefunden wurde
    % lambda - Tiefe der Korrespondenzpunktpaare für die beste gefundene Kombination aus T und R. In der linken Spalte stehen die Tiefen für das erste Kamerakoordinatensystem und in der zweiten analog die für das zweite.
    % Mx - LGS-Matritzen für die Berechnung der Tiefeninformationen in beiden Kamerakoordinatensystemen

    %% Vorbereitung
    % Cellarrays für T und R erstellen, die bei Iteration über den Index alle Kombinationen von T und R bilden.
    T_cell = {T1, T2, T1, T2};
    R_cell = {R1, R1, R2, R2};
    % Korrespondenzpunkte aus Korrespondenzen extrahieren, in homogene Pixelkoordinaten umwandeln und justieren
    x1 = to_cal_hom(Korrespondenzen(1:2, :), K);
    x2 = to_cal_hom(Korrespondenzen(3:4, :), K);

    %% Rekonstruktion der Tiefeninformationen mit Algorithmus aus der Vorlesung
    %
    % Ich habe mich dazu entschieden die Konstruktion der LGS-Matritzen nicht über eine Schleife, sondern soviel wie möglich durch Funktionen aus der linearen Algebra zu lösen. Ob das performancemäßig sinnvoll ist, ist mir noch nicht klar, aber es war eine interessante Herausforderung.
    %
    % Kreuzproduktmatritzen für Korrespondenzpunkte konstruieren
    W1 = make_cross_matrix(x1);
    W2 = make_cross_matrix(x2);
    % Matritzen konstruieren bei denen die Korrespondenzpunkte jeweils spaltenweise diagonal angeordnet sind
    fh = @(x) kron(eye(length(x)), ones(3, 1)) .* x(:);
    Dx1 = fh(x1);
    Dx2 = fh(x2);
    % Index der Kombination mit der größten Anzahl positiver Tiefenwerte
    i_best_combination = [];
    % Anzahl positiver Tiefenwerte in best_combination
    positive_in_best_combination = 0;
    % Tiefenwerte der Kombination mit der größten Anzahl positiver Tiefenwerte
    lambda = [];
    % for each Kombination von T und R
    for it_combination = 1:4
        % Große, diagonal angeordnete Rotationsmatrix konstruieren
        Rm = kron(eye(length(Korrespondenzen)), R_cell{it_combination});
        % T sooft übereinanderstapeln, dass ich ihn mit der passenden Dimension rechts an den diagonalen Teil von M ansetzen kann.
        Tm = repmat(T_cell{it_combination}, length(Korrespondenzen), 1);
        % LGS-Matritzen entsprechend Beschreibung aufstellen
        %
        % Diagonalen Teil von M1 und M2 konstruieren
        Diag1 = W2 * Rm  * Dx1;
        Diag2 = W1 * Rm' * Dx2;
        % Rechtsseitigen Spaltenvektor von M1 und M2 konstruieren
        Rhs1 =  W2       * Tm;
        Rhs2 = -W1 * Rm' * Tm;
        % M1 und M2 aus ihren Bestandteilen zusammensetzen
        M1 = [Diag1, Rhs1];
        M2 = [Diag2, Rhs2];
        % Lösung der homogenen LGS durch Lösung des Optimierungsproblems argmin(||M * d||²) über d mithilfe der Singulärwertzerlegung
        [~, ~, V1] = svd(M1);
        [~, ~, V2] = svd(M2);
        % Extraktion der Lösungsvektoren d = [λ1, λ2, ..., γ]
        d1 = V1(:, end);
        d2 = V2(:, end);
        % Lösungsvektoren so normieren, dass γ = 1
        d1 = d1 / d1(end);
        d2 = d2 / d2(end);
        % Lösungsvektoren so zusammenfassen, dass zeilenweise die Tiefenwerte eines Korrespondenspunkts für beide Kamerakoordinatensysteme stehen
        current_lambdas = [d1(1:end-1), d2(1:end-1)];
        % Hat der gefundene Lösungsvektor mehr positive Tiefenwerte als der bisher Beste?
        positive_in_current = nnz(current_lambdas > 0);
        if positive_in_current > positive_in_best_combination
            % Dann haben wir eine neue beste Kombination gefunden
            lambda = current_lambdas;
            i_best_combination = it_combination;
            positive_in_best_combination = positive_in_current;
        end
    end
    % T und R der besten Kombination zurückgeben
    T = T_cell{i_best_combination};
    R = R_cell{i_best_combination};
end

function x = to_cal_hom(x, K)
    % Pixelkoordinaten in homogene Darstellung umwandeln und mit Kameraparametern (Matrix K = Ks * Kf) justieren

    % Pixelkoordinaten in homogene Darstellung umwandeln
    x = [x; ones(1, length(x))];
    % Pixelkoordinaten mit Kameraparametern justieren
    x = K \ x;
end

function W = make_cross_matrix(V)
    % Kreuzproduktmatrix aus einem 3x1 Vektor oder einer Matrix aus N spaltenweise angeordneten Vektoren. Ist V eine Matrix, werden die Kreuzproduktmatritzen auf der Hauptdiagonalen angeordnet.

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
