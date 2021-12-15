%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create_AccFF.m creates flash flood observational fields for different
% accumulation periods.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

% INPUT PARAMETERS
Acc = 12;
AccP_Start = [0,6,12,18];
Year = 2020;
EFFCI_list = [1,6,10];
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
FileIN_Emask = "Data/Processed/EcuadorMasks/Emask_ENS.csv";
FileIN_ObsFF = "Data/Raw/ObsFF_Mod/Ecu_FF_Hist_ECMWF_mod.csv";
DirOUT_AccFF_csv = "Data/Processed/AccFF";
DirOUT_AccFF_jpeg = "Data/Figures/AccFF";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Defining the analysis period
StartDate = datenum(Year,1,1);
EndDate = datenum(Year,12,31);
disp("Computing accumulated flash flood observational fields...")
disp(strcat("(", num2str(length(AccP_Start)), " ", num2str(Acc), "-hourly accumulated periods per day are considered"))
disp(strcat("between ", datestr(StartDate,"yyyy-mm-dd"), " and ", datestr(EndDate,"yyyy-mm-dd"), ")"))

% Reading Ecuador's mask
FileIN = strcat(Git_repo, "/", FileIN_Emask);
Emask = import_Emask(FileIN);
coordEmask = Emask(:,1:2);

% Generating template for accumulated flash flood observational fields
AccFF_template = Emask;
AccFF_template(:,3) = 0;

% Creating the output directory for .jpeg files
DirOUT_jpeg_temp = strcat(Git_repo, "/", DirOUT_AccFF_jpeg);
if ~exist(DirOUT_jpeg_temp, 'dir')
    mkdir(DirOUT_jpeg_temp)
end

% Creating the accumulated flash flood observational fields 
for ind_EFFCI = 1 : length(EFFCI_list)
    
    % Selecting the EFFCI threshold to consider
    EFFCI = EFFCI_list(ind_EFFCI);
    disp(" ")
    disp(strcat(" - Considering flood reports with EFFCI>=",num2str(EFFCI)))
    
    % Creating the output directory for .csv files
    DirOUT_csv_temp = strcat(Git_repo, "/", DirOUT_AccFF_csv, "/EFFCI", num2str(EFFCI,'%02.f'));
    if ~exist(DirOUT_csv_temp, 'dir')
       mkdir(DirOUT_csv_temp)
    end
    
    % Reading the flash flood reports for the correspondent year and EFFCI
    FileIN = strcat(Git_repo, "/", FileIN_ObsFF);
    ObsFF = import_ObsFF(FileIN,Year,EFFCI);
    
    % Initiating the variable that will stored the number of gridded flash  
    % flood observations for each accumulation period
    % Note: the end of the accumulation period is stored
    AccFF_grid = cell(0);
    
    % Selecting the accumulation periods
    for TheDate = StartDate : EndDate
        
        for ind_AccP = 1 : length(AccP_Start)
            
            AccP_S = AccP_Start(ind_AccP);
            AccP_F = AccP_S + Acc;
            
            Date_S = TheDate + hours(AccP_S) + minutes(0) + seconds(0);
            Date_F = TheDate + hours(AccP_F) + minutes(0) + seconds(0);
            
            % Selecting the flash flood reports within the considered 
            % accumulation period
            pointer_FF = find(ObsFF.DateTimeNum>=Date_S & ObsFF.DateTimeNum<Date_F);
            
            % Associating the flash flood reports to the ENS grid-boxes
            % The grid-boxes that have a flash flood associated are set to
            % 1; they are set to 0, otherwise.
            if ~isempty(pointer_FF)
                coordFF = [ObsFF.Y_DD(pointer_FF), ObsFF.X_DD(pointer_FF)];
                pointer_Emask = dsearchn(coordEmask,coordFF);
                AccFF = AccFF_template;
                AccFF(pointer_Emask,3) = 1; % if there are more ff obs in a grid box, they are not added up. Thus, the variable contains only 1s and 0s.
                NumAccFF_grid = sum(AccFF(:,3));
            else
                AccFF = AccFF_template;
                NumAccFF_grid = 0;
            end
            
            % Recording the number of flash flood reports in each ENS
            % grid-box
            AccFF_grid = [AccFF_grid; strcat(datestr(Date_F,"yyyy-mm-dd HH"), " UTC"), num2cell(NumAccFF_grid)];
            
            % Converting the matrix to table to store the accumulated
            % observational field in a .csv file with headings
            AccFF_table = array2table(AccFF,'VariableNames',{'lat','lon','AccFF_code'});
            
            % Saving the accumulated observational field in a .csv file
            FileOUT_csv = strcat(DirOUT_csv_temp, "/AccFF_", datestr(Date_F, "yyyymmdd"), "_", datestr(Date_F, "HH"), ".csv");
            writetable(AccFF_table, FileOUT_csv, 'Delimiter',',')
            
        end
        
    end
    
    % Plot the number of gridded flash flood reports in each accumulation 
    % period
    disp(" - Plotting the number of gridded flash flood reports in each accumulation period")
    
    AccPer = AccFF_grid(:,1);
    NumAccFF_grid = str2double(AccFF_grid(:,2));
    
    XLabel_list = {'2020-01-01 12 UTC','2020-02-01 12 UTC','2020-03-01 12 UTC','2020-04-01 12 UTC','2020-05-01 12 UTC','2020-06-01 12 UTC','2020-07-01 12 UTC','2020-08-01 12 UTC','2020-09-01 12 UTC','2020-10-01 12 UTC','2020-11-01 12 UTC','2020-12-01 12 UTC'};
    m = length(XLabel_list);
    XTicks_list = zeros(1,m);
    for i = 1 : m
        XLabel = XLabel_list(i);
        XTicks_list(i) = find(strcmp(AccPer,XLabel));
    end    
    
    figure
    plot(NumAccFF_grid, "xb")
    title(["Number of ENS grid-boxes containing at least one flood report", strcat("Flood reports with EFFCI>=", num2str(EFFCI))])
    xlabel("End of accumulation period")
    ylabel("Number of ENS grid-boxes")
    xticks(XTicks_list)
    xticklabels(XLabel_list)
    ylim([0 7])
    yticks(0:7)
    grid on
    
    % Saving the plot as .jpeg file
    FileOUT_eps = strcat(DirOUT_jpeg_temp, "/AccFF_EFFCI", num2str(EFFCI,'%02.f'), ".eps");
    saveas(gcf,FileOUT_eps, "epsc")
    
end