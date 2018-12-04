function [ETA DATEN DATEX DAT MASSFLOW COMBUSTION] = GT(P_e,options,display)
% GT Gas turbine modelisation
% GT(P_e,options,display) compute the thermodynamics states for a Gas
% turbine based on several inputs (given in OPTION) and based on a given 
% electricity production P_e. It returns the main results. It can as well
% plots graphs if input argument DISPLAY = true (<=> DISPLAY=1)
%
% INPUTS (some inputs can be dependent on others => only one of these 2 can
%         be activated)
% P_E = electrical power output target [kW]
% OPTIONS is a structure containing :
%   -options.k_mec [-] : Shaft losses 
%   -options.T_0   [°C] : Reference temperature
%   -options.T_ext [°C] : External temperature
%   -options.r     [-] : Comperssion ratio
%   -options.k_cc  [-] : Coefficient of pressure losses due to combustion
%                        chamber
%   -options.T_3   [°C] : Temperature after combustion (before turbine)
%   -option.eta_PiC[-] : Intern polytropic efficiency (Rendement
%                        polytropique interne) for compression
%   -option.eta_PiT[-] : Intern polytropic efficiency (Rendement
%                        polytropique interne) for expansion
%DISPLAY = 1 or 0. If 1, then the code should plot graphics. If 0, then the
%          do not plot.
%
%OUPUTS : 
% ETA is a vector with :
%   -eta(1) : eta_cyclen, cycle energy efficiency
%   -eta(2) : eta_toten, overall energy efficiency
%   -eta(3) : eta_cyclex, cycle exegy efficiency
%   -eta(4) : eta_totex, overall exergie efficiency
%   -eta(5) : eta_rotex, compressor-turbine exergy efficiency
%   -eta(6) : eta_combex, Combustion exergy efficiency
%   FYI : eta(i) \in [0;1] [-]
% DATEN is a vector with : 
%   -daten(1) : perte_mec [kW]
%   -daten(2) : perte_ech [kW]
% DATEX is a vector with :
%   -datex(1) : perte_mec [kW]
%   -datex(2) : perte_rotex [kW]
%   -datex(3) : perte_combex [kW]
%   -datex(4) : perte_echex  [kW]
% DAT is a matrix containing :
% dat = {T_1       , T_2       , T_3       , T_4; [°C]
%        p_1       , p_2       , p_3       , p_4; [bar]
%        h_1       , h_2       , h_3       , h_4; [kJ/kg]
%        s_1       , s_2       , s_3       , s_4; [kJ/kg/K]
%        e_1       , e_2       , e_3       , e_4;};[kJ/kg]
% MASSFLOW is a vector containing : 
%   -massflow(1) = m_a, air massflow [kg/s]
%   -massflow(2) = m_c, combustible massflow [kg/s] 
%   -massflow(3) = m_f, exhaust gas massflow [kg/s]
% 
% COMBUSTION is a structure with :
%   -combustion.LHV    : the Lower Heat Value of the fuel [kJ/kg]
%   -combustion.e_c    : the combuistible exergie         [kJ/kg]
%   -combustion.lambda : the air excess                   [-]
%   -combustion.Cp_g   : heat capacity of exhaust gas at 400 K [kJ/kg/K]
%   -combustion.fum  : is a vector of the exhaust gas composition :
%       -fum(1) = m_O2f  : massflow of O2 in exhaust gas [kg/s]
%       -fum(2) = m_N2f  : massflow of N2 in exhaust gas [kg/s]
%       -fum(3) = m_CO2f : massflow of CO2 in exhaust gas [kg/s]
%       -fum(4) = m_H2Of : massflow of H2O in exhaust gas [kg/s] 
%
% FIG is a vector of all the figure you plot. Before each figure, define a
% figure environment such as:  
%  "FIG(1) = figure;
%  plot(x,y1);
%  [...]
%   FIG(2) = figure;
%  plot(x,y2);
%  [...]"
%  Your vector FIG will contain all the figure plot during the run of this
%  code (whatever the size of FIG).
%


%% Your Work

% Exemple of how to use 'nargin' to check your number of inputs
if nargin<3
    display=1;
   if nargin<2
       options=struct();
       if nargin<1
           P_e=100e3;%100MW
       end
   end
end


% Exemple of how to use (isfield' to check if an option has been given (or
% not)
if isfield(options,'T_0')
    T_0 = options.T_0;
else
    T_0 = 15;%C   
end

if isfield(options,'k_mec')
    k_mec = options.k_mec;
else
    k_mec = 0.98;   
end

if isfield(options,'T_ext')
    T_ext = options.T_ext;
else
    T_ext = 15;   %C
end

if isfield(options,'r')
    r = options.r;
else
    r = 10;   
end

if isfield(options,'k_cc')
    k_cc = options.k_cc;
else
    k_cc = 0.95;   
end


if isfield(options,'T_3')
    T_3 = options.T_3;
else
    T_3 = 1050;   %C
end


if isfield(options,'eta_PiC')
    eta_PiC = options.eta_PiC;
else
    eta_PiC = 0.9;   
end

if isfield(options,'eta_PiT')
    eta_PiT = options.eta_PiT;
else
    eta_PiT = 0.9;   
end


%%%%%%%%%%%%%%% OUTPUT %%%%%%%%%%%%%%%%%%%
ETA = zeros(6,1);

XMASSFLOW = zeros(nsout,1);

DATEN = zeros(2,1);

DATEX = zeros(4,1);

DAT= zeros(5,4);

MASSFLOW = zeros(3,1); %A MODIFIER
COMBUSTION = zeros(5,1); %A MODIFIER
fum = zeros(4,1);
combustion(5) = fum;

FIG = 0; %A MODIFIER

%%%%% Calcul des états %%%%%%
R_air = 287.1; %J/kg.K 
% %calcul point 1 : air atmosphérique

p_1 = 1,01325 ; %bar
T_1 = T_ext ;
Cp_air_27 = 1000*(0.79*janaf('c','N2',300)+0.21*janaf('c','O2',300)) ; %J/kg*K
h_1 = T_ext * Cp_air_27 ;
s_1 = Cp_air_27*log((T_ext+273.15)/273.15); %J/kg*K
e_1 = 0; % point de reference

%%calcul point 2 : apres la pompe

p_2 = r*p_1 ;
T_2 =  transf_poly('compression',T_ext,r,eta_PiC,R_air,0); %renvoie T en sortie de compresseur en C, pas besoin des compo fumee pour 1 compr
Cp_2 = 1000*(0.79*janaf('c','N2',T_2)+0.21*janaf('c','O2',T_2) ; %J/kg*K faire cp moyen entre T1 et T2 ?
h_2 = h_1 + Cp_2*(T_2-T_1);
s_2 = s_1 + ((1-eta_PiC)*Cp_2*log((T_2+273.15)/(T_1+273.15)); %eq 3.15
e_2 = (h_2-h_1) - 273.15*(s_2-s_1);

%%calcul point 3 : après la combustion

T_3 = T_3 ; % really ?
p_3 = p_2*k_cc; %pertes de charges dans chambre combustion


end
