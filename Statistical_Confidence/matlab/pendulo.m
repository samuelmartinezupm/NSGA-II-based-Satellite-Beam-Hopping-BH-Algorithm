function deriv = pendulo(t,estado)
    m = 5000; % gramos
    g = 980;  % centimetros por segundo al cuadrado
    l = 500; % centimetros

    deriv = zeros(2,1);
    
    deriv(1) = estado(2);
    deriv(2) = - m * g / l * sin(estado(1));
end