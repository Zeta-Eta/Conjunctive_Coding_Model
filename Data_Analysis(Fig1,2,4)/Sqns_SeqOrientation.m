% plot sequence accracy by sequence orientation (clockwise vs counterclockwise)
% regardless of starting point
% (assumped that stp and orientation are independent)
% different paritipants(group) on different subplot


clear;
datapath = [pwd '\AccuracyAndRT\'];
load([datapath 'Fig1.ACC.mat'])

%% Plot accuracy
participants = {'Adults','Children','MO','MG'};
parti_tag = {'Adults','Children','M1','M2'};

rule ='repeat';
touchtype_temp ='Combined';   %  ''freeTouch'|'Combined'
setsize = 4;
use_randomSelect = 0;

%% font size and other properties

title_fontsize = 18;
label_fontsize = 18;
ticklabel_fontsize = 18;
text_fontsize = 16;
legend_fontsize = 16;

axis_ticklength = [0.015,0.025];


axis_linewidth = 2;
plot_linewidth = 2.5;

map = [    185 170 130; ...
    50 139 135; ...
    
    115 60 20; ...
    165 110 70; ...
    215 160 120]./255; % ÇàÂÌ ¿¨Æä ¿§·È

fig = figure('Color',[1 1 1]);

set(gcf,'position',[0,0,260*size(participants,2),260]);

%% Plot Accuracy
for i = 1:size(participants,2)
    temp_max = 0;
    temp_min = 1;
    filepath = ['Data/' participants{i} '/'];
    if strcmp(participants{i},'ML')   % ML: no free touch- repeat data
        touchtype = 'errorStop';
    elseif contains(participants{i},'M')
        touchtype = touchtype_temp;
    elseif strcmp(participants{i},'Children') |  strcmp(participants{i},'Adults')
        touchtype = 'freeTouch';
    end
    
    % load pattern accuracy
    if use_randomSelect ==1  &  contains(participants{i},'M')
        datafile = [filepath, touchtype '_' rule '_' num2str(setsize) '_SqnsTable_random.mat'];
    else
        datafile = [filepath, touchtype '_' rule '_' num2str(setsize) '_SqnsTable.mat'];
    end
    load(datafile);
    
    
    trialnum = [SqnsTable.clctrialnum,SqnsTable.anticlctrialnum];
    data2plot = [SqnsTable.clcAC,SqnsTable.anticlcAC];
    
    data_mean = mean(data2plot,1);
    data_errorbar = std(data2plot,1)./sqrt(size(data2plot,1));
    
    % Shapiro-Wilk for normality
    %     [H_normal(i,1), pValue_normal(i,1), SWstatistic_normal(i,1)] = swtest(reshape(data2plot,size(data2plot,1)*size(data2plot,2),1),0.05);  % 0- normally distributed
    % test for starting points
    % ttest
    [H_ttest(i,1),sig(i,1)] = ttest2(data2plot(:,1),data2plot(:,2));
    
    % non-parametrical test
    [P_npara(i,1),tbl_npara{i,1},stats_npara{i,1}] = friedman(data2plot,1,'off');   % Friedman test
    cnpara{i,1} = multcompare(stats_npara{i,1},'Alpha',0.05,'CType','bonferroni','Display','off');
    sig_npara(i,1) = tbl_npara{i,1}{2,6};
    chisquare_npara(i,1) = tbl_npara{i,1}{2,5};
    kendallsw(i,1) = chisquare_npara(i,1)/(180*(2-1));
    
    temp_max = max(temp_max,max(data_mean+data_errorbar,[],[1 2]));
    temp_min = min(temp_min,min(data_mean-data_errorbar,[],[1 2]));
    
    h(i,1)= subplot(1,size(participants,2),i);
    pos = get(h(i,1),'position');
    set(h(i,1),'pos',pos+[0 0.15 -0.025 -0.23])
    errorbar([1:2],data_mean,data_errorbar,'LineWidth',plot_linewidth,'Color',map(i,:));
    % set ticks
    mini_tick = 0.2;
    y_scale = [0:mini_tick:1];
    set(gca,'XTick',[1:1:2],'YTick',y_scale,'XTickLabel',{'CW','CCW'},'LineWidth',axis_linewidth,...
        'FontSize',ticklabel_fontsize ,'tickdir','out','ticklength',axis_ticklength,...
        'Box','off');
    
    upper_limit = y_scale(min(find(y_scale >= temp_max)));
    lower_limit = y_scale(max(find(y_scale <= temp_min)));
    ylim([0.4,1]);
    xlim([0.5,2.5]);
    title(parti_tag{i},'FontName', 'Arial','FontWeight', 'bold','FontSize',title_fontsize);
    if sig_npara(i,1)<0.001
        sigflag = '***';
    elseif sig_npara(i,1)<0.01
        sigflag = '**';
    elseif sig_npara(i,1)<0.05
        sigflag = '*';
    else
        sigflag = 'n.s.';
    end
    text(1.2,min(upper_limit,1)-0.05*(min(upper_limit,1)-lower_limit),sigflag,'FontName','Arial','FontWeight', 'bold','FontSize',text_fontsize)
    hold off;
    
    
end

hold on

ax = axes(fig);
han = gca;
han.Visible = 'off';
han.XLabel.Visible = 'on';
han.YLabel.Visible = 'on';
xlb = xlabel('Orientation','FontName', 'Arial','FontWeight', 'bold','FontSize',label_fontsize);
ylb = ylabel('P(correct)','FontName', 'Arial','FontWeight', 'bold','FontSize',label_fontsize );
xlb.Position = [0.45, 0, 0];
ylb.Position = [-0.07, 0.5, 0];
get(fig,'paperposition');
hold off


