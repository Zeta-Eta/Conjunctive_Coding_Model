% plot RT in different ordinal position
% SE represented sem of participants in human and sessions in monkey
close all

clear;
datapath = [pwd '\AccuracyAndRT\'];
load([datapath 'all_ACC.mat'])

%% settings
participants = {'Adults','Children','MO&MG'};
parti_tag = {'Adults','Children','Monkeys'};


rule ='repeat';
touchtype ='freeTouch';   %  ''freeTouch'|'Combined'
setsize_2_plot = 4;
plot_weighted_monkey = 0;    % whether plot weighted mean of session (in monkey only, by trial number in each session)

%% font size and other properties

title_fontsize = 18;
label_fontsize = 18;
ticklabel_fontsize = 18;
text_fontsize = 14;
legend_fontsize = 16;

axis_ticklength = [0.015,0.025];
axis_linewidth = 2;
plot_linewidth = 2.5;



map = [    185 170 130; ...
    50 139 135; ...
    115 60 20; ...
    165 110 70; ...
    215 160 120]./255; % ¿¨Æä ÇàÂÌ  ¿§·È


fig = figure('Color',[1 1 1]);

set(gcf,'position',[0,0,260*size(participants,2),260]);

%% Plot RT
for i = 1:size(participants,2)
    h = subplot(1,size(participants,2),i);
    pos=get(h,'position');
    set(h,'pos',pos+[0 0.13 -0.03 -0.18])
    hold on;
    temp_max = 0; temp_min = 1;
    for j =1:size(setsize_2_plot,2)
        
        % human have only free touch
        if strcmp(participants{i},'Children') |  strcmp(participants{i},'Adults') | strcmp(participants{i},'Children_3Dots')
            data_temp = final_output(strcmp(participants{i},table2array(final_output(:,1)))...
                & strcmp(rule,table2array(final_output(:,2))) ...
                & strcmp('freeTouch',table2array(final_output(:,3))) ...
                & strcmp(num2str(setsize_2_plot(j)),string(table2array(final_output(:,4)))),:);
            % MO and MG
        elseif strcmp(participants{i},'MO') | strcmp(participants{i},'MG')
            data_temp = final_output(strcmp(participants{i},table2array(final_output(:,1)))...
                & strcmp(rule,table2array(final_output(:,2))) ...
                & strcmp(touchtype,table2array(final_output(:,3))) ...
                & strcmp(num2str(setsize_2_plot(j)),string(table2array(final_output(:,4)))),:);
            
        elseif contains(participants{i},'MO') & contains(participants{i},'MG')  % combine monkeys as one
              if strcmp(touchtype,'Combined')    % use monkeys' data regardless of touch type
                data_temp= final_output((strcmp('MO',table2array(final_output(:,1))) | strcmp('MG',table2array(final_output(:,1))))...
                    & strcmp(rule,table2array(final_output(:,2))) ...
                    & strcmp(touchtype,table2array(final_output(:,3))) ...
                    & strcmp(num2str(setsize_2_plot(j)),string(table2array(final_output(:,4)))),:);
              else  % use MO and MG's data in defined touch type
                data_temp= final_output((strcmp('MO',table2array(final_output(:,1))) | strcmp('MG',table2array(final_output(:,1))))...
                    & strcmp(rule,table2array(final_output(:,2))) ...
                    & strcmp(touchtype,table2array(final_output(:,3))) ...
                    & strcmp(num2str(setsize_2_plot(j)),string(table2array(final_output(:,4)))),:);
            end
        end
        
        if ~isempty(data_temp)
            data2plot{j} = data_temp.rt_session(:,1:setsize_2_plot(j));
            trialnum{j} = data_temp.trialnum;
            
            % statistical test: main effect of order( test for U-shape)
            % Shapiro-Wilk for normality
            [H_rt_normal(i,j), pValue_rt_normal(i,j), SWstatistic_rt_normal(i,j)] = swtest(reshape(data2plot{j},size(data2plot{j},1)*size(data2plot{j},2),1),0.05);  % 0- normally distributed
            
            % Repeat-measure ANOVA
            for kk =1:setsize_2_plot(j)
                name_temp{kk} =['item' num2str(kk)] ;
            end
            t = array2table( data2plot{j},'VariableName',name_temp);  clear name_temp
            rm = fitrm(t,['item1-item' num2str(setsize_2_plot(j)) '~1']);
            tbl_rt_anova{i,j} = ranova(rm);
            cANOVA_rt{i,j} = multcompare(rm,'Time','ComparisonType','bonferroni');
            
            
            [P_rt_npara(i,j),tbl_rt_npara{i,j},stats_rt_npara{i,j}] = friedman(data2plot{j},1,'off');   % Friedman test
            cnpara_rt{i,j} = multcompare(stats_rt_npara{i,j},'Alpha',0.05,'CType','bonferroni','Display','off');    %  pval = NaN   'bonferroni'
            chisquare_npara(i,1) = tbl_rt_npara{i,1}{2,5};
            kendallsw(i,1) = chisquare_npara(i,1)/(size(data2plot{j},1)*(setsize_2_plot(j)-1));
            % compute adjusted pvalue manually
            for tt = 1:size(cnpara_rt{i,j},1)
                                cnpara_rt{i,j}(tt,6)=signrank(data2plot{j}(:,cnpara_rt{i,j}(tt,1)),data2plot{j}(:,cnpara_rt{i,j}(tt,2)));
%                 cnpara_rt{i,j}(tt,6)= friedman(data2plot{j}(:,[cnpara_rt{i,j}(tt,1),cnpara_rt{i,j}(tt,2)]),1,'off');
% %                 cnpara_rt{i,j}(tt,6) =min(cnpara_rt{i,j}(tt,6)*size(cnpara_rt{i,j},1),1);
%  cnpara_rt{i,j}(tt,6) =min(cnpara_rt{i,j}(tt,6)*3;
            end
            
            if plot_weighted_monkey == 1 & contains(participants{i},'M')
                % Weighted mean
                data_mean = sum(trialnum{j}.*data2plot{j}(:,1:setsize_2_plot(j)),1)/sum(trialnum{j},1);
                data_sd = std(data2plot{j}(:,1:setsize_2_plot(j)),trialnum{j},1);
                data_errorbar =data_sd/sqrt(length(data2plot{j}));
            else
                % Arithmetic mean
                data_mean = mean(data2plot{j}(:,1:setsize_2_plot(j)),1);
                data_sd = std(data2plot{j}(:,1:setsize_2_plot(j)),1);
                data_errorbar = data_sd/sqrt(length(data2plot{j}));
            end
            for pair = 1:3
              cohen_d(i,pair) = (data_mean(pair) - data_mean(pair+1))/sqrt((data_sd(pair)^2 + data_sd(pair+1)^2)/2);
            end
            
            temp_max = max(temp_max,max(data_mean+data_errorbar,[],[1 2]));
            temp_min = min(temp_min,min(data_mean-data_errorbar,[],[1 2]));
            
            errorbar([1:setsize_2_plot(j)]+(j-1)*0.12,data_mean,data_errorbar,'LineWidth',plot_linewidth,'Color',map(i,:));
        end
    end
    title(parti_tag{i},'FontSize',title_fontsize ,'FontName', 'Arial','FontWeight', 'bold');
    
    if temp_max-temp_min>0.2
        y_scale = [0:0.2:2];
    else
        y_scale = [0:0.05:2];
    end
    set(gca,'XTick',[0:1:6],'YTick',y_scale,'LineWidth',axis_linewidth,'FontSize',ticklabel_fontsize,'tickdir','out','ticklength',axis_ticklength);
    
    upper_limit = y_scale(min(find(y_scale > temp_max)));
    lower_limit = y_scale(max(find(y_scale < temp_min)));
        
    ylim([lower_limit,min(upper_limit,1)]);
   xlim([0.5,max(setsize_2_plot)+.5]);
    if strcmp(participants{i},'Adults')
        xlim([0.5,max(setsize_2_plot)+.5]);
    end
    
    hold off;   
end

hold on
ax = axes(fig);
han = gca;
han.Visible = 'off';
han.XLabel.Visible = 'on';
han.YLabel.Visible = 'on';
xlb = xlabel('Order','FontName', 'Arial','FontWeight', 'bold','FontSize',label_fontsize);
ylb = ylabel('Time/s','FontName', 'Arial','FontWeight', 'bold','FontSize',label_fontsize );
xlb.Position = [0.5, -0.024, 0];
ylb.Position = [-0.1, 0.5, 0];
get(fig,'paperposition');
hold off


