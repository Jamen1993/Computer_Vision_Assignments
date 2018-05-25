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

    function Mpt = remove_outer_Mpts(Mpt)
        % Merkmalspunkte, die die oben genannte Bedingung verletzen, entfernen

        % Zuerst erstelle ich eine Matrix, die für jeden Merkmalspunkt zeigt, welcher der beiden Pixelindizes die oben genannte Bedingung verletzt.
        condition = Mpt <= r | Mpt >= s - r + 1;
        % Dann fasse ich die beiden Zeilenvektoren zusammen, denn ein Merkmalspunkt wird dann entfernt, wenn x ODER y die Bedingung verletzen
        mask = condition(1, :) | condition(2, :);
        % Merkmalspunkte, die die oben genannte Bedingung verletzen, entfernen
        Mpt(:, mask) = [];
    end

    % Funktion auf Merkmalspunkte aus beiden Bildern anwenden
    Mpt1 = remove_outer_Mpts(Mpt1);
    Mpt2 = remove_outer_Mpts(Mpt2);

    %% Normierung
    % An dieser Stelle wird die oben erwähnte Fensterung durchgeführt. Damit die NCC richtig auf den Bildausschnitt angewandt werden kann, müssen alle Bildausschnitte bezüglich Helligkeit und Kontrast normalisiert werden. Nur so ist ein Vergleich überhaupt möglich.

    % Indexverschiebung für Fensterung -> diese Elemente müssen, ausgehend vom Merkmal in der Mitte des Fensters, entnommen werden.
    iw = -r:r;

    function Mat_feat = normalised_feature_matrix(Im, Mpt)
        % Merkmalspunkte fenstern, Fenster normalisieren, vektorisieren und spaltenweise als Matrix angeordnet zurückgeben

        % In dieser Matrix werden die vektorisierten, normalisierten Fenster pro Merkmalspunkt spaltenweise gespeichert.
        Mat_feat = zeros(window_length ^ 2, length(Mpt));

        % for each Merkmalspunkt
        for it = 1:length(Mpt)
            % Indizes für Fensterung berechnen
            ix = iw + Mpt(1, it);
            iy = iw + Mpt(2, it);
            % Fenster um Merkmalspunkt holen und für einfachere Verarbeitung vektorisieren
            w = Im(iy, ix);
            w = w(:);
            % Fenster mit Mittelwert und Standardabweichung entsprechend Kontrast und Helligkeit normalisieren
            wn = (w - mean(w)) ./ std(w);
            % In Ergebnismatrix ablegen
            Mat_feat(:, it) = wn;
        end
    end

    % Funktion auf Merkmalspunkte aus beiden Bildern anwenden
    Mat_feat_1 = normalised_feature_matrix(Im1, Mpt1);
    Mat_feat_2 = normalised_feature_matrix(Im2, Mpt2);

    Korrespondenzen = {Mat_feat_1, Mat_feat_2};
end
