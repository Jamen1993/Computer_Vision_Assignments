function Korrespondenzen = punkt_korrespondenzen(I1, I2, Mpt1, Mpt2, varargin)
    % In dieser Funktion sollen die extrahierten Merkmalspunkte aus einer
    % Stereo-Aufnahme mittels NCC verglichen werden um Korrespondenzpunktpaare
    % zu ermitteln.
    %
    % I1 - Erstes Bild der Szene in Graustufendarstellung
    % I2 - Zweites Bild der Szene in Graustufendarstellung
    % Mpt1 - Pixelkoordinaten [x; y] der Merkmalspunkte in I1
    % Mpt2 - Pixelkoordinaten [x; y] der Merkmalspunkte in I2
    %
    % 'window_length' - (numerisch, ungerade, > 1) Seitenlänge des quadratischen Fensters um die Merkmalspunkte, die untereinander verglichen werden (Standardwert = 25)
    % 'min_corr' - (numerisch, (0; 1)) Unterer Schwellwert für die Stärke der Korrelation zweier Merkmale (Standardwert = 0.95)
    % 'do_plot' - (logical) bestimmt, ob das Bild angezeigt wird oder nicht (Standardwert = false)

    %% Input parser
    % I1, I2, Mpt1, Mpt2 + 3 name value pairs = 10 Parameter
    assert(nargin <= 10, 'Zu viele Parameter');

    % Parameter entsprechend Beschreibung parsen; Standardwerte setzen und prüfen
    p = inputParser;

    addParameter(p, 'window_length', 25, @(x) assert(isnumeric(x) && mod(x, 2) == 1 && x > 1, 'window_length muss eine ungerade Ganzzahl größer 1 sein'));
    addParameter(p, 'min_corr', 0.95, @(x) assert(isnumeric(x) && 0 < x && x < 1, 'min_corr muss eine reelle Zahl im Intervall (0; 1) sein'));
    addParameter(p, 'do_plot', false, @(x) assert(islogical(x), 'do_plot'));

    parse(p, varargin{:});

    % Parameter umbennen für einfachere Nutzung
    window_length = p.Results.window_length;
    min_corr = p.Results.min_corr;
    do_plot = p.Results.do_plot;

    % Graustufenbilder für numerische Verarbeitung in Fließkommazahl konvertieren
    Im1 = double(I1);
    Im2 = double(I2);

    Korrespondenzen = {window_length, min_corr, do_plot, Im1, Im2};
end
