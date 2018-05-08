function merkmale = harris_detektor_C(input_image, varargin)
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

    %% Merkmalsextraktion über die Harrismessung
    % Determinante von G für jedes Pixel
    G_det = G11_filtered .* G22_filtered - G12_filtered .^ 2;
    % Spur von G für jedes Pixel
    G_tr = G11_filtered + G22_filtered;
    % Harrismetrik für jedes Pixel
    H = G_det - k .* G_tr .^ 2;
    % Am Rand ist die Harrismetrik aufgrund von Unregelmäßigkeiten bei der Interpolation im vorherigen Abschnitt groß. Das führt bei der Intepretation der Metrik fälschlicherweise zur Detektion von Kanten. Der Rand muss also als ungültig erklärt werden, was durch Ersatz mit 0 möglich ist.
    margin_size = ceil(segment_length / 2);
    H_without_margin = zeros(size(H));
    H_without_margin((margin_size + 1):(end - margin_size), (margin_size + 1):(end - margin_size)) = H((margin_size + 1):(end - margin_size), (margin_size + 1):(end - margin_size));
    % Schwellwert für Ecke prüfen
    pixels_above_threshold = H_without_margin > tau;
    % Pixel ohne Ecken eliminieren
    corners = H_without_margin .* pixels_above_threshold;
    % Pixelkoordinaten der Ecken in Array zusammenfassen
    [y, x] = find(pixels_above_threshold);
    merkmale = [x'; y'];

    %% Plot
    if do_plot
        figure('name', 'Merkmale');
        imshow(input_image);
        hold on;
        plot(x, y, 'or');
        hold off;
        legend('Detektierte Ecken');
    end
end
