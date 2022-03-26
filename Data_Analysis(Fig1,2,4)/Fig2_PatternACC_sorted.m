%% Plot pattern accuracy
% legend(text label) of participants on the right side
% error bar = se of the 12 sequences in a pattern


close all;
addpath(genpath('DataManipulations'));

use_randomSelect = 0;

participants = {'Children','Adults','MO&MG'};
parti_tag = {'Children','Adults','Monkeys'};

rule ='repeat';
touchtype_temp = 'Combined';  % 'Combined' | 'freeTouch'
setsize = 4;
N =6;
Is_nomarlized  = 0;    % whether normalize accuracy
plot_errorbar = 1;    % whether plot error bar
line_fitting = 2;  % 0-hide fitting line;  >0 -N, degree

%% font size and other properties

% title_fontsize = 18;
label_fontsize = 18;
ticklabel_fontsize = 18;
legend_fontsize = 18;
axis_ticklength = [0.004,0.02];
axis_linewidth = 2;
plot_linewidth = 2.5;

graymap = [28 28 28
    95 95 95
    178 178 178
    ]/255;

map = [50 139 135; ...
    185 170 130; ...
    115 60 20; ...
    165 110 70; ...
    215 160 120]./255; % ÇàÂÌ ¿¨Æä ¿§·È

%% pattern ACC
fig = figure('Color',[1 1 1]);
set(gcf,'position',[0,0,600,330]);  % narrow
axes1 = axes('Parent',fig,'Position',[0.1 0.05 0.70 0.85],'Units','normalized');
hold on;
% colormap(graymap)
pattern_rank = [1:30]';
for i = 1:size(participants,2)
    
    filepath = ['Data/' participants{i} '/'];
    if strcmp(participants{i},'ML')   % ML: no free touch- repeat data
        touchtype = 'errorStop';
    elseif contains(participants{i},'M') 
        touchtype = touchtype_temp;
    elseif strcmp(participants{i},'Children') |  strcmp(participants{i},'Adults')
        touchtype = 'freeTouch';
    end
    
    % load accuracy and labels of each trial
    if use_randomSelect ==1  &  contains(participants{i},'M')    
        datafile = [filepath, touchtype '_' rule '_' num2str(setsize) '_Infotable_random.mat'];
    else
        datafile = [filepath, touchtype '_' rule '_' num2str(setsize) '_Infotable.mat'];
    end
    load(datafile);
    
    for pattern = 1:30
        patindex = find(Infotable.pattern_marker == pattern); % find all sequences in a specific pattern
        datatemp = Infotable(patindex,:);
        samplesize(pattern,1) = size(patindex,1);
        sqns = unique(datatemp.sequence_marker);   % find the 12 sequence types
        for sequence = 1:size(sqns,1)   % mean of each of the 12 sequences within the pattern
            acc(sequence,pattern) = mean(datatemp.sqns_acc(datatemp.sequence_marker == sqns(sequence,1)));
        end
    end
    
    data2plot = mean(acc,1);
    se2plot = std(acc,[],1)./sqrt(12);      % SE of the 12 sequence within the same pattern
    
    data2plot = data2plot';
    se2plot = se2plot';
    
    y_ticks = [-1:0.2:1];
    y_limit = [0.3,1.05];
    y_label = 'P(correct)';
    %%  plot : acc by pattern
    hold on;
    % sort pattern according the the accuracy of the first group
    if i ==1
        [~,pattern_rank(1:30,1)] = sort(data2plot,'descend');
        pattern_label =  mat2cell(string(num2str(pattern_rank(1:30,1))),30,1);
    end
    % scatter plot: sort by pattern accuracy
    partiplot(i)=scatter([1:30],data2plot(pattern_rank(:,1)),35,map(i,:),'LineWidth',plot_linewidth);
    if Is_nomarlized  ==0 & plot_errorbar == 1
        ff = errorbar(data2plot(pattern_rank(:,1)),se2plot(pattern_rank(:,1)),'o', 'LineWidth',plot_linewidth-0.5,'Color',map(i,:));
        set(get(get(ff,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
    
    % add fitting line
    if line_fitting > 0
        pp = polyfit([1:30]',data2plot(pattern_rank(:,1)),line_fitting);
        yy  = polyval(pp,[1:30]');
        f = plot([1:30]',yy,'Color',map(i,:),'LineWidth',plot_linewidth);
        set(get(get(f,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
    % add label on the right, next to the fitting line
    text(31,yy(end),parti_tag{1,i},'FontWeight', 'bold','FontSize',legend_fontsize,...
        'verticalAlignment','middle','horizontalAlignment','left')
    hold off 
end
hold on;
set(gca,'YTick', y_ticks,'XTick',[1:1:30],'XTickLabel',{},...
    'YAxisLocation','left','XAxisLocation','bottom','TickLength',axis_ticklength ,...
    'LineWidth',axis_linewidth,'Box','off','FontSize',ticklabel_fontsize);
xlim([0.3,30.7]);
ylim(y_limit);
ylabel(y_label,'FontName', 'Arial','FontWeight', 'bold','FontSize',label_fontsize);
hold off

if ~exist('Figure','dir')
mkdir('Figure');
end
saveas(gcf,[pwd '\Figure\Fig3_E.emf']);



%%   plot patterns in order ( errors may occurs in some matlab versions)
N = 6;
setsize = 4;
orientation = 0 ;   % 1- CW and CCW patterns, 0- patterns regardless of orientations

% generate patterns
v = num2cell(repmat(1:N,[setsize,1]),2);
[v{setsize:-1:1}] = ndgrid(v{:});
mdlTypes = reshape(cat(setsize,v{:}),[],setsize);
GeSequences = [];

for type = 1:size(mdlTypes,1)
    if size(unique(mdlTypes(type,:)),2)==setsize
        GeSequences = [GeSequences;mdlTypes(type,:)];
    end
end

[ptrnT,~] = sqns2ptrn(GeSequences,GeSequences,1,orientation);  % patterns generation,
patterns = unique(ptrnT,'rows');                                       % all possible patterns

% generate a hexagon
d=120:-60:-480;
x=cosd(d);
y=sind(d);



fig = figure('Color',[1 1 1]);
set(gcf,'position',[0,50,1000,80]); % narrow
pos = get(fig,'position');
set(fig,'pos',pos+[0 0 pos(3)*0.6, 0]);
% arrange subplot position,
fig_order = [1:30];

hold on;

for i =1:size(patterns,1)
   h(i) = subplot(1,size(patterns,1),fig_order(i));
    num_pattern = pattern_rank(i,1);
    % plot hexagon
    p(i) = scatter(x,y,50,[72 175 124]/255,'filled');
    
    axis([-1.3 1.3 -1.3 1.3]);
    axis equal
    % add lines for patterns
    for j  =1:size(patterns,2)-1
        line(x(patterns(num_pattern,j:j+1)),y(patterns(num_pattern,j:j+1)),'LineWidth',2.8,'Color',[16 15 84]/255);
    end
    
    set(gca,'YTick',[0:0.25:1],'XTick',[1:1:30],'TickLength',[0,0],...
        'LineWidth',1,'Box','off','Visible','off');
end
hold off
% adjust position
hold on
for i =1:size(patterns,1)
    pos = get(h(i),'position');
    set(h(i),'pos',pos + [0 0 pos(3)*1.05 0])
end
hold off

if ~exist('Figure','dir')
mkdir('Figure');
end
saveas(gcf,[pwd '\Figure\Fig3_E_xlabel.emf']);


