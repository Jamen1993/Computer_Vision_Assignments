function merkmale = harris_detektor_E(input_image, varargin)
    % In dieser Funktion soll der Harris-Detektor implementiert werden, der
    % Merkmalspunkte aus dem Bild extrahiert

    %% Input parser
    % input_image + 7 name value pairs = 15 Parameter
    if nargin > 9
        error("Zu viele Parameter");
    end

    % Parameter entsprechend Beschreibung parsen; Standardwerte setzen und prüfen.
    p = inputParser;

    addParameter(p, 'segment_length', 15, @(x) assert(isnumeric(x) && isscalar(x) && mod(x,2) == 1 && x > 1, 'segment_length muss eine ungerade Ganzzahl größer 1 sein'));
    addParameter(p, 'k', 0.05, @(x) assert(isnumeric(x) && isscalar(x) && 0 <= x && x <= 1, 'k muss eine Reelle Zahl im Intervall [0; 1] sein.'));
    addParameter(p, 'tau', 1e6, @(x) assert(isnumeric(x) && isscalar(x) && x > 0, 'tau muss eine Reelle Zahl größer 0 sein'));
    addParameter(p, 'do_plot', false, @(x) assert(islogical(x), 'k muss ein logical sein.'));
    addParameter(p, 'min_dist', 20, @(x) assert(isnumeric(x) && x >= 1, 'min_dist muss eine Reelle Zahl größer gleich 1 sein.'));
    addParameter(p, 'tile_size', 200, @(x) assert(isnumeric(x) && prod(x >= 1) == 1 , 'min_dist muss eine Ganzzahl größer gleich 1 sein.'));
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

    merkmale = {min_dist, tile_size, N};
end
