function d = EMD(P, Q)

% Earth Mover's Distance

if size(P, 2) ~= size(Q, 2)
    error('the number of columns in P and Q should be the same');
end

if sum(~isfinite(P(:))) + sum(~isfinite(Q(:)))
    error('the inputs contain non-finite values!')
end

if size(P, 1) ~= size(Q, 1)
    error('the number of rows in P and Q should be the same');
    
elseif size(P, 1) == size(Q, 1)
    
    [m, n] = size(P);
    
    d = zeros(m, 1);
    
    A1 = zeros(n, n * n);
    A2 = zeros(n, n * n);
    for i = 1:n
        for j = 1:n
            k = i + (j - 1) * n;
            A1(i, k) = 1;
            A2(j, k) = 1;
        end
    end
    A = [A1; A2];
    
    lb = zeros(1, n * n);
    
    for k = 1:m
        p = P(k, :)';
        q = Q(k, :)';
        
        b = [p;q];
        
        D = zeros(n, n);
        for i = 1:n
            for j = 1:n
                D(i, j) = abs(p(i) - q(j));
            end
        end
        D = D(:);
        
        opt = optimset('Display', 'off');
        [~, fval] = linprog(D, [], [], A, b, lb, [], opt);
        
        d(k) = fval;
    end
    
end

end