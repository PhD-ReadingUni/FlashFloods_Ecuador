%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot_CDFs plots the CDFs for all rainfall values in "La Costa" and "La 
% Sierra" for 2019, and the CDFs for rainfall values associated with flash  
% flood events.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

% INPUT PARAMETERS
Year = 2019;
Acc = 12;
Percs = (1:99);
PercExt_list = [50,75,85,90,95,98,99];
EFFCI_list = [1,6,10];
SystemFC_list = ["ENS","ecPoint"];
RegionName_list = ["Costa","Sierra"];
LZ_Acc = 3;
LZ_Perc = 2;
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
DirIN = "Data/Processed/RainCDF_";
DirOUT = "Data/Figures/RainCDF_";

Colours_PlotSystemFC_list = ["r","b"];
Lines_PlotSystemFC_list = ["-",":"];

Colours_PlotRegion_list = ["#FFDA00","#996500"];
Lines_PlotRegion_list = ["-","--"];

PlotPercExt_list = ["#EDB120", "g", "#7E2F8E", "c", "#0072BD", "m", "#D95319"];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% NOTE: Points that belong to Ecuador's region "Oriente" will not be
% considered in this analysis as there are not many flood reports for that
% region and any analysis might be robust.

% Creating strings from numbers
AccSTR = num2str(Acc, strcat('%0',num2str(LZ_Acc),'.f'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Plotting the CDFs for all rainfall values in "La Costa" and "La 
% Sierra" (all cases are considered)

for indRegion = 1 : length(RegionName_list)
    
    % Selecting the region to consider
    RegionName = RegionName_list(indRegion);
    Lines_PlotRegion = Lines_PlotRegion_list(indRegion);
    disp(strcat(" - Considering the region '", RegionName, "'"))
    
    figure
    
    for indFC = 1 : length(SystemFC_list)
        
        % Selecting the forecasting system to consider
        SystemFC = SystemFC_list(indFC);
        Colours_PlotSystemFC = Colours_PlotSystemFC_list(indFC);
        disp(strcat("   - Considering '", SystemFC, "'"))
    
        DirIN_temp = strcat(Git_repo, "/", DirIN, AccSTR, "/RainAll/", SystemFC, "/", RegionName);
        FileIN = strcat(DirIN_temp, strcat("/RainCDF_All.csv"));
        CDF = import_CDF(FileIN);
        
        plot(CDF(:,2), CDF(:,1), "Color", Colours_PlotSystemFC, "LineWidth", 2)
        hold on
        
    end
    
    xlabel("Rainfall values [mm/12h]")
    ylabel("Percentiles (%)")
    xlim([0 100])
    ylim([0 100])
    yticks(0:5:100)
    
    YTickLabels = {};
    for i = 0 : 5 : 100
        if mod(i,10) == 0
            YTickLabels = [YTickLabels, num2str(i)];
        else
            YTickLabels = [YTickLabels, " "];
        end
    end
    yticklabels(YTickLabels)
    
    grid on
    ax=gca;
    ax.GridAlpha=0.5;
    ax.FontSize = 16;

    FileOUT = strcat(Git_repo, "/", DirOUT, AccSTR, "/RainAll_All_", RegionName, ".eps");
    saveas(gcf,FileOUT, "epsc")    
    
end


% Plotting the CDFs for all rainfall values in "La Costa" and "La 
% Sierra" (only extreme cases are considered)

for indRegion = 1 : length(RegionName_list)
    
    % Selecting the region to consider
    RegionName = RegionName_list(indRegion);
    disp(strcat(" - Considering the region '", RegionName, "'"))
    
    figure
    
    for indFC = 1 : length(SystemFC_list)
        
        % Selecting the forecasting system to consider
        SystemFC = SystemFC_list(indFC);
        Lines_PlotSystemFC = Lines_PlotSystemFC_list(indFC);
        disp(strcat("   - Considering '", SystemFC, "'"))
        
        DirIN_temp = strcat(Git_repo, "/", DirIN, AccSTR, "/RainAll/", SystemFC, "/", RegionName);
        
        for indPercExt = 1 : length(PercExt_list)
        
            PercExt = PercExt_list(indPercExt);
            PlotPercExt = PlotPercExt_list(indPercExt);
            PercExtSTR = num2str(PercExt, strcat('%0',num2str(LZ_Perc),'.f'));
            
            FileIN = strcat(DirIN_temp, strcat("/RainCDF_RainExt", PercExtSTR, ".csv"));
            CDF = import_CDF(FileIN);
        
            % Setting the plots
            PlotLinesColour = strcat(PlotPercExt,Lines_PlotSystemFC);
            
            plot(CDF(:,2), CDF(:,1), Lines_PlotSystemFC, "Color", PlotPercExt, "LineWidth", 3)
            hold on
        
        end
        
    end
    
    xlabel("Rainfall values [mm/12h]")
    ylabel("Percentiles (%)")
    xlim([0 100])
    ylim([0 100])
    yticks(0:5:100)
    
    YTickLabels = {};
    for i = 0 : 5 : 100
        if mod(i,10) == 0 
            YTickLabels = [YTickLabels, num2str(i)];
        else
            YTickLabels = [YTickLabels, " "];
        end
    end
    yticklabels(YTickLabels)
    
    grid on
    ax=gca;
    ax.GridAlpha=0.5;
    ax.FontSize = 16; 
    
    FileOUT = strcat(Git_repo, "/", DirOUT, AccSTR, "/RainAll_RainExtr_", RegionName, ".eps");
    saveas(gcf,FileOUT, "epsc")
    
end


% Plotting the CDFs for all rainfall values associated to flood reports in 
% "La Costa" and "La Sierra" (all cases are considered)

for indEFFCI = 1 : length(EFFCI_list)
    
    % Selecting the EFFCI to consider
    EFFCI = EFFCI_list(indEFFCI);
    EFFCI_STR = num2str(EFFCI,"%02.f");
    disp(strcat(" - Considering an EFFCI>=", EFFCI_STR))

    for indRegion = 1 : length(RegionName_list)
        
        % Selecting the region to consider
        RegionName = RegionName_list(indRegion);
        Lines_PlotRegion = Lines_PlotRegion_list(indRegion);
        disp(strcat(" - Considering the region '", RegionName, "'"))
        
        figure
        
        for indFC = 1 : length(SystemFC_list)
            
            % Selecting the forecasting system to consider
            SystemFC = SystemFC_list(indFC);
            Colours_PlotSystemFC = Colours_PlotSystemFC_list(indFC);
            disp(strcat("   - Considering '", SystemFC, "'"))
            
            DirIN_temp = strcat(Git_repo, "/", DirIN, AccSTR, "/RainFR/", SystemFC, "/EFFCI", EFFCI_STR, "/", RegionName);
            FileIN = strcat(DirIN_temp, strcat("/RainCDF_All.csv"));
            CDF = import_CDF(FileIN);
            
            plot(CDF(:,2), CDF(:,1), "Color", Colours_PlotSystemFC, "LineWidth", 2)
            hold on
            
        end
        
        xlabel("Rainfall values [mm/12h]")
        ylabel("Percentiles (%)")
        xlim([0 350])
        ylim([0 100])
        yticks(0:5:100)
        
        YTickLabels = {};
        for i = 0 : 5 : 100
            if mod(i,10) == 0
                YTickLabels = [YTickLabels, num2str(i)];
            else
                YTickLabels = [YTickLabels, " "];
            end
        end
        yticklabels(YTickLabels)
        
        grid on
        ax=gca;
        ax.GridAlpha=0.5;
        ax.FontSize = 16;
        
        FileOUT = strcat(Git_repo, "/", DirOUT, AccSTR, "/RainFR_All_EFFCI", EFFCI_STR, "_", RegionName, ".eps");
        saveas(gcf,FileOUT, "epsc")
        
    end
    
end


% Plotting the CDFs for all rainfall values in "La Costa" and "La 
% Sierra" (only extreme cases are considered)

for indEFFCI = 1 : length(EFFCI_list)
    
    % Selecting the EFFCI to consider
    EFFCI = EFFCI_list(indEFFCI);
    EFFCI_STR = num2str(EFFCI,"%02.f");
    disp(strcat(" - Considering an EFFCI>=", EFFCI_STR))

    for indRegion = 1 : length(RegionName_list)
        
        % Selecting the region to consider
        RegionName = RegionName_list(indRegion);
        disp(strcat(" - Considering the region '", RegionName, "'"))
        
        figure
        
        for indFC = 1 : length(SystemFC_list)
            
            % Selecting the forecasting system to consider
            SystemFC = SystemFC_list(indFC);
            Lines_PlotSystemFC = Lines_PlotSystemFC_list(indFC);
            disp(strcat("   - Considering '", SystemFC, "'"))
            
            DirIN_temp = strcat(Git_repo, "/", DirIN, AccSTR, "/RainFR/", SystemFC, "/EFFCI", EFFCI_STR, "/", RegionName);
             
            for indPercExt = 1 : length(PercExt_list)
                
                PercExt = PercExt_list(indPercExt);
                PlotPercExt = PlotPercExt_list(indPercExt);
                PercExtSTR = num2str(PercExt, strcat('%0',num2str(LZ_Perc),'.f'));
                
                FileIN = strcat(DirIN_temp, strcat("/RainCDF_RainExt", PercExtSTR, ".csv"));
                CDF = import_CDF(FileIN);
                
                % Setting the plots
                PlotLinesColour = strcat(PlotPercExt,Lines_PlotSystemFC);
                
                plot(CDF(:,2), CDF(:,1), Lines_PlotSystemFC, "Color", PlotPercExt, "LineWidth", 3)
                hold on
                
            end
            
        end
        
        xlabel("Rainfall values [mm/12h]")
        ylabel("Percentiles (%)")
        xlim([0 350])
        ylim([0 100])
        yticks(0:5:100)
        
        YTickLabels = {};
        for i = 0 : 5 : 100
            if mod(i,10) == 0
                YTickLabels = [YTickLabels, num2str(i)];
            else
                YTickLabels = [YTickLabels, " "];
            end
        end
        yticklabels(YTickLabels)
        
        grid on
        ax=gca;
        ax.GridAlpha=0.5;
        ax.FontSize = 16;
        
        FileOUT = strcat(Git_repo, "/", DirOUT, AccSTR, "/RainFR_RainExtr_EFFCI", EFFCI_STR, "_", RegionName, ".eps");
        saveas(gcf,FileOUT, "epsc")
        
    end
    
end


% Zoom in of the CDFs for all rainfall values in "La Costa" and "La 
% Sierra" (only extreme cases are considered)

for indEFFCI = 1 : length(EFFCI_list)
    
    % Selecting the EFFCI to consider
    EFFCI = EFFCI_list(indEFFCI);
    EFFCI_STR = num2str(EFFCI,"%02.f");
    disp(strcat(" - Considering an EFFCI>=", EFFCI_STR))

    for indRegion = 1 : length(RegionName_list)
        
        % Selecting the region to consider
        RegionName = RegionName_list(indRegion);
        disp(strcat(" - Considering the region '", RegionName, "'"))
        
        figure
        
        for indFC = 1 : length(SystemFC_list)
            
            % Selecting the forecasting system to consider
            SystemFC = SystemFC_list(indFC);
            Lines_PlotSystemFC = Lines_PlotSystemFC_list(indFC);
            disp(strcat("   - Considering '", SystemFC, "'"))
            
            DirIN_temp = strcat(Git_repo, "/", DirIN, AccSTR, "/RainFR/", SystemFC, "/EFFCI", EFFCI_STR, "/", RegionName);
             
            for indPercExt = 1 : length(PercExt_list)
                
                PercExt = PercExt_list(indPercExt);
                PlotPercExt = PlotPercExt_list(indPercExt);
                PercExtSTR = num2str(PercExt, strcat('%0',num2str(LZ_Perc),'.f'));
                
                FileIN = strcat(DirIN_temp, strcat("/RainCDF_RainExt", PercExtSTR, ".csv"));
                CDF = import_CDF(FileIN);
                
                % Setting the plots
                PlotLinesColour = strcat(PlotPercExt,Lines_PlotSystemFC);
                
                plot(CDF(:,2), CDF(:,1), Lines_PlotSystemFC, "Color", PlotPercExt, "LineWidth", 3)
                hold on
                
            end
            
        end
        
        xlabel("Rainfall values [mm/12h]")
        ylabel("Percentiles (%)")
        xlim([0 100])
        ylim([0 100])
        yticks(0:5:100)
        
        YTickLabels = {};
        for i = 0 : 5 : 100
            if mod(i,10) == 0
                YTickLabels = [YTickLabels, num2str(i)];
            else
                YTickLabels = [YTickLabels, " "];
            end
        end
        yticklabels(YTickLabels)
        
        grid on
        ax=gca;
        ax.GridAlpha=0.5;
        ax.FontSize = 16;
        
        FileOUT = strcat(Git_repo, "/", DirOUT, AccSTR, "/RainFR_RainExtr_EFFCI", EFFCI_STR, "_", RegionName, "_ZoomIn.eps");
        saveas(gcf,FileOUT, "epsc")
        
    end
    
end
