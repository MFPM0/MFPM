function Source = build_source(ang_deg, na_illum, na_inner, lambda, numRot, Fx, Fy)
    % half-circle source pattern for a given illumination direction
    Source = zeros(length(Fx), length(Fy), numRot);
    
    R = sqrt(Fx.^2 + Fy.^2) * lambda;
    S0 = (R <= na_illum) & (R >= na_inner * na_illum);

    for i = 1 : length(ang_deg)
        mask = zeros(size(Fx));
        if ang_deg(i) < 180 || ang_deg(i) == 270 
            mask(Fy>=(Fx*tand(ang_deg(i)))) = 1;
        else
            mask(Fy<=(Fx*tand(ang_deg(i)))) = 1;    
        end
        Source(:,:,i) = S0 .* mask;
    end   
end