function [samplesize,newRHO,newp_cor] = Fig_corr_whetherChunk(tempx,tempy,corr_type,map,exclude_outlier)

%% Correlation of exam score and acc (sequence with chunks and without chunks)
    x_upper_limit = max(tempx,[],'all');
    x_lower_limit = min(tempx,[],'all');    
%     corr_type = 'Spearman';  % 'Spearman' | 'Pearson'
    if strcmp(corr_type,'Spearman' )
        stats_tag = '\rho';
    elseif strcmp(corr_type,'Pearson' )
         stats_tag = 'r';    
    end
    
    % different complexity in subplot
    fig =figure('Color',[1 1 1]);
    set(gcf,'position',[50,50,300*size(tempx,2),300]);
    zero_index = [];

    for i = 1:size(tempx,2)
        
        h(i)= subplot(1,size(tempx,2),i);
        pos{i}=get(h(i),'position');
        set(h(i),'pos',pos{i}+[-0.02 0.09 -0.02 -0.15])
        hold on
        x = tempx(~isnan(tempx(:,i)),i);
        y = tempy(~isnan(tempx(:,i)));
        % exclude outlier
        
        if exclude_outlier==1
             outlierIdx = unique([find(isoutlier(x,'median'));find(isoutlier(y,'median'))])
            if ~isempty(outlierIdx)
                x(outlierIdx ) =[]; y(outlierIdx ) =[];
            end
        end
        
       samplesize(i,1) = length(x);
        
        y_upper_limit = max(y);
        y_lower_limit = min(y);
        
        [newRHO(i,1),newp_cor(i,1)] = corr(x,y,'type',corr_type);
        s = scatter(x,y,26,map(1,:),'filled');
        % add fitting line
        pp = polyfit(x,y,1);
        yy  = polyval(pp,x);
        f = plot(x,yy,'Color',[98 98 98]/255,'LineWidth',2.5);

        x_upper_limit = max(x,[],'all');
        x_lower_limit = min(x,[],'all');
        
        text_temp = GenStatsFlag(stats_tag, newRHO(i,1), newp_cor(i,1),0,1);
        text(x_lower_limit+(x_upper_limit-x_lower_limit)*0.05,y_upper_limit+(y_upper_limit-y_lower_limit)*0.1,text_temp,...
            'FontSize',16,'FontName', 'Arial','FontAngle','italic','FontWeight', 'bold','Color',map(1,:));
        
        xlim([x_lower_limit-0.05*(x_upper_limit-x_lower_limit),x_upper_limit+0.05*(x_upper_limit-x_lower_limit)]);
        ylim([y_lower_limit-0.1*(y_upper_limit-y_lower_limit),y_upper_limit+0.1*(y_upper_limit-y_lower_limit)]);
        if  i ==1
              til =  title('Chunk','FontSize',18,'FontWeight', 'bold');
        else
            til = title('No-chunk','FontSize',18,'FontWeight', 'bold');
        end
            til.Position = [0.5, 103, 0];
        if y_upper_limit > 10
            y_scale = [0:10:100];
        else
            y_scale = [-5:0.5:5];
        end
        set(gca,'YTick', y_scale ,'XTick',[-3:0.25:3],...
            'YAxisLocation','left','XAxisLocation','bottom',...
            'LineWidth',2,'Box','off','FontSize',16,'ticklength',[0.015 0.025]);
        
        hold off
        
    end
    
    hold on;
    ax = axes(fig);
    % yyaxis(ax, 'left');
    han = gca;
    han.Visible = 'off';
    han.Title.Visible = 'on';
    han.XLabel.Visible = 'on';
    han.YLabel.Visible = 'on';

    xlb = xlabel('Accuracy','FontSize',16,'FontWeight', 'bold');
    ylb = ylabel('Exam Score','FontSize',16,'FontWeight', 'bold');
    xlb.Position = [0.5, -0.024, 0];
    ylb.Position = [-0.1, 0.5, 0];
    get(fig,'paperposition');
    hold off
    