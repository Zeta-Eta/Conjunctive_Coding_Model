% plot statistics of within pattern difference
% test the difference with factor 1£© starting point, or 2) orientation

clear;

 use_randomSelect = 0;
participants = {'Adults','Children','MO','MG'};
parti_tag = {'Adults','Children','M1','M2'};
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
    215 160 120]./255; % ¿¨Æä ÇàÂÌ ¿§·È
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
        datafile = [filepath, touchtype '_' rule '_' num2str(setsize) '_Infotable_random.mat'];
    else
        datafile = [filepath, touchtype '_' rule '_' num2str(setsize) '_Infotable.mat'];
    end
    load(datafile);
   
 
     % test: difference within patterns
    for pattern = 1:30
        patindex = find(Infotable.pattern_marker == pattern);
        data2stat = [];
        datatemp = Infotable(patindex,:);
        
        for gg = 1:2     % use non-paramatric test, orientation
            % reshape data:  col1 = acc; col2 = # condition
            if ~isempty(Infotable.sqns_acc)
                sample_size_ori(gg,pattern) = size(datatemp.sqns_acc(datatemp.orientation_marker == gg),1);
                data2stat = [data2stat;[datatemp.sqns_acc(datatemp.orientation_marker == gg),ones(sample_size_ori(gg,pattern),1)*gg]];
            end
        end
        
        % test: within each pattern, difference among sequences
        [P_ori(i,pattern),tbl_ori{i,pattern},stats_ori{i,pattern}] = kruskalwallis(data2stat(:,1),data2stat(:,2),'off'); % kruskal-wallis test
        chisquare_ori(i,pattern) = tbl_ori{i,pattern}{2,5};
        etasquare_ori(i,pattern) = (chisquare_ori(i,pattern)-(12-1))/(sum(sample_size_ori(:,pattern),1)-12);

        
         data2stat = [];
         % use non-paramatric test, starting point
         for gg = 1:6
                         % reshape data:  col1 = acc; col2 = # condition
            if ~isempty(Infotable.sqns_acc)
                sample_size_stp(gg,pattern) = size(datatemp.sqns_acc(datatemp.stp_marker == gg),1);
                data2stat = [data2stat;[datatemp.sqns_acc(datatemp.stp_marker == gg),ones(sample_size_stp(gg,pattern),1)*gg]];
            end
         end
         [P_stp(i,pattern),tbl_stp{i,pattern},stats_stp{i,pattern}] = kruskalwallis(data2stat(:,1),data2stat(:,2),'off'); % kruskal-wallis test
         chisquare_stp(i,pattern) = tbl_stp{i,pattern}{2,5};
         etasquare_stp(i,pattern) = (chisquare_stp(i,pattern)-(12-1))/(sum(sample_size_stp(:,pattern),1)-12);
        
    end
    Stp_sigindex{i,1} = find(P_stp(i,:)*30*p_correction < 0.05)';
    
end


%% plot p value

fig  = figure('Color',[1 1 1]);
set(gcf,'position',[0,0,400,600]);  
hold on;
colormap(map)

%% plot within-
h1 = subplot(2,1,1);
pos1 = get(h1,'position');
set(h1,'pos',pos1+[0.05 +0.03 -0.08 0])
hold on;
for i =1:size(participants,2)
    
    % line£ºp = 0.001  and  0.05
    if i ==1
        lin1 = line([0 size(participants,2)+.6],[-log10(0.001) -log10(0.001)],'LineWidth',2,'Color',[160 160 160]/255,'LineStyle','--');
        lin2 = line([0 size(participants,2)+.6],[-log10(0.05) -log10(0.05)],'LineWidth',2,'Color',[160 160 160]/255,'LineStyle','--');
        set(get(get(lin1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        set(get(get(lin2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        text(size(participants,2)+.65,-log10(0.001)+0.2,'p = .001','FontSize',text_fontsize,'FontName', 'Arial','FontAngle','italic','FontWeight', 'normal')
        text(size(participants,2)+.65,-log10(0.05)+0.2,'p = .05','FontSize',text_fontsize,'FontName', 'Arial','FontAngle','italic','FontWeight', 'normal')
    end
    
    % p-value: test orientation in the same pattern
    Pval2plot = P_ori(i,:)';    %%%%%%%%%%%%%%%%%%%%%%%%%    corrections?*30  
    if p_correction == 1
        Pval2plot =Pval2plot*30;
    end
    Pval2plot(isnan(Pval2plot))=1;
    Pval2plot(Pval2plot>1)=1;
    Pval2plot = -log10(Pval2plot);
    Pcolor = repmat(map(i,:),size(Pval2plot,1),1);

    s(i) = scatter(rand(30,1)*0.4-0.2+i,Pval2plot,40,Pcolor,'filled');
    s(i).MarkerEdgeColor = [50 50 50]/255;
    s(i).LineWidth = 1.5;
    
    
    
end
set(gca,'YTick',[0:5:20],'XTick',[1:1:3],'XTickLabel',{''},...
    'TickLength',[0 0],...
    'LineWidth',axis_linewidth,'Box','off','FontSize',ticklabel_fontsize);
ax = gca;
ax.YAxis.TickLength = axis_ticklength;
xlim([0.5,size(participants,2)+1]);
ylim([0,20]);
title('Orientation','FontSize',title_fontsize,'FontName', 'Arial','FontWeight', 'bold')
hold off

%% plot Between-
h2 = subplot(2,1,2);
pos2 = get(h2,'position');
set(h2,'pos',pos2+[0.05 +0.05 -0.08 0])
hold on

for i =1:size(participants,2)
    % line£ºp = 0.001  and  0.05
    if i ==1
        lin1 = line([0 size(participants,2)+.6],[-log10(0.001) -log10(0.001)],'LineWidth',2,'Color',[160 160 160]/255,'LineStyle','--');
        lin2 = line([0 size(participants,2)+.6],[-log10(0.05) -log10(0.05)],'LineWidth',2,'Color',[160 160 160]/255,'LineStyle','--');
        set(get(get(lin1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        set(get(get(lin2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        text(size(participants,2)+.65,-log10(0.001)+0.2,'p = .001','FontSize',text_fontsize,'FontName', 'Arial','FontAngle','italic','FontWeight', 'normal')
        text(size(participants,2)+.65,-log10(0.05)+0.2,'p = .05','FontSize',text_fontsize,'FontName', 'Arial','FontAngle','italic','FontWeight', 'normal')
    end
    
    % p-value: test starting point in the same pattern
    Pval2plot = P_stp(i,:)';    %%%%%%%%%%%%%%%%%%%%%%%%%    corrections?*30  
    if p_correction == 1
        Pval2plot =Pval2plot*30;
    end
    Pval2plot(isnan(Pval2plot))=1;
    Pval2plot(Pval2plot>1)=1;
    Pval2plot = -log10(Pval2plot);
    Pcolor = repmat(map(i,:),size(Pval2plot,1),1);

    s(i) = scatter(rand(30,1)*0.4-0.2+i,Pval2plot,40,Pcolor,'filled');
    s(i).MarkerEdgeColor = [50 50 50]/255;
    s(i).LineWidth = 1.5;
    
end
set(gca,'YTick',[0:5:20],'XTick',[1:1:size(participants,2)],'XTickLabel',parti_tag,'XTickLabelRotation',-30,...
    'TickLength',[0 0],...
    'LineWidth',2,'Box','off','FontSize',ticklabel_fontsize);

ax = gca;
ax.XAxis.FontWeight = 'bold';
ax.XTick = ax.XTick - 0.3;
ax.YAxis.TickLength = axis_ticklength;
xlim([0.5,size(participants,2)+1]);
ylim([0,20]);
title('Starting point','FontSize',title_fontsize ,'FontName', 'Arial','FontWeight', 'bold')
hold off;

% set common labels
hold on
han = gca;
han.YLabel.Visible = 'on';
ylb = ylabel('-log10(p-value)','FontSize',label_fontsize ,'FontName', 'Arial','FontWeight', 'bold','rotation',90);
ylb.Position = [-0.05, 25, 0];
get(fig,'paperposition');
hold off


