% plot correlation between chunk-size-based complexity and accuracy and RT
clear; 
 use_randomSelect = 0;

%% Plot pattern accuracy
close all;


participants = {'Children','Adults','MO&MG'};
parti_tag = {'Children','Adults','Monkeys'};

rule ='repeat';
touchtype_temp = 'freeTouch';   % 'Combined'|'freeTouch'
setsize = 4;
N =6;
Is_nomarlized  = 0;    % whether normalize accuracy
plot_errorbar = 1;    % whether plot error bar
line_fitting = 1;  % 0-hide fitting line;  >0 -N, degree


%% font size and other properties

title_fontsize = 18;
label_fontsize = 16;
ticklabel_fontsize = 16;
text_fontsize = 14;
legend_fontsize = 18;
axis_linewidth = 2;
plot_linewidth = 3;


map = [50 139 135; ...
    185 170 130; ...
    115 60 20]./255; % ÇàÂÌ ¿¨Æä ¿§·È



%% pattern ACC

fig = figure('Color',[1 1 1]);
set(gcf,'position',[0,0,300*2,260]);  % original
hold on;
colormap(map)
pattern_rank = [1:30]';
h(1) = subplot(121);
pos{1}=get(h(1),'position');
for i = 1:size(participants,2)
    
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

    % normalization
    temp_mean = mean(ptrnACtable.ptrnAC);   % mean of all patterns
    temp_sd = std(ptrnACtable.ptrnAC);    % sd 
    norm_ptrnAC = (ptrnACtable.ptrnAC-temp_mean)./temp_sd;   % normalization
    
    if Is_nomarlized  ==1
        data2plot = norm_ptrnAC;
        y_ticks = [-10:1:10];
        y_limit = [-3,3];
        y_label = 'Normalized Accuracy';
    else
        data2plot = ptrnACtable.ptrnAC;    
        y_ticks = [-1:0.2:1];
        y_limit = [0.3,1.05];
         y_label = 'P(correct)';
    end
    
    pattern = ptrnACtable.patterns2;
  [chunk_num,chunk_num_tag, chunk_length, path_length] = cal_complexity(pattern,setsize);
    
    for mm  = 1:4
        ACC_bynum(mm,1)= mean(ptrnACtable.ptrnAC(chunk_num==mm));
        SD_bynum(mm,1)= std(ptrnACtable.ptrnAC(chunk_num==mm));
        
    end

    %%  plot : acc by pattern

    hold on;
    % line 

   x=round(sum(1./chunk_length(pattern_rank(:,1),:),2));   % complexity = sum(1/chunksize of each item)
   y = data2plot(pattern_rank(:,1));
    % scatter plot: sort by pattern accuracy
    partiplot(i)=scatter(x,y,40,map(i,:),'LineWidth',plot_linewidth-0.5);

    [RHO(i),p_cor(i)] = corr(x,y,'type','Spearman');
    
    % add fitting line
    if line_fitting > 0
        pp = polyfit(x,y,line_fitting);
        yy  = polyval(pp,x);
        f = plot(x,yy,'Color',map(i,:),'LineWidth',plot_linewidth);
        set(get(get(f,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
    
    font_size = 23;
    if p_cor(i)<0.001
        sig_text = '***';
    elseif p_cor(i)<0.01
        sig_text = '**';
    elseif p_cor(i)<0.05
        sig_text = '*';
    else
        sig_text = 'n.s.';
        font_size = 16;
    end

    text(max(x)*1.15,yy(end)+0.03,sig_text,...% 'Color',map(i,:),
            'FontSize',font_size,'FontName', 'Arial','FontWeight', 'bold','HorizontalAlignment','center');
    
        
    hold off 
end
hold on;
set(gca,'YTick', y_ticks,'XTick',[0:1:6],...  % 'XTickLabel',{},'TickLength',[0.004,0.02],
    'YAxisLocation','left','XAxisLocation','bottom',...
    'LineWidth',axis_linewidth,'Box','off','FontSize',ticklabel_fontsize);

xlim([0.5,4.5]);
ylim(y_limit);
ylabel(y_label,'FontName', 'Arial','FontWeight', 'bold','FontSize',label_fontsize);
hold off



%% pattern RT

hold on;
colormap(map)
pattern_rank = [1:30]';
h(2) = subplot(122);
pos{2}=get(h(2),'position');
for i = 1:size(participants,2)
    
    filepath = ['Data/' participants{i} '/'];
    if strcmp(participants{i},'ML')   % ML: no free touch- repeat data
        touchtype = 'errorStop';
    elseif contains(participants{i},'M') 
        touchtype = touchtype_temp;
    elseif strcmp(participants{i},'Children') |  strcmp(participants{i},'Adults')
        touchtype = 'freeTouch';
    end
    
    % load pattern accuracy
    datafile = [filepath, touchtype '_' rule '_' num2str(setsize) '_SqnsRTTable.mat'];
    load(datafile);

    y_ticks = [0:0.1:1];
    y_limit = [0.3,0.55];
    y_label = 'Time/s';
    
    pattern = ptrnACtable.patterns2;
  [chunk_num,chunk_num_tag, chunk_length, path_length] = cal_complexity(pattern,setsize);
 

    %%  plot : RT by pattern
    hold on;
    % line 
   x=round(sum(1./chunk_length(pattern_rank(:,1),:),2));
   y = mean(ptrnRTtable.ptrnRT,2);
    partiplot(i)=scatter(x,y,40,map(i,:),'LineWidth',plot_linewidth-0.5);

    [RHO2(i),p_cor2(i)] = corr(x,y,'type','Spearman');
    
    % add fitting line
    if line_fitting > 0
        pp = polyfit(x,y,line_fitting);
        yy  = polyval(pp,x);
        f = plot(x,yy,'Color',map(i,:),'LineWidth',plot_linewidth);
        set(get(get(f,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
    
    font_size = 23;
    if p_cor2(i)<0.001
        sig_text = '***';
    elseif p_cor2(i)<0.01
        sig_text = '**';
    elseif p_cor2(i)<0.05
        sig_text = '*';
    else
        sig_text = 'n.s.';
        font_size = 16;
    end

    text(max(x)*1.15,yy(end)+0.03,sig_text,...% 'Color',map(i,:),
            'FontSize',font_size,'FontName', 'Arial','FontWeight', 'bold','HorizontalAlignment','center');
        
    hold off
    

    
end
hold on;
set(gca,'YTick', y_ticks,'XTick',[0:1:6],...  % 'XTickLabel',{},'TickLength',[0.004,0.02],
    'YAxisLocation','left','XAxisLocation','bottom',...
    'LineWidth',2,'Box','off','FontSize',ticklabel_fontsize);
xlim([0.5,4.5]);
ylim(y_limit);
ylabel(y_label,'FontName', 'Arial','FontWeight', 'bold','FontSize',label_fontsize);
hold off

hold on;
set(h(1),'pos',pos{1}+[-0.02 0.12 -0.02 -0.08])
set(h(2),'pos',pos{2}+[+0.02 0.12 -0.02 -0.08])
ax = axes(fig);

han = gca;
han.Visible = 'off';
han.Title.Visible = 'on';
han.XLabel.Visible = 'on';
xlb = xlabel('sum(1/Chunk size)','FontName', 'Arial','FontWeight', 'bold','FontSize',label_fontsize);
xlb.Position = [0.48, 0.02, 0];
get(fig,'paperposition');
hold off
  

% calculate different complexities
function [chunk_num,chunk_num_tag, chunk_length, path_length] = cal_complexity(pattern,setsize)
% distance between sucessive items (1 = adjacent items)
target_dis = abs(pattern(:,1:end-1)-pattern(:,2:end));   % distance btw sucessive items
% try: chunk num
% pattern_rank = [1:30]';
chunk_num = ones(size(pattern,1),1);
% Four types:
% all items can be grouped into a single unit, i.e. sequence 1234,chunk_num ==1
% no adjacent items, and the sequence consists of 4 units
chunk_num(sum(target_dis==1,2)==0,1)=4;
% 3 units, 1-1-2, 1-2-1,2-1-1
chunk_num(sum(target_dis==1,2)==1,1)=3;
% 2 units, 2-2, 1-3, 3-1
chunk_num(sum(target_dis==1,2)==2,1)=2;
% scatter(chunk_num,comp)
chunk_num_tag = {'1','2','3','4'};


% chunk length 
is_chunk = zeros(size(target_dis));
is_chunk(target_dis==1) =1;
chunk_length = ones(size(is_chunk,1),setsize);
for bb  = 1:size(is_chunk,1)
    temp_index = find(is_chunk(bb,:) == 1);
    overlap = intersect(temp_index, temp_index+1);
    temp_index = unique([temp_index, temp_index+1]);
    chunk_length(bb,temp_index) = chunk_length(bb,temp_index)+length(overlap)+1;
end

% path length
path_length = zeros(size(pattern,1),1);
for yy  = 1:size(pattern,1)
    for zz  = 1:3
        path_length(yy,1) = path_length(yy,1) + (abs(exp(2*pi/6*1i*pattern(yy,zz+1))-exp(2*pi/6*1i*pattern(yy,zz))));
    end
end
end


