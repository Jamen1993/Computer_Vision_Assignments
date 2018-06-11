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
    p = inputParser;

    addParameter(p, 'epsilon', 0.5, @(x) assert(isnumeric(x) && 0 < x && x < 1, 'epsilon muss eine reelle Zahl im Intervall (0, 1) sein'));
    addParameter(p, 'p', 0.5, @(x) assert(isnumeric(x) && 0 < x && x < 1, 'p muss eine Reelle Zahl im Intervall (0, 1) sein'));
    addParameter(p, 'tolerance', 0.01, @(x) assert(isnumeric(x) && 0 < x, 'tolerance muss eine reelle Zahl größer 0 sein'));

    parse(p, varargin{:});

    % Parameter umbennenen für einfachere Nutzung
    epsilon = p.Results.epsilon;
    tolerance = p.Results.tolerance;
    p = p.Results.p;

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
    % Fundamentalmatrix mit der das largest_set gefunden wurde
    largest_set_F = zeros(3);

    Korrespondenzen_robust = {k, s, largest_set_size, largest_set_dist, largest_set_F};
end
