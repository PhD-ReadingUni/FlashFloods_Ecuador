WT_codes = WT(:,1);
WT_counts = WT(:,2);
n = length(WT_codes);

XTickLabels = {};
for i = 1 : n
    WT_code_temp = WT_codes(i);
    if WT_code_temp==11111 || WT_code_temp==21111 || WT_code_temp==31111 || WT_code_temp==41111
        XTickLabels = [XTickLabels, num2str(WT_code_temp)];
    else
        XTickLabels = [XTickLabels, " "];
    end
end


figure
bar((1:n), WT_counts)
xticks(1:n)
xticklabels(XTickLabels)
xlim([0 (n+1)])
ylim([0 1000000])
grid off