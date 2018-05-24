function merkmale = harris_detektor(input_image, varargin)
    % In dieser Funktion soll der Harris-Detektor implementiert werden, der
    % Merkmalspunkte aus dem Bild extrahiert.

    %% Input parser
    % input_image + 7 name value pairs = 15 Parameter
    if nargin > 15
        error('Zu viele Parameter');
    end

    % Parameter entsprechend Beschreibung parsen; Standardwerte setzen und prüfen.
    p = inputParser;

    addParameter(p, 'segment_length', 15, @(x) assert(isnumeric(x) && isscalar(x) && mod(x,2) == 1 && x > 1, 'segment_length muss eine ungerade Ganzzahl größer 1 sein'));
    addParameter(p, 'k', 0.05, @(x) assert(isnumeric(x) && isscalar(x) && 0 <= x && x <= 1, 'k muss eine reelle Zahl im Intervall [0; 1] sein.'));
    addParameter(p, 'tau', 1e6, @(x) assert(isnumeric(x) && isscalar(x) && x > 0, 'tau muss eine reelle Zahl größer 0 sein'));
    addParameter(p, 'do_plot', false, @(x) assert(islogical(x), 'do_plot muss ein logical sein.'));
    addParameter(p, 'min_dist', 20, @(x) assert(isnumeric(x) && x >= 1, 'min_dist muss eine reelle Zahl größer gleich 1 sein.'));
    addParameter(p, 'tile_size', 200, @(x) assert(isnumeric(x) && prod(x >= 1) == 1 , 'tile_size muss eine Ganzzahl größer gleich 1 sein.'));
    addParameter(p, 'N', 5, @(x) assert(isnumeric(x) && x >= 1, 'N muss eine Ganzzahl größer gleich 1 sein.'));

    parse(p, varargin{:});

    % Parameter umbennenen für einfachere Nutzung
    segment_length = p.Results.segment_length;
    k = p.Results.k;
    tau = p.Results.tau;
    do_plot = p.Results.do_plot;
    min_dist = p.Results.min_dist;
    % Größe von tile_size übernehmen oder quadratische Kachel festlegen
    tile_size = [1, 1] .* p.Results.tile_size;
    N = p.Results.N;

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
    % Formel aus Matlab Dokumentation
    w = 0.54 - 0.46*cos(2*pi*index/max_index);
    w_norm = w / sum(w);
    % Zu zweidimensionalem separablem Filter kombinieren
    W = w_norm' * w_norm;
    % Harris Matrix G
    % Komponenten der Harrismatrix für jedes Pixel berechnen
    G11 = Ix .^ 2;
    G12 = Ix .* Iy;
    G22 = Iy .^ 2;
    % Komponenten mit Filterfunktion falten, um sie zu glätten und mittigen Pixeln mehr Gewicht zu verleihen.
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
    % margin size
    margin_size = ceil(segment_length / 2);
    % Maske für Rand erstellen
    mask = true(size(H));
    mask((margin_size + 1):(end - margin_size), (margin_size + 1):(end - margin_size)) = false;
    % Rand mit maske zu Null setzen
    H_margin = H;
    H_margin(mask) = 0;
    % Pixel ohne Ecken durch Maskierung eliminieren
    corners = H_margin;
    corners(corners <= tau) = 0;

    %% Merkmalsvorbereitung
    % Rand mit Nullen um corners hinzufügen
    % Der Rand wird benötigt, damit später die Cake-Maske angewandt werden kann ohne, dass es am Rand zu Konflikten bei der Indizierung kommt.
    corners_padded = zeros(size(corners) + 2 * min_dist);
    corners_padded((min_dist + 1):(end - min_dist), (min_dist + 1):(end - min_dist)) = corners;
    % corners_padded spaltenweise vektorisieren und Index der ursprünglichen Position hinzufügen
    [X, Y] = meshgrid(1:size(corners_padded, 2), 1:size(corners_padded, 1));
    corners_indices = [corners_padded(:), Y(:), X(:)];
    % Reihen mit Merkmalsstärke 0 eliminieren
    corners_indices((corners_padded(:) == 0), :) = [];
    % Reihen entsprechend der Merkmalsstärke absteigend sortieren
    corners_indices_sorted = sortrows(corners_indices, 'descend');

    %% Akkumulatorfeld
    % Kacheln gleichverteilt über Bild
    AKKA = zeros(ceil(size(input_image) ./ tile_size));
    % Nach der Verareitung kann es maximal N Merkmale pro Kachel geben aber auch nur dann, wenn die Anzahl der gefundenen Merkmale die Anzahl der möglichen Merkmale übersteigt. Ansonsten sind nur so viele Merkmale möglich, wie bereits vorher gefunden wurden.
    n_merkmale = min([length(corners_indices_sorted), numel(AKKA) * N]);
    merkmale = zeros(2, n_merkmale);

    %% Merkmalsbestimmung mit Mindestabstand und Maximalzahl pro Kachel
    % Diese Maske wird verwendet, um mit Hilfe der Cake-Maske die Merkmalsdichte entsprechend min_dist zu reduzieren.
    min_dist_mask = logical(corners_padded);
    % Cake-Maske generieren
    Cake = cake(min_dist);
    % Merkmale und Indizes aus corners_indices_sorted extrahieren
    corners_sorted = corners_indices_sorted(:, 1);
    iy = corners_indices_sorted(:, 2);
    ix = corners_indices_sorted(:, 3);
    % Kachel der sortierten Merkmale berechnen
    % Vorher muss eine Indexverschiebung vom Bild mit Padding zum Bild ohne Padding durchgeführt werden, denn die Position der Kacheln ist auf das Bild ohne Padding bezogen.
    % Die Kx und Ky im linken und oberen Padding sind jetzt 0 und damit ungültig. Da sich im Padding aber keine Merkmale befinden, werden diese nie abgerufen und können ignoriert werden.
    Ky = ceil((iy - min_dist) ./ tile_size(1));
    Kx = ceil((ix - min_dist) ./ tile_size(2));
    % Vektor für Indizierung bei der Maskierung mit Cake im Voraus berechnen
    min_dist_range = -min_dist:min_dist;
    % Iterator für gefundene Merkmale
    it_merkmale = 1;
    % for each in corners_sorted
    for it = 1:length(corners_sorted)
        % Wenn das Merkmal nicht vorhanden ist, wurde es bereits ausmaskiert und ist damit ungültig -> überspringen
        if ~min_dist_mask(iy(it), ix(it))
            continue;
        else
            % Bereich um Merkmal ausmaskieren
            n = iy(it) + min_dist_range;
            m = ix(it) + min_dist_range;
            min_dist_mask(n, m) = min_dist_mask(n, m) & Cake;
        end
        % In der Kachel um das Merkmal wurden schon N stärkere Merkmale gefunden -> überspringen
        if AKKA(Ky(it), Kx(it)) >= N
            continue;
        else
            % Akkumulator inkrementieren und Merkmal aufnehmen
            AKKA(Ky(it), Kx(it)) = AKKA(Ky(it), Kx(it)) + 1;
            merkmale(:, it_merkmale) = [ix(it); iy(it)];
            it_merkmale = it_merkmale + 1;
        end
    end
    % Indexverschiebung vom Bild mit Padding zum Bild ohne Padding
    merkmale = merkmale - min_dist;
    % Ausgabematrix auf tatsächliche Anzahl von gefundenen Merkmalen zuschneiden
    merkmale(:, it_merkmale:end) = [];

    %% Plot
    if do_plot
        figure('name', 'Merkmale');
        imshow(input_image);
        hold on;
        plot(merkmale(1,:), merkmale(2, :), 'or');
        hold off;
        legend('Detektierte Ecken');
    end
end
