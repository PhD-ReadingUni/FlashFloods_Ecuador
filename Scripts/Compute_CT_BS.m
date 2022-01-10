%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute_CT_BS computes the boostrapping samples for the contingency 
% tables  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

% INPUT PARAMETERS
StepF_S = 18;
StepF_F = 18;
Disc_StepF = 6;
Acc = 12;
EFFCI_list = [1];
PercCDF_list = [85];
SystemFC_list = ["ENS", "ecPoint"];
NumEM_list = [51,99];
SystemFCPlot_list = ["r", "b"];
Region_list = [1,2];
RegionName_list = ["Costa", "Sierra"];
RegionPlot_list = ["o-","o--"];
NumBS = 1000;
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
DirIN_CT = "Data/Processed/CT_";
DirOUT_AURC = "Data/Figures/AURC_";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Creating the CT bootstrapping samples

for indEFFCI = 1 : length(EFFCI_list)
    
    % Selecting the EFFCI to consider
    EFFCI = EFFCI_list(indEFFCI);
    disp(" ")
    disp(strcat(" - Considering EFFCI>=", num2str(EFFCI)))
    
    for indPercCDF = 1 : length(PercCDF_list)
        
        % Selecting the CDF percentile to consider
        PercCDF = PercCDF_list(indPercCDF);
        disp(" ")
        disp(strcat("  - Considering PercCDF=", num2str(PercCDF)))
        
        for indSystemFC = 1 :length(SystemFC_list)
            
            % Selecting the forecasting system to consider
            SystemFC = SystemFC_list(indSystemFC);
            SystemFCPlot = SystemFCPlot_list(indSystemFC);
            NumEM = NumEM_list(indSystemFC);
            disp(" ")
            disp(strcat("   - Considering '", SystemFC, "' forecasts"))
        
            for indRegion = 1 : length(Region_list)
                
                % Selecting the region to consider
                Region = Region_list(indRegion);
                RegionName = RegionName_list(indRegion);
                RegionPlot = RegionPlot_list(indRegion);
                disp(" ")
                disp(strcat("    - Considering the '", RegionName, "' region"))
                
                for StepF = StepF_S : Disc_StepF : StepF_F
                    
                    % Selecting the StepF to consider
                    disp(strcat("      - Considering StepF=", num2str(PercCDF)))
                    
                    % Define the input directory
                    DirIN_temp = strcat(Git_repo, "/", DirIN_CT, num2str(Acc, "%03.f"), "/", SystemFC, "/EFFCI", num2str(EFFCI,'%02d'), "/Perc", num2str(PercCDF,'%02d') , "/", RegionName, "/", num2str(StepF,'%03d'));
                        
                    % % Creating the CT bootstrapping samples
                    NumDays = numel(dir(strcat(DirIN_temp,"/CT_Day*.csv")));
                    
                    H = zeros(NumEM,(NumBS+1));
                    FA = zeros(NumEM,(NumBS+1));
                    M = zeros(NumEM,(NumBS+1));
                    CN = zeros(NumEM,(NumBS+1));
                    
                    for indBS = 0 : NumBS
                        
                        disp(indBS)
                        
                        if indBS == 0
                            Days_BS = (1:NumDays)';
                        else
                            Days_BS = randi([1,NumDays],[NumDays,1]);
                        end
                        
                        for indDays = 1 : NumDays
                            
                            NumDay_temp = Days_BS(indDays);
                            FileIN_temp = strcat(DirIN_temp, "/CT_Day", num2str(NumDay_temp,"%03.f"), ".csv");
                            [H_temp,FA_temp,M_temp,CN_temp] = import_CT(FileIN_temp);
                            
                            H(:,indBS+1) = H(:,indBS+1) + H_temp;
                            FA(:,indBS+1) = FA(:,indBS+1) + FA_temp;
                            M(:,indBS+1) = M(:,indBS+1) + M_temp;
                            CN(:,indBS+1) = CN(:,indBS+1) + CN_temp;
                            
                        end
                        
                    end
                    
                    % Saving the CT bootstrapping samples
                    FileOUT_temp = strcat(DirIN_temp, "/CT_BS_H.csv");
                    writetable(array2table(H),FileOUT_temp,'Delimiter',',')
                    
                    FileOUT_temp = strcat(DirIN_temp, "/CT_BS_FA.csv");
                    writetable(array2table(FA),FileOUT_temp,'Delimiter',',')
                                
                    FileOUT_temp = strcat(DirIN_temp, "/CT_BS_M.csv");
                    writetable(array2table(M),FileOUT_temp,'Delimiter',',')
                    
                    FileOUT_temp = strcat(DirIN_temp, "/CT_BS_CN.csv");
                    writetable(array2table(CN),FileOUT_temp,'Delimiter',',')
                    
                end
                
            end
                    
        end
        
    end
    
end