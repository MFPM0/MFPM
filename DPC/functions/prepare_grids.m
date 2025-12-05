function [grid, dim] = prepare_grids(ny, nx, pixel_size)

    % x,y coordinates (real space)
    rx = -(nx-mod(nx,2))/2 : 1 : (nx-mod(nx,2))/2 - (mod(nx,2)==0);
    ry = -(ny-mod(ny,2))/2 : 1 : (ny-mod(ny,2))/2 - (mod(ny,2)==0);
    rx = rx * pixel_size;
    ry = ry * pixel_size;
    
    % frequency axes
    dfx = 1 / (nx * pixel_size); dfy = 1 / (ny * pixel_size);
    fx = -(nx-mod(nx,2))/2 : 1 : (nx-mod(nx,2))/2 - (mod(nx,2)==0);
    fy = -(ny-mod(ny,2))/2 : 1 : (ny-mod(ny,2))/2 - (mod(ny,2)==0);
    fx = dfx * fx; fy = dfy * fy;
    fx = ifftshift(fx); fy = ifftshift(fy);
    [grid.Fx, grid.Fy] = meshgrid(fx, fy);
end