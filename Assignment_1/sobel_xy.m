function [Fx, Fy] = sobel_xy(input_image)
    % In dieser Funktion soll das Sobel-Filter implementiert werden, welches
    % ein Graustufenbild einliest und den Bildgradienten in x- sowie in
    % y-Richtung zurückgibt.

    % Filterkoeffizienten für Sobelfilter entsprechend Vorlesungsunterlagen
    % Für die qualitative Berechnung reicht die unnormierte Variante des Sobelfilters.
    g_x = [1 0 -1; 2 0 -2; 1 0 -1];
    g_y = g_x';
    % Faltung der Bilddaten mit dem Sobelfilter: Um den Rand werden Nullen ergänzt, damit auch die äußeren Pixel einen äußeren Nachbarn für den entsprechenden Koeffizienten in der Filtermatrix haben.
    % Dieser Rand wird durch den Parameter "same" nach der Faltung entfernt.
    Fx = conv2(input_image, g_x, 'same');
    Fy = conv2(input_image, g_y, 'same');
end
