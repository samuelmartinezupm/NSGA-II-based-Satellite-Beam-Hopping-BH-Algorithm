function deriv = foucault (t, estado)

    vang = 2*pi/86400;
    lat = 40;
    radio = 6300000;
    grav = [0 0 -9.8]';
    
    centrifuga = vang^2 * radio * cos(lat) * [cos(lat) 0 -sin(lat)]';
    
    omega = vang * [cos(lat) 0 sin(lat)]';
    deriv = zeros(6,1);
    
    pos = estado(1:3);
    vel = estado(4:6);
    
    deriv(1:3) = vel;
    deriv(4:6) = grav - 2 * cross(omega, vel) - cross (omega, cross(pos,omega)) - centrifuga;
    
end