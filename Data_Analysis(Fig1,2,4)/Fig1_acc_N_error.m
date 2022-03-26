%% plot fig1
% accuracy figure:
%  error bar represent se of:
%       participants for human beings
%       sessions for monkeys

clear;
% load data
datapath = [pwd '\AccuracyAndRT\'];
load([datapath 'all_ACC.mat'])

%% Plot accuracy
participants = {'Adults','Children','MO','MG'};
parti_tag = {'Adults','Children','M1','M2'};

rule ='repeat';
touchtype ='freeTouch';   %  ''freeTouch'|'Combined'|'errorStop'
plot_weighted_monkey = 0;    % whether plot weighted mean of session (in monkey only, by trial number in each session)

%% font size and other properties
title_fontsize = 18;
label_fontsize = 18;
ticklabel_fontsize = 18;
legend_fontsize = 16;

axis_ticklength = [0.015 0.025];
axis_fontweight = 'bold'; % 'bold' | 'normal';

axis_linewidth = 2;
plot_linewidth = 2.5;

%% Accuracy (each touch)
map = [0 0 0
    81 81 81
    133 133 133
    185 185 185
    ]/255;

fig = figure('Color',[1 1 1]);

set(gcf,'position',[0,0,310*size(participants,2),900]);   % 310 for 3 columns, 280 for 4 columns

setsize_2_plot = 3:6;
for i = 1:size(participants,2)

    temp_max = 0; temp_min = 1;
    h(i,1)= subplot(3,size(participants,2),i);
    hold on;
    for j =1:size(setsize_2_plot,2)
        % human have only free touch
        if contains(participants{i},'Children') |  contains(participants{i},'Adults')
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
            if  strcmp(touchtype,'Combined')    % use  monkeys' data regardless of touch type
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
            
            data2plot{j} = data_temp.acc_session(:,1:setsize_2_plot(j));
            trialnum{j} = data_temp.trialnum;
            
            % statistical test: main effect of order( test for U-shape)
            % Shapiro-Wilk for normality
            [H_normal(i,j), pValue_normal(i,j), SWstatistic_normal(i,j)] = swtest(reshape(data2plot{j},size(data2plot{j},1)*size(data2plot{j},2),1),0.05);  % 0- normally distributed
            
            % %             Repeat-measure ANOVA
            if setsize_2_plot(j) == 3
                for kk =1:setsize_2_plot(j)
                    name_temp{kk} =['item' num2str(kk)] ;
                end
                t = array2table( data2plot{j},'VariableName',name_temp);  clear name_temp
                rm = fitrm(t,['item1-item' num2str(setsize_2_plot(j)) '~1']);
                tbl_anova{i,j} = ranova(rm);
                cANOVA{i,j} = multcompare(rm,'Time','ComparisonType','bonferroni');
                
                [P_anova(i,j),tbl_anova{i,j},stats_anova{i,j}] = anova1(data2plot{j},[],'off');   % one-way ANOVA, should be RM-ANOVA
                cANOVA{i,j} = multcompare(stats_anova{i,j},'Alpha',0.05,'CType','bonferroni','Display','off');
                
                [P_npara(i,j),tbl_npara{i,j},stats_npara{i,j}] = friedman(data2plot{j},1,'off');   % Friedman test
                cnpara{i,j} = multcompare(stats_npara{i,j},'Alpha',0.05,'CType','bonferroni','Display','off'); %  pval =NaN
                chisquare_npara(i,1) = tbl_npara{i,1}{2,5};
                kendallsw(i,1) = chisquare_npara(i,1)/(size(data2plot{j},1)*(setsize_2_plot(j)-1));
                % compute adjusted pvalue manually
                for tt = 1:size(cnpara{i,j},1)
                    cnpara{i,j}(tt,6)=signrank(data2plot{j}(:,cnpara{i,j}(tt,1)),data2plot{j}(:,cnpara{i,j}(tt,2)));
                    %                     cnpara{i,j}(tt,6)= friedman(data2plot{j}(:,[cnpara{i,j}(tt,1),cnpara{i,j}(tt,2)]),1,'off');
                    %                                     cnpara{i,j}(tt,6) =min(cnpara{i,j}(tt,6)*size(cnpara{i,j},1),1);
                end
            end
            
            % whether use weighted mean and se for monkeys
            if plot_weighted_monkey == 1 & contains(participants{i},'M')
                % Weighted mean
                data_mean = sum(trialnum{j}.*data2plot{j}(:,1:setsize_2_plot(j)),1)/sum(trialnum{j},1);
                data_sd = std(data2plot{j}(:,1:setsize_2_plot(j)),trialnum{j},1);
                data_errorbar = data_sd/sqrt(length(data2plot{j}));
            else
                % Arithmetic mean
                data_mean = mean(data2plot{j}(:,1:setsize_2_plot(j)),1);
                 data_sd = std(data2plot{j}(:,1:setsize_2_plot(j)),1);
                data_errorbar = data_sd/sqrt(length(data2plot{j}));
            end
            for pair = 1:setsize_2_plot(j)-1
                cohen_d(i,pair) = (data_mean(pair) - data_mean(pair+1))/sqrt((data_sd(pair)^2 + data_sd(pair+1)^2)/2);
            end
            temp_max = max(temp_max,max(data_mean+data_errorbar,[],[1 2]));
            temp_min = min(temp_min,min(data_mean-data_errorbar,[],[1 2]));
            % plot line with error bar
            errorbar([1:setsize_2_plot(j)]+(j-1)*0.12-0.12,data_mean,data_errorbar,'LineWidth',plot_linewidth,'Color',map(j,:));
        end
    end
    title(parti_tag{i},'FontName', 'Arial','FontWeight', 'bold','FontSize',title_fontsize);
    % set ticks
    mini_tick = 0.1;
    y_scale = [0:mini_tick:1];
    set(gca,'XTick',[0:1:6],'YTick',y_scale,'LineWidth',axis_linewidth,'FontSize',ticklabel_fontsize ,'tickdir','out','ticklength',axis_ticklength,'FontWeight',axis_fontweight);
    
    upper_limit = y_scale(min(find(y_scale >= temp_max)));
    lower_limit = y_scale(max(find(y_scale <= temp_min)));
    if i == 1
        ylabel('P(correct)','FontName', 'Arial','FontWeight', 'bold','FontSize',label_fontsize);
    elseif  i == size(participants,2)
        text(4.5,lower_limit-0.07*(upper_limit-lower_limit),'(Order)','FontWeight', 'bold','FontSize',label_fontsize)
    end
    if strcmp(participants{i},'Adults')
        xlim([0.5,6.5]);
        ylim([0.8,1]);
    elseif strcmp(participants{i},'Adults_3Dots')
        xlim([0.5,3.5]);
        ylim([0.95,1]);      
        set(gca,'XTick',[0:1:6],'YTick',[0:0.05:1],'LineWidth',axis_linewidth,'FontSize',ticklabel_fontsize ,'tickdir','out','ticklength',axis_ticklength,'FontWeight',axis_fontweight);
    elseif strcmp(participants{i},'Children_3Dots')
        xlim([0.5,3.5]);
        ylim([0.6,0.9]);
    else
        xlim([0.5,4.5]);
        ylim([lower_limit,min(upper_limit,1)]);
    end
    hold off;
end

%% plot order error
map = [180 65 55
    220 139 55
    90 139 60
    50 115 169]/255; % ºì ³È ÂÌ À¶
colormap(map)
setsize_2_plot = 4;
% load the distibution and plot
for i = 1:size(participants,2)
    temp_max = 1;
    filepath = ['Data/' participants{i} '/'];
    if strcmp(touchtype,'freeTouch')  | strcmp(touchtype,'errorStop')
        if strcmp(participants{i},'Adults') | strcmp(participants{i},'Children')
            datafile = [filepath, 'freeTouch_' rule '_' num2str(setsize_2_plot) '_DistributionMap.mat'];
        else
            datafile = [filepath, touchtype '_' rule '_' num2str(setsize_2_plot) '_DistributionMap.mat'];
        end
    elseif strcmp(touchtype, 'Combined')
        if strcmp(participants{i},'Adults') | strcmp(participants{i},'Children')
            datafile = [filepath, 'freeTouch_' rule '_' num2str(setsize_2_plot) '_DistributionMap.mat'];
        else
            datafile = [filepath, 'Combined_' rule '_' num2str(setsize_2_plot) '_DistributionMap.mat'];
        end
    end
    load(datafile);
      
    h(i,2)= subplot(3,size(participants,2),i+size(participants,2)*1);
    hold on;
    for j =1:size(setsize_2_plot,2)
        data2plot{j} = OrderMap;
        if ~isempty(data2plot{j})
            for k=1:setsize_2_plot
                plot(data2plot{j}(k,2:end)','LineWidth',plot_linewidth,'Color',map(k,:),'Marker','.','MarkerSize',22)
            end
        end
    end
    upper_limit = 1;
    lower_limit = -0.05;
    set(gca,'XTick',[0:1:4],'YTick',[0:0.5:1],'LineWidth',axis_linewidth,'FontSize',ticklabel_fontsize ,'tickdir','out','ticklength',axis_ticklength,'FontWeight',axis_fontweight);
    if i ==1
        ylabel('P(response)','FontName', 'Arial','FontWeight', 'bold','FontSize',label_fontsize);
        %         ylabel('Response');
    elseif  i == size(participants,2)
        text(setsize_2_plot+.5,lower_limit-0.07*(upper_limit-lower_limit),'(Order)','FontWeight', 'bold','FontSize',label_fontsize)
    end
    xlim([0.5,setsize_2_plot+.5]);
    ylim([-0.05,1]);
    %     xlabel('Order');
    hold off;
    clear data2plot;
end



%% plot distance error

setsize_2_plot = 4;
for i = 1:size(participants,2)
    temp_max = 1;     temp_min = 1;
    filepath = ['Data/' participants{i} '/'];
    
    if strcmp(touchtype,'freeTouch')  | strcmp(touchtype,'errorStop')
        if strcmp(participants{i},'Adults') | strcmp(participants{i},'Children')
            datafile = [filepath, 'freeTouch_' rule '_' num2str(setsize_2_plot) '_DistributionMap.mat'];
        else
            datafile = [filepath, touchtype '_' rule '_' num2str(setsize_2_plot) '_DistributionMap.mat'];
        end
    elseif strcmp(touchtype, 'Combined')
        if strcmp(participants{i},'Adults') | strcmp(participants{i},'Children')
            datafile = [filepath, 'freeTouch_' rule '_' num2str(setsize_2_plot) '_DistributionMap.mat'];
        else
            datafile = [filepath, 'Combined_' rule '_' num2str(setsize_2_plot) '_DistributionMap.mat'];
        end
    end
    load(datafile);
    
    h(i,3)= subplot(3,size(participants,2),i+size(participants,2)*2);
    hold on;
    for j =1:size(setsize_2_plot,2)
        data2plot{j} = DistMap;
        %         data2plot{j} = PositionMap;
        if ~isempty(data2plot{j})
            temp_max = min(temp_max,max(data2plot{j}(:,2:end),[],[1 2]));
            temp_min = min(temp_min,min(data2plot{j}(:,2:end),[],[1 2]));
            for k=1:setsize_2_plot
                plot(data2plot{j}(k,2:end)','LineWidth',plot_linewidth,'Color',map(k,:),'Marker','.','MarkerSize',20)
            end
        end
    end
    
    mini_tick = 0.16;
    while temp_max- temp_min <mini_tick*1.5
        mini_tick = mini_tick/2;
    end
    y_scale = [0:mini_tick:1];
    set(gca,'XTick',[0:1:4],'YTick',y_scale,'LineWidth',axis_linewidth,'FontSize',ticklabel_fontsize,'tickdir','out','ticklength',axis_ticklength,'FontWeight',axis_fontweight);
    upper_limit = y_scale(min(find(y_scale > temp_max)));
    lower_limit = y_scale(max(find(y_scale < temp_min)));
    
    %     ylim([0,upper_limit]);
    if lower_limit & upper_limit
        ylim([lower_limit,upper_limit]);
    else
        ylim([0,upper_limit]);
    end
    
    xlim([0.5,3.5]);
    if i ==1
        ylabel('P(response)','FontName', 'Arial','FontWeight', 'bold','FontSize',label_fontsize);
    elseif  i == size(participants,2)
        text(3.2,lower_limit-0.07*(upper_limit-lower_limit),'(Distance)','FontWeight', 'bold','FontSize',label_fontsize)
    end
    %     xlabel('Distance');
    hold off;
    clear data2plot;
end
hold on;
lgd= legend({'1','2','3','4'},'Position',[0.88 0.16 0.015 0.15],'Box','off','FontSize',legend_fontsize,'FontWeight','bold');% for 4 columns
title(lgd,'Touch','FontSize',legend_fontsize,'FontWeight','bold')
hold off;

% adjust subplot position
for i = 1:3   % rows
    for j = 1:size(participants,2)  % column
        pos = get(h(j,i),'position');
%         set(h(j,i),'pos',pos+[0 0 -0.02 -0.01])  % for 3 columns
                set(h(j,i),'pos',pos+[-0.05 0 -0.02 -0.01])  % for 4 columns
    end
end

if ~exist('Figure','dir')
    mkdir('Figure');
end
saveas(fig,[pwd '\Figure\Fig1_BDE.emf']);


