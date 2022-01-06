%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot_NumAccFR.m plots the number of point and gridded flood reports in 
% the considered accumulation periods.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

% INPUT PARAMETERS
Year = 2020;
EFFCI_list = [1,6,10];
Acc = 12;
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
FileIN_AccFR = "Data/Raw/NumAccFR_";
DirOUT = "Data/Figures/NumAccFR_";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


disp("Plotting the number of point and gridded flood reports in the considered accumulation periods.")

% Creating the output directory
DirOUT = strcat(Git_repo, "/", DirOUT, num2str(Acc, "%03.f"));
if ~exist(DirOUT, 'dir')
    mkdir(DirOUT)
end

% Creating the labels for the x-axis
m = 12;
XLabel_list = [];
for Month = 1 : m
    temp = strcat(num2str(Year), "-", num2str(Month,"%02.f"), "-01 ", num2str(Acc), " UTC");
    XLabel_list = [XLabel_list, temp];
end
XLabel_list = cellstr(XLabel_list);


% Plotting the number of point and gridded flood reports in the considered accumulation periods
for ind_EFFCI = 1 : length(EFFCI_list)
    
    % Selecting the EFFCI threshold to consider
    EFFCI = EFFCI_list(ind_EFFCI);
    disp(strcat(" - Considering flood reports with EFFCI>=",num2str(EFFCI)))
    
    % Reading the number of point and gridded flood reports for the correspondent EFFCI
    DirIN_temp = strcat(Git_repo, "/", FileIN_AccFR, num2str(Acc, "%03.f"), "/EFFCI", num2str(EFFCI, "%02.f"));
    FileIN_NumAccFR_Point = strcat(DirIN_temp, "/NumAccFR_Point.csv");
    FileIN_NumAccFR_Grid = strcat(DirIN_temp, "/NumAccFR_Grid.csv");
    
    NumAccFR_Point = import_NumAccFR(FileIN_NumAccFR_Point);
    NumAccFR_Grid = import_NumAccFR(FileIN_NumAccFR_Grid);
    
    % Plotting
    AccPer_End = NumAccFR_Point(:,1);
    NumAccFR_Point = double(string(NumAccFR_Point(:,2)));
    NumAccFR_Grid = double(string(NumAccFR_Grid(:,2)));
    
    XTick_list = zeros(1,m);
    for i = 1 : m
        XTick_list(i) = find(strcmp(AccPer_End,XLabel_list(i)));
    end
    
    figure
    plot(NumAccFR_Point, "xb")
    title(["Number of point flood reports in each accumulation period", strcat("Flood reports with EFFCI>=", num2str(EFFCI))])
    xlabel("End of accumulation period")
    ylabel("Number of point flood reports")
    xticks(XTick_list)
    xticklabels(XLabel_list)
    ylim([0 10])
    grid on
    
    FileOUT_Point = strcat(DirOUT, "/NumAccFR_Point_EFFCI", num2str(EFFCI,'%02.f'), ".eps");
    saveas(gcf,FileOUT_Point, "epsc")
    
    figure
    plot(NumAccFR_Grid, "xb")
    title(["Number of gridded flood reports in each accumulation period", strcat("Flood reports with EFFCI>=", num2str(EFFCI))])
    xlabel("End of accumulation period")
    ylabel("Number of gridded flood reports")
    xticks(XTick_list)
    xticklabels(XLabel_list)
    ylim([0 10])
    grid on
    
    FileOUT_Grid = strcat(DirOUT, "/NumAccFR_Grid_EFFCI", num2str(EFFCI,'%02.f'), ".eps");
    saveas(gcf,FileOUT_Grid, "epsc")
    
end