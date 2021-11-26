% CDFs_RainThr.m creates the CDFs for the rainfall thresholds used in
% Ecuador

clear 
clc

% INPUT PARAMETERS
Year = 2019;
Region_list = ["Costa", "Sierra"];
ThrEFFCI = 10;
Colour_list = ["b", "r"];
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
DirIN = "Data/Processed/RainThr";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure

for indReg = 1 : length(Region_list)
    
    Region = Region_list(indReg);
    Colour = Colour_list(indReg);
        
    FileIN = strcat(Git_repo, "/", DirIN, "/RainThr_", num2str(Year), "_EFFCI", num2str(ThrEFFCI,'%02.f'), "_", Region, ".csv");
    [Perc,Vals] = import_RainThr(FileIN);
    plot(Vals,Perc,strcat(Colour,"-"), "LineWidth", 2)
    hold on

end

title(strcat("Rainfall percentiles - EFFCI>=", num2str(ThrEFFCI)))
xlabel("Rainfall [mm/12h]")
ylabel("Percentiles")
xlim([0,100])
ylim([30,100])
legend("Costa", "Sierra")