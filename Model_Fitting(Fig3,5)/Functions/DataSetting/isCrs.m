function f = isCrs(A, B)

A = [A; 0, 0];
B = [B; 0, 0];

A1 = A(:, 1);
A2 = A(:, 2);
B1 = B(:, 1);
B2 = B(:, 2);

A1A2 = A2 - A1;
A1B1 = B1 - A1;
A1B2 = B2 - A1;

fA = cross(A1A2, A1B1)' * cross(A1A2, A1B2) < 0;

B1B2 = B2 - B1;
B1A1 = A1 - B1;
B1A2 = A2 - B1;

fB = cross(B1B2, B1A1)' * cross(B1B2, B1A2) < 0;

f = fA && fB;
end

