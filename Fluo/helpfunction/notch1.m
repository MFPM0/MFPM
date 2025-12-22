function outimage = notch1(image,k2a)
[Nx,Ny] = size(image);
cenx = floor(Nx/2)+1 + k2a(2);
ceny = floor(Ny/2)+1 + k2a(1);
notchfilter = ones(Nx,Ny);
mm = 20;
for jx = 1:Nx
    for jy = 1:Ny
        distance = sqrt((jx-cenx)^2+(jy-ceny)^2);
        if distance < mm
            notchfilter(jx,jy) = 0.0025*distance^2;
        end
    end
end
outimage = notchfilter.*image;

end