function [cluster,cluster_tag,pattern_rank ] = CalCluster(Patterns,choose_cluster)

% choose_cluster =  'config';|'chunk_num' |'clustering'
%
%define pattern clustering, according to choose_cluster method


%% distance between sucessive items (1 = adjacent items)
target_dis = abs(Patterns(:,1:end-1)-Patterns(:,2:end));

% try: chunk num
% pattern_rank = [1:30]';
chunk_num = ones(size(Patterns,1),1);
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

% try: specific configuration
% pattern_rank = [1:30]';
% [1 1 1]  % 4
% [1 1 x]  % 3-1
% [1 x 1]  % 2-2
% [x 1 1]  % 1-3
% [x x 1]  % 1-1-2
% [x 1 x]  % 1-2-1
% [1 x x]  % 2-1-1
config = ones(size(Patterns,1),1);   % 1-1-1-1
config(sum(target_dis(:,[1,3])~=[1 1]&target_dis(:,2)==1,2)==2,1)=2;  % 1-2-1
config(sum(target_dis(:,1:2)~=[1 1]&target_dis(:,3)==1,2)==2,1)=3;  % 1-1-2
config(sum(target_dis(:,2:3)~=[1 1]&target_dis(:,1)==1,2)==2,1)=4;   % 2-1-1
config(sum(target_dis(:,[1,3])==[1 1]&target_dis(:,2)~=1,2)==2,1)=5;  % 2-2
config(sum(target_dis(:,2:3)==[1 1]&target_dis(:,1)~=1,2)==2,1)=6;  % 1-3
config(sum(target_dis(:,1:2)==[1 1]&target_dis(:,3)~=1,2)==2,1)=7;  % 3-1
config(sum(target_dis(:,1:3)==1,2)==3,1)=8;   % 4
config_tag = {'1-1-1-1','1-2-1','1-1-2','2-1-1','2-2','1-3','3-1','[¡À1]^3'};

%% pattern order, according to cluster chosen
if strcmp(choose_cluster,'comp_ranking')
    % [~, pattern_rank] = sort(ChunkDist(:,1),1);     %  sort by item complexity
    [~, pattern_rank] = sort(comp,1);     %  sort by sequence complexity
else
    pattern_rank = [1:30]';
end

%% angle of the path
angle = ones(size(Patterns,1),1);
d=120:-60:-180;
x=cosd(d);
y=sind(d);

for i = 1:size(Patterns,1)
    for j = 1:size(Patterns,2) -1
        v(j,:) = [x(Patterns(i,j+1)),y(Patterns(i,j+1)),0] -  [x(Patterns(i,j)),y(Patterns(i,j)),0];
    end
    for k = 1:size(Patterns,2) -2
        Theta(i,k) = atan2(norm(cross(v(k,:), v(k+1,:))), dot(v(k,:), v(k+1,:)));
    end
end
Theta = round(Theta,3);
% Theta_ratio = round(Theta(:,2)./Theta(:,1),2);
Theta_ratio = abs(Theta(:,2)-Theta(:,1));
% uni_Theta = unique(round(Theta,2),'rows');
uni_Theta = unique(Theta_ratio,'rows');
angle_tag  = cell(1,size(uni_Theta,1));
for i = 1:size(uni_Theta,1)
    %     angle(sum(round(Theta,2) == uni_Theta(i,:),2)==2) = i;
    %     angle_tag{i} = num2str(uni_Theta(i,:));
    angle(Theta_ratio == uni_Theta(i)) = i;
    angle_tag{i} = num2str(uni_Theta(i));
end



%% path length
pathLen  = zeros(size(Patterns,1),1);
path_length = zeros(size(Patterns,1),1);
for yy  = 1:size(Patterns,1)
    for zz  = 1:3
        path_length(yy,1) = path_length(yy,1) + (abs(exp(2*pi/6*1i*Patterns(yy,zz+1))-exp(2*pi/6*1i*Patterns(yy,zz))));
    end
    
end
path_length  = round(path_length,3);
pathtemp = unique(path_length);
for i = 1:size(pathtemp,1)
    pathLen(path_length == pathtemp(i)) = i;
    pathLen_tag{i} = num2str(pathtemp(i));
end



%% clustering ctriteria and tags
cluster = eval(choose_cluster);
cluster_tag = eval([choose_cluster '_tag']);
