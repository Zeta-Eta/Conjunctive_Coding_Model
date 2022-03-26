function coort = sqns2coord(sequence)

    original = pi./6;
    
    gaps = pi./3;
    angelSequence = original + gaps*(sequence-1);
    x_coor = sin(angelSequence);
    y_coor = cos(angelSequence);
    coort = [x_coor;y_coor];
end