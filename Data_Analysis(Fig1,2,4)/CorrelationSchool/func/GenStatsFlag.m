function [statsFlag] = GenStatsFlag(stats_tag, statsvalue, pvalue,showP,showSign)

temp_sign = '';
if showP ==0
    if pvalue <0.001
        statsFlag =  [stats_tag ' = ' num2str(round(statsvalue,3))];
        temp_sign = ' ***';
    elseif pvalue <0.01
        statsFlag = [stats_tag ' = ' num2str(round(statsvalue,3))];
        temp_sign = ' **';
    elseif pvalue <0.05
        statsFlag = [stats_tag ' = ' num2str(round(statsvalue,3))];
        temp_sign = ' *';
    else
        statsFlag = [stats_tag ' = ' num2str(round(statsvalue,3)) ];
    end
else
    if pvalue <0.001
        statsFlag =  [stats_tag ' = ' num2str(round(statsvalue,3)) ', p < .001'];
        temp_sign = ' ***';
    elseif pvalue <0.01
        statsFlag = [stats_tag ' = ' num2str(round(statsvalue,3)) ', p = ' num2str(round(pvalue,3))];
        temp_sign = ' **';
    elseif pvalue <0.05
        statsFlag = [stats_tag ' = ' num2str(round(statsvalue,3)) ', p = ' num2str(round(pvalue,3))];
        temp_sign = ' *';
    else
        statsFlag = [stats_tag ' = ' num2str(round(statsvalue,3)) ', p = ' num2str(round(pvalue,3)) ];
    end  
end
if showSign==1
    statsFlag = [statsFlag,temp_sign];
end