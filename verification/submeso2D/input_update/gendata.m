% Script that generates initial condition files

% Define vertical grid: uniform dz=1m for a depth of 100m
dzL=4;
kL=100;
dz=ones(1,kL)*dzL; nz=size(dz,2);
zF=[0 -cumsum(dz)]; zC=(zF(1:nz)+zF(2:nz+1))/2;

% Define horizontal grid: uniform dy=100m for a length of 100km (ny=1000 points)
dy=100; ny=1000;
yF=[0:ny]-ny/2; yF=yF*dy; yC=(yF(1:ny)+yF(2:ny+1))/2;
dx=100; nx=1;
xF=[0:nx]; xF=xF*dx; xC=(xF(1:nx)+xF(2:nx+1))/2;

% Set parameters
alphaT = 2.e-4;
gravity = 9.81;
rho0 = 1000;
fo = 1.e-4;
N2 = 0.4e-5;
M2 = -5e-8;

W = 40000;  % distance of the two fronts (in meters)
Ly = (W/2);   % half width (in meters)
yM=0;   % center of the two fronts
Ho=400; % depth (in meters)
A = 5; % vertical decay factor (non-dimensional)

T_MLD = 16; % temperature at MLD is fixed
kmx = 30;   % level of depth of ML
D = 10000;  % scaling factor in tanh and amplitude of tanh in temperature

% Define background temperature

% Using N2 = db/dz = g alphaT dT/dz
dTdz = N2/gravity/alphaT;
% Using M2 = db/dy = g alphaT dT/dy
dTdy = M2/gravity/alphaT;

T_surf = (zC(1)-zC(kmx))*dTdz+T_MLD;

T = zeros(nx,ny,nz);
for i=1:nx
for k=1:nz
    T(i,:,k) = T_surf + dTdz*(zC(k)) ...
        +2*D*dTdy*((tanh((yC(1,:)-yM-Ly)/D)-tanh((yC(1,:)-yM+Ly)/D))/2) ...
        *exp(-A*(zC(k)/Ho)^(2));
end
end

% Create a ML with weak stratification
N2ML=1.e-12;
dTdzML=N2ML/gravity/alphaT;
TML=T(:,:,kmx);
for i=1:nx
for k=kmx-1:-1:1
    T(i,:,k) = TML(i,:)+(kmx-k)*dzL*dTdzML;
end
end

% Thermal wind
dbdy=zeros(nx,ny+1,nz);
dbdy(:,2:ny,:)=gravity*alphaT*(T(:,[2:ny],:)-T(:,[1:ny-1],:))/dy;
ug=zeros(nx,ny+1,nz+1);
for i=1:nx
for k=nz:-1:1
 ug(i,:,k) = ug(i,:,k+1) - dbdy(i,:,k)*dz(k)/fo ;
end
end
uCg=ug(:,[1:ny],[1:nz])+ug(:,[2:ny+1],[2:nz+1])  ...
   +ug(:,[2:ny+1],[1:nz])+ug(:,[1:ny],[2:nz+1]);
uCg=uCg/4;

rng(2);
T=T+0.001*rand(nx,ny,nz);

%% Passive tracers

zC0 = zC(1);
yC0 = yC(ny/2);

for i=1:nx
for j=1:ny
for k=1:nz

      % pt24 — Linear increase with depth
      pt24(i,j,k) = zC(k);

      % pt25 — tanh transition centered near z = –100
      pt25(i,j,k) = tanh(0.01 * (zC(k) + 100));

      % pt34 — Vertical Gaussian, constant along mid-y
      pt34(i,j,k) = exp(-((zC(k)+100)/80)^2);

      % pt35 — Meridional cosine pattern, decaying with depth
      pt35(i,j,k) = cos(pi*(yC(j)-yC0)/100000) .* exp(zC(k)/150);

      % pt37 — Mixed y–z Gaussian ridge
      pt37(i,j,k) = exp(-((yC(j)-yC0)/40000)^2 - ((zC(k)+80)/60)^2);

end
end
end

% Shift and normalize passive tracers

pt24 = pt24 - pt24(1,1,end);
pt24 = pt24 * (nx*ny*nz) / sum(pt24,'all');

pt25 = pt25 - pt25(1,1,1);
pt25 = pt25 * (nx*ny*nz) / sum(pt25,'all');

pt34 = pt34 - min(pt34, [], 'all');
pt34 = pt34 * (nx*ny*nz) / sum(pt34,'all');

pt35 = pt35 - min(pt35, [], 'all');
pt35 = pt35 * (nx*ny*nz) / sum(pt35,'all');

pt37 = pt37 - min(pt37, [], 'all');
pt37 = pt37 * (nx*ny*nz) / sum(pt37,'all');


%%
% Plot to check

figure(1);clf;
subplot(211);
var=squeeze(T(1,:,:)); var(find(var==0))=NaN;
[cs,h]=contour(yC,zC,var',30);
grid
title('Initial Condition');

subplot(223);
var=squeeze(T(1,1,:));
plot(var,zC,'b-');
hold on;
var=squeeze(T(1,ny/2,:));
plot(var,zC,'r-');
i1=ny/2-3; i2=1+ny-i1;
var=squeeze(T(1,i1,:));
plot(var,zC,'g-');
var=squeeze(T(1,i2,:));
plot(var,zC,'c-');
hold off;
grid;
title('Profile at left boundary and center');

subplot(224);
var=squeeze(uCg(1,:,:));
[cs,h]=contour(yC(1:ny),zC,var',20);clabel(cs);
grid
title('u ini');

%%

figure(2); clf;
tracers = {'pt24','pt25','pt34','pt35','pt37'};

for n = 1:length(tracers)
    tracer_name = tracers{n};
    tracer_data = eval([tracer_name '(1,:,:)']);
    tracer_data = squeeze(tracer_data);

    subplot(2,3,n) 
    contourf(yC/1000, zC, tracer_data', 20, 'LineColor', 'none');
    colorbar
    title(tracer_name)
    xlabel('y [km]')
    ylabel('z [m]')
    set(gca,'YDir','normal')
end

sgtitle('Passive tracers (y–z slice at x=1)')
colormap(turbo)

%%
% Save variables in .bin files

H=zF(end)*ones(nx,ny);
H(:,1)=0; H(:,ny)=0;

fid=fopen('topog.bin','w','b'); fwrite(fid,H,'real*8'); fclose(fid);
fid=fopen('t_ini.bin','w','b'); fwrite(fid,T,'real*8'); fclose(fid);
fid=fopen('u_ini.bin','w','b'); fwrite(fid,uCg,'real*8'); fclose(fid);
fid=fopen('pt24.bin','w','b'); fwrite(fid,pt24,'real*8'); fclose(fid);
fid=fopen('pt25.bin','w','b'); fwrite(fid,pt25,'real*8'); fclose(fid);
fid=fopen('pt34.bin','w','b'); fwrite(fid,pt34,'real*8'); fclose(fid);
fid=fopen('pt35.bin','w','b'); fwrite(fid,pt35,'real*8'); fclose(fid);
fid=fopen('pt37.bin','w','b'); fwrite(fid,pt37,'real*8'); fclose(fid);

return
