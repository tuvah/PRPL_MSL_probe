function coord = init_coord
%% Define the position (R,Z) of the conducting components

%% Stabilization coils
d = 3.33e-3; % Wire radius

sc_I = 1e3; % Current scaling [kA]
sc_B = 1e3; % Magnetic field scaling [mT]

% Vertical stabilization
VertStab.R_base = [0.210; 0.210; 0.650; 0.650]; 
VertStab.Z_base = [0.280; -0.280; 0.233; -0.257];
VertStab.Id = [-1; 1; -1; 1];


VertStab.Nc = numel(VertStab.Id); % Number of coil
VertStab.Nl = 8; % Number of loops per coil

VertStab.sc_I = sc_I; VertStab.sc_B = sc_B;
if VertStab.Nl > 1 && mod(VertStab.Nl, 2) == 0
    n = VertStab.Nl/2;
    VertStab.R = cell2mat(arrayfun(@(x)  repmat(linspace(x - n*d, x + n*d, n),1,2) ,VertStab.R_base' ,'UniformOutput' ,false));
    VertStab.Z = cell2mat(arrayfun(@(x)  [repmat(x,1,n), repmat(x,1,n)+1.5*d] ,VertStab.Z_base' ,'UniformOutput' ,false));
    VertStab.Id = cell2mat(arrayfun(@(x)  repmat(x,1, n*2) ,VertStab.Id' ,'UniformOutput' ,false));
else    
    VertStab.R = VertStab.R_base; 
    VertStab.Z = VertStab.Z_base; 
end    


% Horizontal stabilization
HorStab.R_base = [0.270; 0.270; 0.650; 0.650]; 
HorStab.Z_base = [0.280; -0.280; 0.257; -0.233]; 
HorStab.Id = [-1; -1; 1; 1];

HorStab.Nc = numel(HorStab.Id);
HorStab.Nl = 8;

HorStab.sc_I = sc_I; HorStab.sc_B = sc_B;
if HorStab.Nl > 1 && mod(HorStab.Nl, 2) == 0
    n = HorStab.Nl/2;
    HorStab.R = cell2mat(arrayfun(@(x)  repmat(linspace(x - n*d, x + n*d, n),1,2), HorStab.R_base' ,'UniformOutput' ,false));
    HorStab.Z = cell2mat(arrayfun(@(x)  [repmat(x,1,n), repmat(x,1,n)+1.5*d] ,HorStab.Z_base' ,'UniformOutput' ,false));
    HorStab.Id = cell2mat(arrayfun(@(x)  repmat(x,1, n*2) ,HorStab.Id' ,'UniformOutput' ,false));
else    
    HorStab.R = HorStab.R_base; 
    HorStab.Z = HorStab.Z_base; 
end    

% Inner quadrupole
InnerQuadr.Nc = 4;
InnerQuadr.Nl = 1;
InnerQuadr.Id = [-1; -1; 1; 1];
InnerQuadr.sc_I = sc_I; InnerQuadr.sc_B = sc_B;
InnerQuadr.R = [0.3173; 0.3173; 0.4827; 0.4827];
InnerQuadr.Z = [0.0827; -0.0827; 0.0827; -0.0827];

%% Transformer iron core
IronCore.Z = [-0.3, 0.3];
IronCore.R = 0.15;

%% Copper shell
CopperShell.minor_radius = 0.13; % [m]
CopperShell.major_radius = 0.4; % [m]
CopperShell.thickness  = 0.01; % [m]
CopperShell.N = 100; % This should ultimately corresponds to the number of elements used for numerical purposes.
CopperShell.R = arrayfun(@(phi) (CopperShell.major_radius + CopperShell.minor_radius * cos(phi)), linspace(0, 2*pi, CopperShell.N));
CopperShell.Z = arrayfun(@(phi) (CopperShell.minor_radius * sin(phi)), linspace(0, 2*pi, CopperShell.N));

%% Tokamak's vessel
Vessel.minor_radius = 0.1; % [m]
Vessel.major_radius = 0.4; % [m]
Vessel.Nc  = 1e2;           % number of segments (=coils)
Vessel.Nl  = 1;             % number of loops per coil(segment)
Vessel.R  = arrayfun(@(phi) (Vessel.major_radius + Vessel.minor_radius * cos(phi)), linspace(0,2*pi,Vessel.Nc));
Vessel.Z  = arrayfun(@(phi) (Vessel.minor_radius * sin(phi)), linspace(0,2*pi,Vessel.Nc));
Vessel.Id = ones(1, Vessel.Nc); % the currents flowing in the segments have the same direction, which is determined by the direction of Et

% Et~1/R; I_i = 1/R_i*I_tot/sum_j(1/R_j); R..radial coordinate
R_m1_sum = sum(1./Vessel.R); % sum(R^{-1})
for i_R = 1:numel(Vessel.R)
    R_i = Vessel.R(i_R);
    Vessel.Id(i_R) = 1/R_i*1/R_m1_sum;
end

Vessel.sc_I = sc_I; Vessel.sc_B = sc_B;

%% Store all the coordinates in a structure 
coord = struct( ...
    'VertStab', VertStab, ...
    'HorStab', HorStab, ...
    'InnerQuadr', InnerQuadr, ...
    'IronCore', IronCore, ...
    'CopperShell', CopperShell, ...
    'Vessel', Vessel...
    );
end