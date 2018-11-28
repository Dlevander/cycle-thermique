%% Rankine Hirn reheat 1
optionsST.nsout = 0;   %  [-] : Number of feed-heating
optionsST.reheat  = 1; %  [-] : Number of reheating
optionsST.T_max = 560; %  [�C] : Maximum steam temperature
optionsST.T_cond_out = 33; %  [�C] : Condenseur cold outlet temperature
optionsST.p3_hp = 80;    %  [bar] : Maximum pressure
%   -options.drumFlag  [-] : if =1 then drum if =0 => no drum.
options.eta_mec = 0.98;  %[-] : mecanic efficiency of shafts bearings
%   -options.comb is a structure containing combustion data :
%       -comb.Tmax     [�C] : maximum combustion temperature
%       -comb.lambda   [-] : air excess
%       -comb.x        [-] : the ratio O_x/C. Example 0.05 in CH_1.2O_0.05
%       -comb.y        [-] : the ratio H_y/C. Example 1.2 in CH_1.2O_0.05
%   -options.T_exhaust [�C] : Temperature of exhaust gas out of the chimney
optionsST.p_3 = 10.5; %      [-] : High pressure after last reheating
%   -options.x4        [-] : Vapor ratio [gaseous/liquid] (in french : titre)
%   -options.T_0       [�C] : Reference temperature
%   -options.TpinchSub [�C] : Temperature pinch at the subcooler
optionsST.TpinchEx = 15;%  [�C] : Temperature pinch at a heat exchanger
optionsST.TpinchCond = 3;%[�C] : Temperature pinch at condenser
%   -options.Tdrum     [�C] : minimal drum temperature
optionsST.eta_SiC = 0.85;%   [-] : Isotrenpic efficiency for compression
optionsST.eta_SiT = 0.89;   %[-] : Isotrenpic efficiency for Turbine. It can be a vector of 2 values :
%             	             eta_SiT(1)=eta_SiT_HP,eta_SiT(2)=eta_SiT_others

P_e = 35e3;

[ETA,XMASSFLOW,DATEN,DATEX,DAT,MASSFLOW,COMBUSTION,FIG] = ST(P_e,optionsST,1)

