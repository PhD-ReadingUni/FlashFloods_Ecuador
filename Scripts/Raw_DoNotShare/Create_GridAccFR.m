%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create_GridAccFR.m creates accumulated gridded flood observational fields 
% for a specific accumulation period from point flood reports, and saves
% them as .csv files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

% INPUT PARAMETERS
Year = 2020;
Acc = 12;
AccP_Start = [0,6,12,18];
EFFCI_list = [1,6,10];
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
FileIN_Emask = "Data/Raw/EcuadorMasks/Emask_ENS.csv";
FileIN_PointFR = "Data/Raw_DoNotShare/PointFR_Mod/Ecu_FF_Hist_ECMWF_mod.csv";
DirOUT_GridAccFR = "Data/Raw/GridAccFR_";
DirOUT_NumAccFR = "Data/Raw/NumAccFR_";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


disp("Creating accumulated gridded flood observational fields")

% Reading Ecuador's mask
FileIN = strcat(Git_repo, "/", FileIN_Emask);
Emask = import_Emask(FileIN);


% Generating the template for the accumulated gridded flood observational 
% fields
GridAccFR_template = Emask;
GridAccFR_template(:,3) = 0;


% Creating the accumulated gridded flood observational fields 
for ind_EFFCI = 1 : length(EFFCI_list)
    
    % Selecting the EFFCI threshold to consider
    EFFCI = EFFCI_list(ind_EFFCI);
    disp(strcat(" - Considering flood reports with EFFCI>=",num2str(EFFCI)))
    
    % Creating the output directory for the .csv files
    DirOUT_GridAccFR_temp = strcat(Git_repo, "/", DirOUT_GridAccFR, num2str(Acc,"%03.f"), "/EFFCI", num2str(EFFCI,'%02.f'));
    if ~exist(DirOUT_GridAccFR_temp, 'dir')
       mkdir(DirOUT_GridAccFR_temp)
    end
    
    DirOUT_NumAccFR_temp = strcat(Git_repo, "/", DirOUT_NumAccFR, num2str(Acc,"%03.f"), "/EFFCI", num2str(EFFCI,'%02.f'));
    if ~exist(DirOUT_NumAccFR_temp, 'dir')
       mkdir(DirOUT_NumAccFR_temp)
    end
    
    % Reading the flood reports for the correspondent year and EFFCI
    FileIN = strcat(Git_repo, "/", FileIN_PointFR);
    PointFR = import_PointFR(FileIN,Year,EFFCI);
    
    % Initiating the variable that will store the number of point and 
    % gridded flood reports in each accumulation period. Note that the end
    % of the correspondent accumulation period will be stored.
    NumAccFR_Point = cell(0);
    NumAccFR_Grid = cell(0);
    
    for TheDate = datenum(Year,1,1) : datenum(Year,12,31)
        
        for ind_AccP = 1 : length(AccP_Start)
            
            % Selecting the accumulation period to consider
            AccP_S = AccP_Start(ind_AccP);
            Date_S = TheDate + hours(AccP_S) + minutes(0) + seconds(0);
            AccP_F = AccP_S + Acc;
            Date_F = TheDate + hours(AccP_F) + minutes(0) + seconds(0);
            
            % Selecting the point flood reports within the considered 
            % accumulation period
            pointer_pointFR = find(PointFR.DateTimeNum>=Date_S & PointFR.DateTimeNum<Date_F);
           
            % Associating the point flood reports within the considered 
            % accumulation period to the correspondent grid-boxes. 
            % The grid-boxes that have at least one point flood report are
            % set to 1; otherwise, they are set to 0.
            GridAccFR = GridAccFR_template;
            NumAccFR_Point_temp = 0;
            NumAccFR_Grid_temp = 0;
            
            if ~isempty(pointer_pointFR)
                
                coord_pointFR = [PointFR.Y_DD(pointer_pointFR), PointFR.X_DD(pointer_pointFR)];
                pointer_gridFR = dsearchn(Emask(:,1:2),coord_pointFR);
                GridAccFR(pointer_gridFR,3) = 1; 
                
                NumAccFR_Point_temp = length(pointer_pointFR);
                NumAccFR_Grid_temp = sum(GridAccFR(:,3));
            
            end
            
            % Recording the number of point and gridded flood reports in
            % each accumulation period
            NumAccFR_Point = [NumAccFR_Point; strcat(datestr(Date_F,"yyyy-mm-dd HH"), " UTC"), num2cell(NumAccFR_Point_temp)];
            NumAccFR_Grid = [NumAccFR_Grid; strcat(datestr(Date_F,"yyyy-mm-dd HH"), " UTC"), num2cell(NumAccFR_Grid_temp)];
            
            % Saving the accumulated observational field in a .csv file
            GridAccFR_table = array2table(GridAccFR,'VariableNames',{'lat','lon','AccFR_code'});
            FileOUT = strcat(DirOUT_GridAccFR_temp, "/GridAccFR_", datestr(Date_F, "yyyymmdd"), "_", datestr(Date_F, "HH"), ".csv");
            writetable(GridAccFR_table, FileOUT, 'Delimiter',',')
            
        end
        
    end
    
    % Saving the number of point and gridded flood reports in each 
    % accumulation period
    FileOUT_NumAccFR_Point = strcat(DirOUT_NumAccFR_temp, "/NumAccFR_Point.csv");
    writematrix(["End_Acc_Period", "NumAccFR_Point"; NumAccFR_Point], FileOUT_NumAccFR_Point, 'Delimiter',',')
    
    FileOUT_NumAccFR_Grid = strcat(DirOUT_NumAccFR_temp, "/NumAccFR_Grid.csv");
    writematrix(["End_Acc_Period", "NumAccFR_Grid"; NumAccFR_Grid], FileOUT_NumAccFR_Grid, 'Delimiter',',')
    
end