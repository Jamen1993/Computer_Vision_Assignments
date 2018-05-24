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

    %% Merkmalsvorbereitung
    % Für die Berechnung der NCC werden Fenster um die Merkmalspunkte gelegt. Punkte die näher als die halbe Breite des Fensters am Rand des Bildes liegen können nicht richtig gefenstert werden, da das Fenster über den Bildrand hinausstehen würde, wo keine gültigen Pixel existieren. Davon betroffene Merkmalspunkte werden daher entfernt.

    % Breite des Rands
    r = floor(window_length / 2);
    % Größe des Bilds
    % Da die Merkmalspunkte in der Form [x; y] übergeben werden, muss ich die Größe des Bilds aus der Darstellung [y, x] in die Form [x; y] umwandeln.
    s = flip(size(Im1))';

    % Merkmalspunkte, die die oben genannte Bedingung verletzen, entfernen
    function [Mpt, no_pts] = remove_outer_Mpts(Mpt)
        % Zuerst erstelle ich eine Matrix, die für jeden Merkmalspunkt zeigt, welcher der beiden Pixelindizes die oben genannte Bedingung verletzt.
        condition = Mpt <= r | Mpt >= s - r + 1;
        % Dann fasse ich die beiden Zeilenvektoren zusammen, denn ein Merkmalspunkt wird dann entfernt, wenn x ODER y die Bedingung verletzen
        mask = condition(1, :) | condition(2, :);
        % Merkmalspunkte, die die oben genannte Bedingung verletzen, entfernen
        Mpt(:, mask) = [];
        % Anzahl der verbliebenen Merkmalspunkte bestimmen
        no_pts = length(Mpt);
    end

    [Mpt1, no_pts1] = remove_outer_Mpts(Mpt1);
    [Mpt2, no_pts2] = remove_outer_Mpts(Mpt2);

    Korrespondenzen = {no_pts1, no_pts2, Mpt1, Mpt2};
end
