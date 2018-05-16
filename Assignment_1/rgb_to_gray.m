function gray_image = rgb_to_gray(input_image)
    % Diese Funktion soll ein RGB-Bild in ein Graustufenbild umwandeln. Falls
    % das Bild bereits in Graustufen vorliegt, soll es direkt zurückgegeben werden.

    % Wenn pro Pixel nur ein Wert vorliegt (XxYx1), handelt es sich um ein Bild in Graustufen
    if size(input_image, 3) == 1
       gray_image = input_image;
    elseif size(input_image, 3) == 3
        % Daten für Berechnung in Fließkommazahl umwandeln
        img = double(input_image);
        % Bild entsprechend Formel in Graustufen umwandeln
        gimg = 0.299 * img(:,:,1) + 0.587 * img(:,:,2) + 0.114 * img(:,:,3);
        % Daten zurück in Integer umwandeln
        gray_image = uint8(gimg);
    else
        error("Daten in unbekanntem Format: Es wird ein Bild in RGB-Darstellung mit dem Format MxNx3 oder in Graustufendarstellung mit dem Format MxNx1 erwartet.");
    end
end
