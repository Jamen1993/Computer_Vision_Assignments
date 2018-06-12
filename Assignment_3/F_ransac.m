function [Korrespondenzen_robust] = F_ransac(Korrespondenzen, varargin)
    % Diese Funktion implementiert den RANSAC-Algorithmus zur Bestimmung von robusten Korrespondenzpunktpaaren.
    %
    % Korrespondenzen - Matrix in der spaltenweise die Pixelkoordinaten von Korrespondenzpunktpaaren in der Form [x1; y1; x2; y2] abgelegt sind
    %
    % 'epsilon' - (numerisch, (0, 1) ) geschätzte Wahrscheinlichkeit, dass ein zufällig gewähltes Korrespondenzpunktpaar ein Ausreißer ist (Standardwert = 0.5)
    % 'p' - (numerisch, (0, 1) ) gewünschte Wahrscheinlichkeit, dass der Algorithmus einen Satz Korrespondenzpunktpaare liefert, in dem sich kein Ausreißer befindet (Standardwert = 0.5)
    % 'tolerance' - (numerisch, > 0) Toleranz mit der ein Korrespondenzpaar als zum Modell passend (Teil des Consensus-Sets) bewertet wird (Standardwert 0.01)

    %% Input Parser
    % Korrespondenzen + 3 name value pairs = 7 Parameter
    assert(nargin <= 7, 'Zu viele Parameter');

    % Parameter entsprechend Beschreibung parsen, prüfen und Standardwerte setzen
    ip = inputParser;

    addParameter(ip, 'epsilon', 0.5, @(x) assert(isnumeric(x) && 0 < x && x < 1, 'epsilon muss eine reelle Zahl im Intervall (0, 1) sein'));
    addParameter(ip, 'p', 0.5, @(x) assert(isnumeric(x) && 0 < x && x < 1, 'p muss eine Reelle Zahl im Intervall (0, 1) sein'));
    addParameter(ip, 'tolerance', 0.01, @(x) assert(isnumeric(x) && 0 < x, 'tolerance muss eine reelle Zahl größer 0 sein'));

    parse(ip, varargin{:});

    % Parameter umbennenen für einfachere Nutzung
    epsilon = ip.Results.epsilon;
    tolerance = ip.Results.tolerance;
    p = ip.Results.p;

    % Pixelkoordinaten aus Korrespondenzen extrahieren und in homogene Darstellung umwandeln
    fh = @(x) [x; ones(1, length(x))];

    x1_pixel = fh(Korrespondenzen(1:2, :));
    x2_pixel = fh(Korrespondenzen(3:4, :));

    %% RanSaC Algorithmus Vorbereitung
    % Anzahl der Punktpaare, die gefunden werden sollen
    k = 8;
    % Iterationszahl
    s = log(1 - p) / log(1 - (1 - epsilon) ^ k);
    % Anzahl der Korresponzenzen im größten bisher gefundenen Consensus-Set (largest_set)
    largest_set_size = 0;
    % Sampson-Distanz von largest_set
    largest_set_dist = Inf;
    % Fundamentalmatrix für die das largest_set gefunden wurde
    largest_set_F = zeros(3);
    % Indizes des größten Konsensus-Sets
    largest_set = [];

    %% RanSaC Algorithmus Durchführung
    for it = 1:s
        % 1. Fundamentalmatrix mit Achtpunktalgorithmus und k zufällig ausgesuchten Korrespondenzpunktpaaren schätzen
        ind_rand = randperm(length(Korrespondenzen), k);
        F = achtpunktalgorithmus(Korrespondenzen(:, ind_rand));
        % 2. Sampson-Distanz für alle Korrespondenzpunktpaare bezogen auf die geschätzte Fundamentalmatrix berechnen
        sd = sampson_dist(F, x1_pixel, x2_pixel);
        % 3. Geeignete Korrespondenzpunktpaare entsprechend tolerance auswählen und ins aktuelle Consensus-Set aufnehmen
        % Ich arbeite hier nur mit den Indizes, damit ich nicht dauernd große Arrays kopieren muss
        consensus_set = find(sd < tolerance);
        % 4. Für das Consensus-Set die Anzahl der Paare und die absolute Set-Distanz als Summe über die Sampson-Distanzen des Sets ermitteln.
        set_size = length(consensus_set);
        set_dist = sum(sd(consensus_set));
        % 5. & 6. Das Consensus-Set mit dem größten (bezüglich Anzahl der Paare) bisher gefundenen vergleichen: Ist das aktuelle größer, wird dieses übernommen; sind beide gleich groß, wird das mit der kleineren absoluten Set-Distanz übernommen; ansonsten ändert sich nichts.
        if set_size > largest_set_size || set_size == largest_set_size && set_dist < largest_set_dist
            largest_set = consensus_set;
            largest_set_size = set_size;
            largest_set_dist = set_dist;
            largest_set_F = F;
        end
    end
    % Korrespondenzpunktpaare des besten Consensus-Sets auswählen
    Korrespondenzen_robust = {Korrespondenzen(:, largest_set), largest_set_F};
end
