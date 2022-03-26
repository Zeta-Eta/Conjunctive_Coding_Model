%% Plot chunking mode RT
%

clear;
close all;
addpath(genpath('DataManipulations'));
use_randomSelect = 0;    % whether use the randomly selected dataset of monkeys (equal trial number in each monkey(in each touch type))

participants = {'Adults','Children','MO&MG'};
parti_tag = {'Adults','Children','Monkeys'};

plotall = 0;   % plot RT of 30 patterns in seperate figures
plotalllines =0; % plot all lines(patterns) in each cluster

rule ='repeat';
touchtype_temp = 'freeTouch' ;  %  'freeTouch' | 'Combined' | 'errorStop'
setsize = 4;
N =6;

%% statistics
stats_table = [];
for i = 1:size(participants,2)
    filepath = ['Data/' participants{i} '/'];
    if strcmp(participants{i},'ML')   % ML: no free touch- repeat data
        touchtype = 'errorStop';
    elseif contains(participants{i},'M')
        touchtype = touchtype_temp;
    elseif strcmp(participants{i},'Children') |  strcmp(participants{i},'Adults')
        touchtype = 'freeTouch';
    end
    % random selected trials will be used only in monkeys
    if use_randomSelect ==1  &  contains(participants{i},'M')
        datafile = [filepath, touchtype '_' rule '_' num2str(setsize) '_SqnsRTTable_random.mat'];
    else
        datafile = [filepath, touchtype '_' rule '_' num2str(setsize) '_SqnsRTTable.mat'];
    end
    
    % load pattern  response time
    load(datafile);
    
    data2plot{i} = ptrnRTtable.ptrnRT;
    error2plot{i} = ptrnRTtable.ptrnRTSE;  % se of sequence in the same pattern
    sqnsdata{i} = sqnsInptrnRTtable.ptrnRT_sqns;
    
    for pattern = 1:30
        sequence_rt = squeeze(sqnsdata{i}(pattern,:,:));
        H_normal(i,pattern)= lillietest(reshape(sequence_rt,size(sequence_rt,1)*size(sequence_rt,2),1));  % 0- normally distributed
        
        
        [P_anova(i,pattern),tbl_anova{i,pattern},stats_anova{i,pattern}] = anova1(sequence_rt,[],'off');   % one-way ANOVA
        cANOVA{i,pattern} = multcompare(stats_anova{i,pattern},'Alpha',0.05,'CType','bonferroni','Display','off');
        
        [P_kw(i,pattern),tbl_kw{i,pattern},stats_kw{i,pattern}] = kruskalwallis(sequence_rt,[],'off');   % kruskal-wallis test
        ckw{i,pattern} = multcompare(stats_kw{i,pattern},'Alpha',0.05,'CType','bonferroni','Display','off');
        
        stats_table = [stats_table;[i,pattern,H_normal(i,pattern),P_anova(i,pattern),cANOVA{i,pattern}(:,6)',P_kw(i,pattern),ckw{i,pattern}(:,6)']];
    end
    
end
stats_table = array2table(stats_table, 'VariableNames',...
    {'participants','patternIndex','normalityTest',...
    'ANOVA','Pairwise1vs2','Pairwise1vs3','Pairwise1vs4','Pairwise2vs3','Pairwise2vs4','Pairwise3vs4',...
    'kruskalwallis','kwPairwise1vs2','kwPairwise1vs3','kwPairwise1vs4','kwPairwise2vs3','kwPairwise2vs4','kwPairwise3vs4'});
Patterns = ptrnRTtable.patterns2;  % patterns are listed in identical order in all files

% %% Complexity
load('ChunkDist.mat');
comp = sum(ChunkDist,2);

%% font size and other properties

title_fontsize = 18;
label_fontsize = 18;
ticklabel_fontsize = 18;
text_fontsize = 14;
legend_fontsize = 16;
axis_ticklength = [0.015,0.02];
axis_linewidth = 2;
plot_linewidth = 2.5;

colormap =[linspace(250,0,7)',linspace(0,0,7)',linspace(0,250,7)']/255;   %

map = [185 170 130; ...
    50 139 135; ...
    115 60 20]./255; % ¿¨Æä ÇàÂÌ ¿§·È


y_ticks = [-2:0.2:2];
y_limit = [0.2,0.8];
y_label = 'Time/s';

%%  plot : RT by 30 pattern
if plotall == 1
    figure('Color',[1 1 1])
    %%%%%
    nrow = 5;
    ncol = 6;
    set(gcf,'position',[0,0,250*ncol,220* nrow]);
    pattern_rank = [1:30]';
    for jj = 1:30
        subplot(nrow,ncol,jj)
        hold on;
        % line
        partiplot= errorbar( [data2plot{1}(pattern_rank(jj,1),:);data2plot{2}(pattern_rank(jj,1),:);data2plot{3}(pattern_rank(jj,1),:)]',...
            [error2plot{1}(pattern_rank(jj,1),:);error2plot{2}(pattern_rank(jj,1),:);error2plot{3}(pattern_rank(jj,1),:)]',...
            'LineWidth',2);
        for kk =1:size(participants,2)
            eval(['partiplot(' num2str(kk) ').Color = map(' num2str(kk) ',:);']);
        end
        
        set(gca,'YTick', y_ticks,'XTick',[1:1:30],'XTickLabel',{},...
            'YAxisLocation','left','XAxisLocation','bottom','TickLength',axis_ticklength,...
            'LineWidth',axis_linewidth,'Box','off','FontSize',ticklabel_fontsize);
        
        xlim([0.3,4.7]);
        ylim(y_limit);
        
        if mod(jj,ncol) == 1 & ceil(jj/ncol) == floor(nrow/2)+1
            ylabel(y_label,'FontName', 'Arial','FontWeight', 'bold','FontSize',label_fontsize);
        end
        title(num2str(ptrnRTtable.patterns2(pattern_rank(jj,1),:)),'FontSize',title_fontsize)
        hold off
    end
    colormap(map);
    legend([partiplot(2) partiplot(1) partiplot(3)],{parti_tag{1,2},parti_tag{1,1},parti_tag{1,3}},'Box','off','Position',[0.5 0.88 0.1 0.2],'Orientation','horizontal','FontSize',legend_fontsize);
end

%%  plot : RT by pattern clusters
cluster_type = 'config';
[cluster,cluster_tag,pattern_rank ] = CalCluster(Patterns,cluster_type); % 'config'|'chunk_num' |'comp_ranking' |'clustering'

% define gray patch ( use to mark chunks ordinal position)
if strcmp(cluster_type,'config')
    for k  = 1:length(cluster_tag)
        if strcmp(cluster_tag{k},'1-1-1-1')
            patch_num(k) = 0;
            patch_start{k} = [0]; patch_end{k} = [0];
        elseif strcmp(cluster_tag{k},'1-2-1')
            patch_num(k) = 1;
            patch_start{k} = [2]; patch_end{k} = [3];
        elseif strcmp(cluster_tag{k},'1-1-2')
            patch_num(k) = 1;
            patch_start{k} = [3]; patch_end{k} = [4];
        elseif strcmp(cluster_tag{k},'2-1-1')
            patch_num(k) = 1;
            patch_start{k} = [1]; patch_end{k} = [2];
        elseif strcmp(cluster_tag{k},'2-2')
            patch_num(k) = 2;
            patch_start{k} = [1,3]; patch_end{k} = [2,4];
        elseif strcmp(cluster_tag{k},'1-3')
            patch_num(k) = 1;
            patch_start{k} = [2]; patch_end{k} = [4];
        elseif strcmp(cluster_tag{k},'3-1')
            patch_num(k) = 1;
            patch_start{k} = [1]; patch_end{k} = [3];
        elseif strcmp(cluster_tag{k},'[¡À1]^3')
            patch_num(k) = 1;
            patch_start{k} = [1]; patch_end{k} = [4];
        end
        
    end
end

%%  grouped by cluster, each line = each pattern
if plotalllines ==1
    figure('Color',[1 1 1])
    nrow = length(unique(cluster));
    ncol = size(participants,2);
    set(gcf,'position',[0,0,330*ncol,250*nrow]);  % original
    stats_table_cluster = [];
    
    % bigtable = [];
    for i = 1:ncol    % i-participant
        for jj = 1:nrow      % jj - cluster
               cluster_data{i,jj} = [];
            % plot by clusters
            subplot(nrow,ncol,i+ncol*(jj-1))
            hold on;
            cluster_index = find(cluster==jj);
            % extract complexity
            cluster_complexity(i,jj) = mean(comp(cluster_index));
            cluster_complexity_sd(i,jj) = std(comp(cluster_index));
            if cluster_complexity_sd(i,jj) == 0
                cluster_complexity_text{i,jj} = sprintf('%0.2f',cluster_complexity(i,jj));
            else
                cluster_complexity_text{i,jj} = sprintf('%0.2f ¡À %0.2f ',cluster_complexity(i,jj),cluster_complexity_sd(i,jj));
            end
            
            % extract cluster data, row = sequences(grouped by pattern), col= order
            for nn = 1:length(cluster_index)
                cluster_data{i,jj} = [cluster_data{i,jj};squeeze(sqnsdata{i}(cluster_index(nn),:,:))];
            end
             %%% run stats:
            % regard pattern as a factor, each sequence as an observation
            %             H_normal_cluster(i,jj)= lillietest(reshape(cluster_data{i,jj},size(cluster_data{i,jj},1)*size(cluster_data{i,jj},2),1));  % 0- normally distributed
            % Shapiro-Wilk for normality
            H_normal_cluster(i,jj)= swtest(reshape(cluster_data{i,jj},size(cluster_data{i,jj},1)*size(cluster_data{i,jj},2),1));  % 0- normally distributed
            
            
            if length(cluster_index)==1
                [P_anova_cluster{i,jj},tbl_anova_cluster{i,jj},stats_anova_cluster{i,jj}] = anova1(cluster_data{i,jj},[],'off');   % one-way ANOVA, order
                P_anova_cluster{i,jj}= [P_anova_cluster{i,jj},NaN,NaN];
                %                 [P_npara_cluster{i,jj},tbl_npara_cluster{i,jj},stats_npara_cluster{i,jj}] = kruskalwallis(cluster_data{i,jj},[],'off');   % kruskal-wallis test
                [P_npara_cluster{i,jj},tbl_npara_cluster{i,jj},stats_npara_cluster{i,jj}] = friedman(cluster_data{i,jj},1,'off');   % Friedman test
            else
                [P_anova_cluster{i,jj},tbl_anova_cluster{i,jj},stats_anova_cluster{i,jj}] = anova2(cluster_data{i,jj},12,'off');   % two-way ANOVA, order * pattern
                [P_npara_cluster{i,jj},tbl_npara_cluster{i,jj},stats_npara_cluster{i,jj}] = friedman(cluster_data{i,jj},12,'off');   % Friedman test
            end
            % mulicomparison among orders
            cANOVA_cluster{i,jj} = multcompare(stats_anova_cluster{i,jj},'Alpha',0.05,'CType','bonferroni','Display','off');
            cnpara_cluster{i,jj} = multcompare(stats_npara_cluster{i,jj},'Alpha',0.05,'CType','bonferroni','Display','off');  %  pval =NaN
            % compute adjusted pvalue manually
            for tt = 1:size( cnpara_cluster{i,jj},1)
                %                 cnpara_cluster{i,jj}(tt,6)=ranksum(cluster_data{i,jj}(:,cnpara_cluster{i,jj}(tt,1)),cluster_data{i,jj}(:,cnpara_cluster{i,jj}(tt,2)));
                cnpara_cluster{i,jj}(tt,6)=friedman(cluster_data{i,jj}(:,[cnpara_cluster{i,jj}(tt,1),cnpara_cluster{i,jj}(tt,2)]),1,'off');
                cnpara_cluster{i,jj}(tt,6) =min(cnpara_cluster{i,jj}(tt,6)*size( cnpara_cluster{i,jj},1),1);
            end
            
            
            stats_table_cluster = [stats_table_cluster;[i,jj,H_normal_cluster(i,jj),...
                P_anova_cluster{i,jj},cANOVA_cluster{i,jj}(:,6)',...
                P_npara_cluster{i,jj},cnpara_cluster{i,jj}(:,6)']];
            
            
            temp_min = min(data2plot{i}(pattern_rank(cluster_index,1),:)'-error2plot{i}(pattern_rank(cluster_index,1),:)',[],'all');
            temp_max = max(data2plot{i}(pattern_rank(cluster_index,1),:)'+error2plot{i}(pattern_rank(cluster_index,1),:)',[],'all');
            y_limit = [temp_min-0.05,temp_max+0.05];
            y_range = y_limit(2)-y_limit(1);
            
            %%% line: each line = each pattern
            e = errorbar( (repmat(1:4,length(cluster_index),1)+repmat([0:(0.4-0)/length(cluster_index):0.4-(0.4-0)/length(cluster_index)]',1,4))',...
                data2plot{i}(pattern_rank(cluster_index,1),:)',error2plot{i}(pattern_rank(cluster_index,1),:)','LineWidth',plot_linewidth);
            for figindex = 1:length(e)
                e(figindex).Color = colormap(figindex,:);
            end
            
            if i ==1 & jj == nrow   % lower right corner
                set(gca,'YTick', [floor(temp_min/0.05)*0.05:floor((temp_max-temp_min)/0.05)*0.05:2],'XTick',[1:4],...
                    'TickLength',axis_ticklength,'LineWidth',axis_linewidth,'Box','off','FontSize',ticklabel_fontsize);
            else
                set(gca,'YTick', [floor(temp_min/0.05)*0.05:floor((temp_max-temp_min)/0.05)*0.05:2],'XTick',[1:4],'XTickLabel',{},...
                    'TickLength',axis_ticklength,'LineWidth',axis_linewidth,'Box','off','FontSize',ticklabel_fontsize);
            end

            xlim([0.5,4.5]);
            ylim(y_limit);
            if i ==1
                if mod(nrow,2)~=0 & jj == floor(nrow/2)+1
                    ylabel(y_label,'FontName', 'Arial','FontWeight', 'bold','FontSize',label_fontsize);
                elseif  mod(nrow,2)==0 & jj == nrow/2 + 1
                    text(-1,0.65,y_label,'FontSize',label_fontsize,'FontName', 'Arial','FontWeight', 'bold','rotation',90)
                end
            elseif i == ncol
                text(4.7,(y_limit(2)-y_limit(1))/2+y_limit(1),cluster_tag{jj},'FontSize',text_fontsize,'FontName', 'Arial','FontWeight', 'bold','HorizontalAlignment','left','VerticalAlignment','middle')
            end
            if jj ==1
                title(parti_tag{i})
            end
            hold off
        end
    end
    stats_table_cluster = array2table(stats_table_cluster, 'VariableNames',...
        {'participants','cluster','normalityTest',...
        'ANOVA_pattern','ANOVA_order','ANOVA_interact','Pairwise1vs2','Pairwise1vs3','Pairwise1vs4','Pairwise2vs3','Pairwise2vs4','Pairwise3vs4',...
        'npara_order','nparaPairwise1vs2','nparaPairwise1vs3','nparaPairwise1vs4','nparaPairwise2vs3','nparaPairwise2vs4','nparaPairwise3vs4'});
end

%%  grouped by cluster, each line = each cluster
% mean of all sequences

fig = figure('Color',[1 1 1]);
nrow = length(unique(cluster));
ncol = size(participants,2);
% set(gcf,'position',[0,0,240*ncol,220*nrow]);  % original
set(gcf,'position',[0,0,260*ncol,220*nrow]);
stats_table_cluster2 = [];
cluster_complexity =[];
for i = 1:ncol    % i-participant
    % mean of all sequences
    pari_reshape = [];
    for kk  = 1:size(sqnsdata{i},1)
        pari_reshape = [pari_reshape; squeeze(sqnsdata{i}(kk,:,:))];
    end
    pari_mean = nanmean(pari_reshape(:,1:4),1);   % mean RTs of all sequences
    pari_sd = nanstd(pari_reshape(:,1:4),1);
    for jj = 1:nrow  % jj-cluster
        cluster_data{i,jj} = [];
        % plot by clusters
        h = subplot(nrow,ncol,i+ncol*(jj-1));
        pos=get(h,'position');
        set(h,'pos',pos+[0 0 -0.03 0])
        hold on;
        cluster_index = find(cluster==jj);

        % extract cluster data, row = sequences(grouped by pattern), col= order
        for nn = 1:length(cluster_index)
            cluster_data{i,jj} = [cluster_data{i,jj};squeeze(sqnsdata{i}(cluster_index(nn),:,:))];
        end
        % substract mean of all sequences ()
        cluster_data{i,jj} = (cluster_data{i,jj}- pari_mean)./pari_sd;

        %%% run stats:
        % neglect pattern(i.e. collapse all data in the same cluster), each sequence as an observation
        %         H_normal_cluster2(i,jj)= lillietest(reshape(cluster_data{i,jj},size(cluster_data{i,jj},1)*size(cluster_data{i,jj},2),1));  % 0- normally distributed
        % Shapiro-Wilk for normality
        H_normal_cluster2(i,jj)= swtest(reshape(cluster_data{i,jj},size(cluster_data{i,jj},1)*size(cluster_data{i,jj},2),1));  % 0- normally distributed
        
        
        [P_anova_cluster2{i,jj},tbl_anova_cluster2{i,jj},stats_anova_cluster2{i,jj}] = anova1(cluster_data{i,jj},[],'off');   % one-way ANOVA, order
        [P_npara_cluster2{i,jj},tbl_npara_cluster2{i,jj},stats_npara_cluster2{i,jj}] = friedman(cluster_data{i,jj},1,'off');   % Friedman test
        %         [P_npara_cluster2{i,jj},tbl_npara_cluster2{i,jj},stats_npara_cluster2{i,jj}] = kruskalwallis(cluster_data{i,jj},[],'off');   % kruskal-wallis test
        % mulicomparison among orders
        cANOVA_cluster2{i,jj} = multcompare(stats_anova_cluster2{i,jj},'Alpha',0.05,'CType','bonferroni','Display','off');
        cnpara_cluster2{i,jj} = multcompare(stats_npara_cluster2{i,jj},'Alpha',0.05,'CType','bonferroni','Display','off');    % pval = NaN
        % compute adjusted pvalue manually
        for tt = 1:size( cnpara_cluster2{i,jj},1)
                        cnpara_cluster2{i,jj}(tt,6)=signrank(cluster_data{i,jj}(:,cnpara_cluster2{i,jj}(tt,1)),cluster_data{i,jj}(:,cnpara_cluster2{i,jj}(tt,2)));
%             cnpara_cluster2{i,jj}(tt,6)=friedman(cluster_data{i,jj}(:,[cnpara_cluster2{i,jj}(tt,1),cnpara_cluster2{i,jj}(tt,2)]),1,'off');
%             cnpara_cluster2{i,jj}(tt,6) =min(cnpara_cluster2{i,jj}(tt,6)*size( cnpara_cluster2{i,jj},1),1);  % p value corrections
        end
        
        stats_table_cluster2 = [stats_table_cluster2;[i,jj,H_normal_cluster2(i,jj),...
            P_anova_cluster2{i,jj},cANOVA_cluster2{i,jj}(:,6)',...
            P_npara_cluster2{i,jj},cnpara_cluster2{i,jj}(:,6)']];
        stats = cnpara_cluster2{i,jj};  % use for plotting
        %
        % exclude 0
        cluster_data{i,jj}(sum(cluster_data{i,jj}==0,2)==4,:)=[];
        
        aa_mean(i,jj) = mean(mean(cluster_data{i,jj},2));  % grand mean of all RTs
        
        data_mean = mean(cluster_data{i,jj});
        data_error = std(cluster_data{i,jj})/sqrt(size(cluster_data{i,jj},1));   % se of  sequence in the same cluster
        upperbound = data_mean+data_error;
        lowerbound = data_mean -data_error;
        temp_min = min(lowerbound,[],'all');
        temp_max = max(upperbound,[],'all');
        
        y_limit = [temp_min-0.05,temp_max+0.05];
        y_range = y_limit(2)-y_limit(1);
        
        statvalue{jj} = [];
        % shading: marks chunks, at bottom layer (of the figure)
        if exist('patch_num','var')
            for pat = 1:patch_num(jj)
                XX = [patch_start{jj}(pat):patch_end{jj}(pat),patch_end{jj}(pat):-1:patch_start{jj}(pat)];
                YY = [data_mean(patch_start{jj}(pat):patch_end{jj}(pat))-0.3,data_mean(patch_end{jj}(pat):-1:patch_start{jj}(pat))+0.3];
                h=patch(XX,YY,[210,210,210]/255) ;   % grey
                set(h,'edgealpha',0,'facealpha',1)
                
                temp_row = find(sum(stats(:,1:2) == [patch_start{jj}(pat),patch_end{jj}(pat)] ,2) ==2);
                statvalue{jj}(pat) = stats(temp_row,6);
                stat_x{jj}(pat) = patch_start{jj}(pat) + 0.6;
                stat_y{jj}(pat) = mean(data_mean(patch_start{jj}(pat):patch_end{jj}(pat)))+0.8;
            end
        end
        
        
        %%% line: each line = each cluster
        line([0,5],[0 0],'LineWidth',1.5,'Color',[128,128,128]/255)
        e= errorbar(data_mean,data_error,'LineWidth',plot_linewidth);
        e.Color = map(i,:);

        mini_tick = 0.4;
        if jj == nrow
            set(gca,'YTick', [-1:1:1],'XTick',[1:4],...
                'TickLength',axis_ticklength,'LineWidth',axis_linewidth,'Box','off','FontSize',ticklabel_fontsize);
        else
            set(gca,'YTick', [-1:1:1],'XTick',[1:4],'XTickLabel',{},...
                'TickLength',axis_ticklength,'LineWidth',axis_linewidth,'Box','off','FontSize',ticklabel_fontsize);
        end
        xlim([0.5,4.5]);
        %         ylim([-1 1]);
        ylim([-1.2 1.2]);
        if jj ==1
            title(parti_tag{i},'FontSize',title_fontsize,'FontName', 'Arial','FontWeight', 'bold')
        end
        if ~isempty(statvalue{jj})
            for marker = 1:length(statvalue{jj})
                if statvalue{jj}(marker) < 0.001
                    stattext = '***'; statfontsize = 16;
                elseif statvalue{jj}(marker) < 0.01
                    stattext = '***';statfontsize = 16;
                elseif statvalue{jj}(marker) < 0.05
                    stattext = '**';statfontsize = 16;
                else
                    stattext = 'n.s.';statfontsize = 14;
                end
                text(stat_x{jj}(marker),stat_y{jj}(marker),stattext,'FontSize',statfontsize,'FontName', 'Arial','FontWeight', 'bold','HorizontalAlignment','center')
            end
        end
        
        hold off
    end
end
hold on

ax = axes(fig);
han = gca;
han.Visible = 'off';
han.XLabel.Visible = 'on';
han.YLabel.Visible = 'on';
xlb = xlabel('Order','FontName', 'Arial','FontWeight', 'bold','FontSize',label_fontsize);
ylb = ylabel('zscore','FontName', 'Arial','FontWeight', 'bold','FontSize',label_fontsize );
xlb.Position = [0.5, -0.04, 0];
ylb.Position = [-0.1, 0.5, 0];
get(fig,'paperposition');
hold off

stats_table_cluster2 = array2table(stats_table_cluster2, 'VariableNames',...
    {'participants','cluster','normalityTest',...
    'ANOVA_order','Pairwise1vs2','Pairwise1vs3','Pairwise1vs4','Pairwise2vs3','Pairwise2vs4','Pairwise3vs4',...
    'npara_order','nparaPairwise1vs2','nparaPairwise1vs3','nparaPairwise1vs4','nparaPairwise2vs3','nparaPairwise2vs4','nparaPairwise3vs4'});



