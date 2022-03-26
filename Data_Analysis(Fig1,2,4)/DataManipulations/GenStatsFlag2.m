function [statsFlag,temp_sign] = GenStatsFlag2(stats_tag, statsvalue, pvalue,showP,showSign)

% Use the statistic results to generate a string, which can be shown in the
% figure

% INPUT
% stats_tag: 
% statsvalue:  the value of the statistic
% pvalue:  p value
% showP : whether include " p = xxx " or " p < 0.001 " in the output 
% showSign:  whether show the stars at the end of the output
% OUTPUT
% statsFlag:  a string indicating the result of statistical test
% temp_sign:  the stars indicating significance

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