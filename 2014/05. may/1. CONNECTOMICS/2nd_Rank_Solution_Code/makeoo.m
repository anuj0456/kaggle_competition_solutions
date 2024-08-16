
%%%%%%%%%%%%%%%%%%%%%%%%%%%%normal-1

load orgn1

% set simulation metadata
V.dt    = 1/40;  % time step size

% initialize params
P.a     = 1;    % observation scale
P.b     = 0;    % observation bias
tau     = 1.5;%2; %1.5;    % decay time constant
P.gam   = 1-V.dt/tau; % C(t) = gam*C(t-1)
P.lam   = 0.1;  % firing rate = lam*dt
P.sig   = 0.1;  % standard deviation of observation noise 

% fast oopsi
V.T=size(org,1)
F=org(:,1);
[N P] = fast_oopsi(F,V,P);

ret=org;
N=size(org,2);

for j=1:N
    F=org(:,j);
    [Nhat Phat]= fast_oopsi(F,V,P);
    ret(:,j)= Nhat;
    disp(j)
end

csvwrite('diff2n1a40b15csv.csv',ret)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%normal-2

load orgn2

% set simulation metadata
V.dt    = 1/40;  % time step size

% initialize params
P.a     = 1;    % observation scale
P.b     = 0;    % observation bias
tau     = 1.5;%2; %1.5;    % decay time constant
P.gam   = 1-V.dt/tau; % C(t) = gam*C(t-1)
P.lam   = 0.1;  % firing rate = lam*dt
P.sig   = 0.1;  % standard deviation of observation noise 

% fast oopsi
V.T=size(org,1)
F=org(:,1);
[N P] = fast_oopsi(F,V,P);

ret=org;
N=size(org,2);

for j=1:N
    F=org(:,j);
    [Nhat Phat]= fast_oopsi(F,V,P);
    ret(:,j)= Nhat;
    disp(j)
end

csvwrite('diff2n2a40b15csv.csv',ret)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%valid

load orgvalid

% set simulation metadata
V.dt    = 1/40;  % time step size

% initialize params
P.a     = 1;    % observation scale
P.b     = 0;    % observation bias
tau     = 1.5;%2; %1.5;    % decay time constant
P.gam   = 1-V.dt/tau; % C(t) = gam*C(t-1)
P.lam   = 0.1;  % firing rate = lam*dt
P.sig   = 0.1;  % standard deviation of observation noise 

% fast oopsi
V.T=size(org,1)
F=org(:,1);
[N P] = fast_oopsi(F,V,P);

ret=org;
N=size(org,2);

for j=1:N
    F=org(:,j);
    [Nhat Phat]= fast_oopsi(F,V,P);
    ret(:,j)= Nhat;
    disp(j)
end

csvwrite('diff2valida40b15csv.csv',ret)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%test

load orgtest

% set simulation metadata
V.dt    = 1/40;  % time step size

% initialize params
P.a     = 1;    % observation scale
P.b     = 0;    % observation bias
tau     = 1.5;%2; %1.5;    % decay time constant
P.gam   = 1-V.dt/tau; % C(t) = gam*C(t-1)
P.lam   = 0.1;  % firing rate = lam*dt
P.sig   = 0.1;  % standard deviation of observation noise 

% fast oopsi
V.T=size(org,1)
F=org(:,1);
[N P] = fast_oopsi(F,V,P);

ret=org;
N=size(org,2);

for j=1:N
    F=org(:,j);
    [Nhat Phat]= fast_oopsi(F,V,P);
    ret(:,j)= Nhat;
    disp(j)
end

csvwrite('diff2testa40b15csv.csv',ret)
