% plot statistics of 1) within pattern difference, 2) btw pattern
% difference
% for each participants
% clear;

use_randomSelect = 0;
% participants initials and code
participants = {'dq' 'fy' 'gjw','sh','xsk','wyz'};
parti_tag = {'s01' 's02' 's03' 's04' 's05' 's06'};
rule ='repeat';
touchtype_temp = 'Combined';  % 'Combined' | 'freeTouch'
setsize = 4;
N =6;

p_correction = 1; % whether correct for multiple comparions(within pattern difference in 30 patterns)

%% font size and other properties

title_fontsize = 18;
label_fontsize = 18;
ticklabel_fontsize = 18;
text_fontsize = 14;
legend_fontsize = 18;

axis_ticklength = [0.015 0.025];
axis_linewidth = 2;
plot_linewidth = 2.5;

%%
map = [185 170 130; ...
    50 139 135; ...
    115 60 20; ...
    165 110 70; ...
    215 160 120]./255; % ���� ���� ����

for i = 1:size(participants,2)

    filepath = ['Data/Adults2/'];
    
    touchtype = 'freeTouch';

    % random selected trials will be used only in monkeys
    if use_randomSelect ==1  &  contains(participants{i},'M')
        datafile = [filepath, touchtype '_' rule '_' num2str(setsize) '_' participants{i} '_SqnsTable_random.mat'];
    else
        datafile = [filepath, touchtype '_' rule '_' num2str(setsize) '_' participants{i} '_SqnsTable.mat'];
    end
    load(datafile);
    
    sqns_ACCmean = sqnsInptrnACtable.ptrnAC_sqns;
    sqns_ACCstd = sqnsInptrnACtable.ptrnSD_sqns;
    sqns_ACCsem = sqnsInptrnACtable.ptrnSE_sqns;
    
    selected_pat = 1:30;
    
    % Repeat-measure ANOVA
    for kk =1:length(selected_pat)
        name_temp{kk} =['pattern' num2str(kk)] ;
    end
    t = array2table( sqns_ACCmean(:,selected_pat),'VariableName',name_temp);  clear name_temp
    %     rm = fitrm(t,'pattern1-pattern30~1');
    rm = fitrm(t,['pattern1-pattern' num2str(length(selected_pat)) '~1']);
    tbl_anova{i,1} = ranova(rm);
    cANOVA{i,1} = multcompare(rm,'Time','ComparisonType','bonferroni');
    % non-parametrical test
    [P_npara(i,1),tbl_npara{i,1},stats_npara{i,1}] = friedman(sqns_ACCmean(:,selected_pat),1,'off');   % Friedman test
    cnpara{i,1} = multcompare(stats_npara{i,1},'Alpha',0.05,'CType','bonferroni','Display','off');
    chisquare_npara(i,1) = tbl_npara{i,1}{2,5};
    kendallsw(i,1) = chisquare_npara(i,1)/(12*(length(selected_pat)-1));
    
    % test: difference within patterns
    
    
    for pat = 1:length(selected_pat)
        pattern = selected_pat(pat);
        data2stat = [];
        %         datatbl = [];
        for gg = 1:12     % use non-paramatric test
            % reshape data:  col1 = acc; col2 = # condition
            if ~isempty(sqnsInptrnACtable.target_sqns{gg,pattern})
                sample_size(gg,pattern) = size(sqnsInptrnACtable.target_sqns{gg,pattern}(:,9),1);
                data2stat = [data2stat;[sqnsInptrnACtable.target_sqns{gg,pattern}(:,9),ones(sample_size(gg,pattern),1)*gg]];
           end
        end
        
        % test: within each pattern, difference among sequences
        [P(i,pattern),tbl{i,pattern},stats{i,pattern}] = kruskalwallis(data2stat(:,1),data2stat(:,2),'off'); % kruskal-wallis test
        chisquare(i,pattern) = tbl{i,pattern}{2,5};
        %%% calculate effect size
        % 1)formula suggested on https://www.researchgate.net/post/Anyone-know-how-to-calculate-eta-squared-for-a-Kruskal-Wallis-analysis
%         Fvalue(i,pattern) = chisquare(i,pattern)/(12-1);
%         etasquare(i,pattern) = (Fvalue(i,pattern)*(12-1))/(Fvalue(i,pattern)*(12-1)+sum(sample_size(:,pattern),1)-12);
        % 2) Tomczak & Tomczak 2014: The need to report effect size estimates revisited
        etasquare(i,pattern) = (chisquare(i,pattern)-(12-1))/(sum(sample_size(:,pattern),1)-12);
        
        %3) epsilon squared
%         epsilonsquare(i,pattern) = chisquare(i,pattern)/((sum(sample_size(:,pattern),1)^2-1)/(sum(sample_size(:,pattern),1)+1));
        
        %         [P_within(i,pattern),tbl_within{i,pattern},stats_within{i,pattern}]  = anova1(data2stat(:,1),cellstr(string(data2stat(:,2))),'off');   % one-way ANOVA
        %         [P_welch(i,pattern),F_welch(i,pattern),df1_welch(i,pattern),df2_welch(i,pattern)]  = wanova(data2stat(:,1),data2stat(:,2));   % welch ANOVA
    end
    
end


%% plot p value

fig  = figure('Color',[1 1 1]);
% set(gcf,'position',[0,0,800,400]);  
set(gcf,'position',[0,0,350,280]);   % vertical
hold on;
colormap(map)

%% plot within-
h1 = subplot(1,1,1);
pos1 = get(h1,'position');
set(h1,'pos',pos1+[0.05 +0.08 -0.1 -0.1])
hold on;
for i =1:size(participants,2)
    
    % line��p = 0.001  and  0.05
    if i ==1
        lin1 = line([0 size(participants,2)+.6],[-log10(0.001) -log10(0.001)],'LineWidth',2,'Color',[160 160 160]/255,'LineStyle','--');
        lin2 = line([0 size(participants,2)+.6],[-log10(0.05) -log10(0.05)],'LineWidth',2,'Color',[160 160 160]/255,'LineStyle','--');
        set(get(get(lin1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        set(get(get(lin2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        text(size(participants,2)-0.35,-log10(0.001)+0.55,'p = .001','FontSize',text_fontsize,'FontName', 'Arial','FontAngle','italic','FontWeight', 'normal')
        text(size(participants,2) -0.35,-log10(0.05)+0.55,'p = .05','FontSize',text_fontsize,'FontName', 'Arial','FontAngle','italic','FontWeight', 'normal')
    end
    
    % p-value: test 12 sequences in the same pattern
    Pval2plot = P(i,:)';    %%%%%%%%%%%%%%%%%%%%%%%%%    corrections?*30
    if p_correction == 1
        Pval2plot =Pval2plot*length(selected_pat);
    end
    AA(i,:) = Pval2plot;
    AAA(i) = length(selected_pat);
    Pval2plot(isnan(Pval2plot))=1;
    Pval2plot(Pval2plot>1)=1;
    Pval2plot = -log10(Pval2plot);
    Pcolor = repmat(map(1,:),size(Pval2plot,1),1);

    s(i) = scatter(rand(30,1)*0.35-0.2+i,Pval2plot,40,Pcolor,'filled');
    s(i).MarkerEdgeColor = [50 50 50]/255;
    s(i).LineWidth = 1.5;
    
    
    
    
end

set(gca,'YTick',[0:5:20],'XTick',[1:1:size(participants,2)],'XTickLabel',parti_tag,'XTickLabelRotation',-45,...
    'TickLength',[0 0],...
    'LineWidth',axis_linewidth,'Box','off','FontSize',ticklabel_fontsize);
ax = gca;
% ax.XAxis.FontWeight = 'bold';
% ax.XRuler.TickLabelGapOffset = 2;
% ax.XTick = ax.XTick - 0.3;
ax.YAxis.TickLength = axis_ticklength;
xlim([0.5,size(participants,2)+1]);
ylim([0,10]);
title('Within-patterns','FontSize',title_fontsize,'FontName', 'Arial','FontWeight', 'bold')
%      ylabel('-log10(p-value)','FontName', 'Arial','FontWeight', 'bold');
hold off


% set common labels
hold on
han = gca;
% han.Visible = 'off';
% han.Title.Visible = 'on';
% han.XLabel.Visible = 'on';
han.YLabel.Visible = 'on';
% title('Title','FontSize',16,'FontWeight', 'bold')
% xlb = xlabel('Complexity','FontName', 'Arial','FontWeight', 'bold','FontSize',16);
% xlb = xlabel('Linear integrated speed-accuracy score','FontSize',16,'FontWeight', 'bold');
ylb = ylabel('-log10(p-value)','FontSize',label_fontsize ,'FontName', 'Arial','FontWeight', 'bold','rotation',90);
ylb.Position = [-0.25, 5, 0];
get(fig,'paperposition');
hold off






