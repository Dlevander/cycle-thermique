function [FIG] = plot_GT(DAT,eta_PiT,eta_PiC,R_air)
    %Compression 1-2
    linP12 = linespace(DAT(2,1),DAT(2,2),100);
    linr12 = p_2/fliplr(linP12);
    linT12 = transf_poly('compression',DAT(1,1),linr12,eta_PiC,R_air,0,0,0,0);
    linS12 = DAT(4,1) + (1-eta_PiC)*Cp_12*log((linT12+273.15)/(DAT(1,1)+273.15));
    %Combustion isobare 2-3
    TK_2 = DAT(1,2)+273.15;
    linT23 = linspace(DAT(1,2),DAT(1,3),100);
    linT23K = linT23+273.15;
    p_3 = DAT(2,2)*k_cc; %pertes de charges dans chambre combustion
    [x_N2,x_O2,x_CO2,x_H2O,R_fum,~,~,~,~] = combustion(x,y,DAT(1,2),linT23,0);
    Cp_23 = arrayfun(@(t) CP(x_O2,x_CO2,x_H2O,x_N2,[TK_2 t]),linT23K);
    linS23 = DAT(4,2)+ Cp_23*log(linT23K/TK_2) - R_fum*log(p_3/p_2);
    
    %Detente 3-4
    linP34 = linespace(DAT(2,3),DAT(2,4),100);
    linr34 = p_4/fliplr(linP34);
    linT34 = transf_poly('detente',DAT(1,3),linr34,eta_PiT,R_fum,x_CO2,x_H2O,x_O2,x_N2);
    linS34 = DAT(4,3) - Cp_34*log(linT34/TK_3)* ((1-eta_PiT)/eta_PiT);
    %Plot
    plot([linS12 linS23 linS34],[linT12 linT23 linT34]);
end