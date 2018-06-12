function sd = sampson_dist(F, x1_pixel, x2_pixel)
    % Diese Funktion berechnet die Sampson-Distanz basierend auf der Fundamentalmatrix F und zwei Vektoren von Korrespondenzpaaren in homogegen Pixelkoordinaten.
    %
    % F - Fundamentalmatrix
    % x1_pixel, x2_pixel - Erstes und zweites Pixel des Korrespondenzpunktpaars in homogenen Pixelkoordinaten der Form xn_pixel = [x; y; 1]. Wenn mehrere Korrespondenzpunktpaare verwendet werden sollen, können diese spaltenweise angehängt werden. Die Sampson-Distanz wird nur zwischen Paaren mit gleichem Spaltenindex berechnet.
    %
    % sd - Wenn x1_pixel und x2_pixel einspaltig sind, ist sd die Sampson-Distanz dieses Paars. Sind sie hingegen mehrspaltig, enthält sd spaltenweise die Sampson-Distanz des jeweiligen Paars mit dem selben Spaltenindex in x1_pixel und x2_pixel.


    assert(size(x1_pixel) == size(x2_pixel), 'x1_pixel und x2_pixel müssen die gleiche Dimension haben');

    %% Berechnung der Sampson-Distanz entsprechend Angabe
    % Kreuzproduktmatrix zum dritten Einheitsvektor e3 = [0, 0, 1]
    E3_hat = [0, -1, 0;...
              1,  0, 0;...
              0,  0, 0];
    % Zähler der Sampson-Distanz
    n = diag(x2_pixel' * F * x1_pixel) .^ 2;
    % Nenner der Sampson-Distanz
    % Linker term
    dlt = sum((E3_hat * F * x1_pixel) .^ 2, 1);
    % Rechter term
    drt = sum((x2_pixel' * F * E3_hat) .^ 2, 2);
    % Nenner
    d = dlt' + drt;
    % Sampson-Distanz
    sd = (n ./ d)';
end
