function [T1, R1, T2, R2] = TR_aus_E(E)
    % Diese Funktion berechnet die möglichen Werte für T und R aus der Essenziellen Matrix.
    %
    % E - Essenzielle Matrix für eine Szene
    %
    % T1 - Erste Lösung für die Translationsmatrix T_hat mit Rz(pi/2)
    % T2 - Zweite Lösung für die Translationsmatrix T_hat mit Rz(-pi/2)
    % R1 - Erste Lösung für die Rotationsmatrix R mit Rz(pi/2)
    % R1 - Zweite Lösung für die Rotationsmatrix R mit Rz(-pi/2)
    % U - Vordere Matrix der Singulärwertzerlegung von E
    % V - Hintere Matrix der Singulärwertzerlegung von E

    % Singulärwertzerlegung von E durchführen
    [U, S, V] = svd(E);
    % U und V in echte Rotationsmatrizen transformieren (Determinante = 1)
    U = make_rotation(U);
    V = make_rotation(V);
    % R und T der durch E ausgedrückten euklidischen Bewegung rekonstruieren
    % Rotationsmatrix um pi/2 um die Z-Achse
    Rz_plus = [0, -1, 0;...
               1,  0, 0;...
               0,  0, 1];
    % Rotationsmatrix um -pi/2 um die Z-Achse
    Rz_minus = [0, 1, 0;...
               -1, 0, 0;...
                0, 0, 1];
    % Translationen rekonstruieren
    T1 = reconstruct_T(U, S, Rz_plus);
    T2 = reconstruct_T(U, S, Rz_minus);
    % Lambda zur Rekonstruktion von R
    reconstruct_R = @(Rz) U * Rz' * V';
    % Rotationen rekonstruieren
    R1 = reconstruct_R(Rz_plus);
    R2 = reconstruct_R(Rz_minus);
end

function result = feq(l, r)
    % Compares two floating point numbers for equality

    result = abs(l - r) < 1e-12;
end

function R = make_rotation(R)
    % Make R a rotation matrix.
    %
    % R - Orthogonal matrix

    % Assure that R's determinant is 1 which is the second requirement, besides orthogonality, for a rotation matrix.
    if feq(det(R), -1)
        R = R * diag([1, 1, -1]);
    end
end

function T = reconstruct_T(U, S, Rz)
    % T aus Singulärwertzerlegung von E und Rotationsmatrix um die Z-Achse rekonstruieren.

    % Dachoperator T aus Singulärwertzerlegung rekonstruieren
    T_hat = U * Rz * S * U';
    % Elemente von T aus Dachoperator T extrahieren
    T = [T_hat(3, 2);...
         T_hat(1, 3);...
         T_hat(2, 1)];
end
