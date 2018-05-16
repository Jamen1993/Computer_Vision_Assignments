function Cake = cake(min_dist)
    % Die Funktion cake erstellt eine "Kuchenmatrix", die eine kreisförmige
    % Anordnung von Nullen beinhaltet und den Rest der Matrix mit Einsen
    % auffüllt. Damit können, ausgehend vom stärksten Merkmal, andere Punkte
    % unterdrückt werden, die den Mindestabstand hierzu nicht einhalten.

    % Matrix generieren in der jedes Element seinen Abstand vom Mittelpunkt entsprechend euklidischer Norm repräsentiert.
    index = -min_dist:min_dist;
    [X, Y] = meshgrid(index);
    % Hier wird auf die Wurzel verzichtet und stattdessen das Quadrat der euklidischen Norm berechnet. Das muss später berücksichtigt werden, indem auch min_dist quadriert wird.
    distances = X .^ 2 + Y .^ 2;
    % Elemente mit Abstand kleiner gleich min_dist zu Null setzen
    Cake = true(min_dist * 2 + 1);
    Cake(distances <= min_dist ^ 2) = false;
end
