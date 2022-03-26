 %% Correlation of pattern accuracy btw different participants
 % correlation of pattern accuracy
 
use_randomSelect = 0;  % whether use randomly selected trials in monkeys
 
participants = {'Children','Adults','MO&MG',};
parti_tag = {'Children','Adults','Monkeys',};
rule ='repeat';
touchtype_temp = 'Combined';  % 'Combined'; | 'freeTouch'

setsize = 4;
N =6;

%% font size and other properties

%title_fontsize = 18;
label_fontsize = 18;
ticklabel_fontsize = 18;
text_fontsize = 18;
legend_fontsize = 18;
axis_ticklength = [0.015 0.025];
axis_linewidth = 2;
plot_linewidth = 2.5;


%%  plot
% correlation pairs: number indicate # of participant group
corpair = [1,2;2,3;1,3];

% load accuracy
for i =1:size(participants,2)
    filepath = ['Data/' participants{i} '/'];
    if contains(participants{i},'M')
        touchtype = touchtype_temp;
    elseif strcmp(participants{i},'Children') |  strcmp(participants{i},'Adults')
        touchtype = 'freeTouch';
    end
        % random selected trials will be used only in monkeys
    if use_randomSelect ==1  &  contains(participants{i},'M')
        datafile = [filepath, touchtype '_' rule '_' num2str(setsize) '_SqnsTable_random.mat'];
    else
        datafile = [filepath, touchtype '_' rule '_' num2str(setsize) '_SqnsTable.mat'];
    end
    load(datafile);
    group_acc{i} = ptrnACtable.ptrnAC;
end


% scatter plot of each pair
figure('Color',[1 1 1])
set(gcf,'position',[0,0,320*size(corpair,1),280]);
for j =1:size(corpair,1)
    %     subplot(2,size(corpair,1)/2,j)
    h = subplot(1,size(corpair,1),j);
    pos = get(h,'position');
    set(h,'pos',pos+[0 0.15 -0.03 -0.16])
    hold on;
    
    % scatter plot
    x= group_acc{corpair(j,1)}; y = group_acc{corpair(j,2)};
   
    scatter(x,y,'filled','k')
    [RHO(j),p_cor(j)] = corr(x,y,'type','Spearman');
    
    % add fitting line
    pp = polyfit(x,y,1);
    yy  = polyval(pp,x);
    plot(x,yy,'Color',[98 98 98]/255,'LineWidth',plot_linewidth)
    
    % set limits
    x_scale = [0:0.02:1.02];y_scale = [0:0.02:1.02];
    x_upper_limit = x_scale(min(find(x_scale > max(x))));
    x_lower_limit = x_scale(max(find(x_scale < min(x))));
    y_upper_limit = y_scale(min(find(y_scale > max(y))));
    y_lower_limit = y_scale(max(find(y_scale < min(y))));
    set(gca,'YTick',[0:0.1:1],'XTick',[0:0.1:1],'LineWidth',axis_linewidth,'Box','off','FontSize',ticklabel_fontsize,'ticklength',axis_ticklength)
    
    xlim([x_lower_limit-0.02*(x_upper_limit-x_lower_limit),x_upper_limit+0.02*(x_upper_limit-x_lower_limit)]);
    ylim([y_lower_limit-0.02*(y_upper_limit-y_lower_limit),y_upper_limit+0.02*(y_upper_limit-y_lower_limit)]);

%         mark r square and sig marker
    if p_cor(j) <0.001
        text_temp = ['\rho = ' num2str(round(RHO(j),3)) ' ***'];
    elseif p_cor(j) <0.01
        text_temp = ['\rho = ' num2str(round(RHO(j),3)) ' **'];
    elseif p_cor(j) <0.05
         text_temp = ['\rho = ' num2str(round(RHO(j),3)) ' **'];
    else
        text_temp = ['\rho = '  num2str(round(RHO(j),3)) ];
    end
    text(x_lower_limit,y_upper_limit+0.09*(y_upper_limit-y_lower_limit),text_temp,...
            'FontSize',text_fontsize,'FontName', 'Arial','FontAngle','italic','FontWeight', 'bold');

    
    ylabel(parti_tag{corpair(j,2)},'FontName', 'Arial','FontWeight', 'bold', 'FontSize',label_fontsize);
    xlabel(parti_tag{corpair(j,1)},'FontName', 'Arial','FontWeight', 'bold', 'FontSize',label_fontsize);   
    
    hold off
end
