function merkmale = harris_detektor_B(input_image, varargin)
    % In dieser Funktion soll der Harris-Detektor implementiert werden, der
    % Merkmalspunkte aus dem Bild extrahiert
    %% Input parser aus Aufgabe 1.3
    if nargin > 9
        error("Zu viele Parameter");
    end

    % Parameter entsprechend Beschreibung parsen; Standardwerte setzen und prüfen.
    p = inputParser;

    addParameter(p, 'segment_length', 15, @(x) assert(isnumeric(x) && isscalar(x) && mod(x,2) == 1 && x > 1, 'segment_length muss eine ungerade Ganzzahl größer 1 sein'));
    addParameter(p, 'k', 0.05, @(x) assert(isnumeric(x) && isscalar(x) && 0 <= x && x <= 1, 'k muss eine Reelle Zahl im Intervall [0; 1] sein.'));
    addParameter(p, 'tau', 1e6, @(x) assert(isnumeric(x) && isscalar(x) && x > 0, 'tau muss eine Reelle Zahl größer 0 sein'));
    addParameter(p, 'do_plot', false, @(x) assert(islogical(x), 'k muss ein logical sein.'));

    parse(p, varargin{:});

    segment_length = p.Results.segment_length;
    k = p.Results.k;
    tau = p.Results.tau;
    do_plot = p.Results.do_plot;

    %% Vorbereitung zur Feature Detektion
    % Prüfe ob es sich um ein Grauwertbild handelt
    if size(input_image, 3) ~= 1
       error("Image format has to be NxMx1");
    end
    % Datentyp für Filterung konvertieren
    gimg = double(input_image);
    % Approximation des Bildgradienten
    [Ix, Iy] = sobel_xy(gimg);
    % Gewichtung mit Hammingfenster
    max_index = (segment_length - 1);
    index = 0:max_index;
    w = 0.54 - 0.46*cos(2*pi*index/max_index);
    w_norm = w / sum(w);
    % Kombiniert zu separablem Filter
    W = w_norm' * w_norm;
    % Harris Matrix G
    % Komponenten der Harrismatrix für jedes Pixel berechnen
    G11 = Ix .^ 2;
    G12 = Ix .* Iy;
    G22 = Iy .^ 2;
    % Komponenten mit Fensterfunktion falten, um mittigen Pixeln mehr Gewicht zu verleihen
    G11_filtered = conv2(G11, W, 'same');
    G12_filtered = conv2(G12, W, 'same');
    G22_filtered = conv2(G22, W, 'same');

    merkmale = {Ix, Iy, w_norm, G11_filtered, G22_filtered, G12_filtered};
end
