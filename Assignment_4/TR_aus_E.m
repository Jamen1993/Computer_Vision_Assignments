function [T1, R1, T2, R2, U, V] = TR_aus_E(E)
    % Diese Funktion berechnet die möglichen Werte für T und R aus der Essenziellen Matrix
    %
    % E - Essenzielle Matrix für eine Szene

    [U, S, V] = svd(E);

    U = make_rotation(U);
    V = make_rotation(V);

    T1 = [];
    R1 = [];
    T2 = [];
    R2 = [];

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
