%% run these following lines to generate files¡¢data needed for plotting 


% run a0_DataScreening to exclude outliers and data with isuues before running the lines below, 
% a clean_dataset.mat will be generated in each data folder

% participant groups: 
% Adults = adults, sequence lenth = 4,5,6 ( main experiment)
% Children = children, sequence lenth = 4 ( main experiment)
% MO = M1, sequence lenth = 3,4 ( main experiment)
% MG = M2, sequence lenth = 3,4 ( main experiment)
% Adults_3Dots = adults, sequence lenth = 3 
% Children_3Dots = children, sequence lenth = 3 
% Adults2 = adults, sequence lenth = 4 (multiple-session experiment) 

%%
addpath(genpath('DataManipulations'));

% whether use a subset of all data(until trial number reach  a threshold)
whether_trimmed = 0;

% combine multiple monkeys and treat their data as one monkey
CombineMonkeys({'MO&MG'},{'MO','MG'},whether_trimmed,0);

%% save acc and rt , for plotting
% acc and rt: mean and sd of each session in monkey, and of each participant in
% human beings
% a table of accuracy and rt of each session/participant will be generated,
% which is saved in folder 'AccuracyAndRT'
final_output = CalAccRT({'Adults','Adults2','Adults_3Dots','Children','Children_3Dots','MO','MG'},{'repeat'},{'freeTouch','errorStop','Combined'},[3:6],0);

%% further analysis
% generate maps for order, position and distance:  
% --> get how accuracy varied with order, spaital location and distance
% from target (Transposition gradient)
% GenDistributionMap(participants,rule,touchtype,setsize,total N of locations,whether_trimmed)
GenDistributionMap({'Adults','Children','MO','MG','MO&MG'},'repeat','freeTouch',4,6,0,0)
GenDistributionMap({'Adults','Children','MO','MG','MO&MG'},'repeat','Combined',4,6,0,0)
GenDistributionMap({'Adults_3Dots','Children_3Dots'},'repeat','freeTouch',3,6,0,0)
GenDistributionMap({'Adults_3Dots','Children_3Dots'},'repeat','Combined',3,6,0,0)


% sort sequence: by orientation and starting point; adjusted for differnt
% location coding(1-6) in different group
%  --> get accuracy of each sequence/pattern
% SortSequence_Rotated(participants,rule,touchtype,setsize,total N of locations,whether_trimmed)
SortSequence_Rotated({'Adults','Children','MO','MG','MO&MG'},'repeat','freeTouch',4,6,0,0)
SortSequence_Rotated({'Adults','Children','MO','MG','MO&MG'},'repeat','Combined',4,6,0,0)


% generate a table containing all information of sequences, e.g.,
% sequences, pattern, starting point, orientation...
%  --> get how accuracy of each sequence/pattern varied with starting point, orientation...
% SortSequence_Rotated_OriStp(participants,rule,touchtype,setsize,total N of locations,whether_trimmed)
SortSequence_Rotated_OriStp({'Adults','Children','MO','MG','MO&MG'},'repeat','freeTouch',4,6,0,0)
SortSequence_Rotated_OriStp({'Adults','Children','MO','MG','MO&MG'},'repeat','Combined',4,6,0,0)

% sort sequence RT: by orientation and starting point; adjusted for differnt
% location coding(1-6) in different group
%  --> get how rts of each sequence/pattern varied with starting point, orientation...
% FindPatternRT_Rotated(participants,rule,touchtype,setsize,total N of locations,whether_trimmed)
FindPatternRT_Rotated({'Adults','Children','MO','MG','MO&MG'},'repeat','freeTouch',4,6,0,0)
FindPatternRT_Rotated({'Adults','Children','MO','MG','MO&MG'},'repeat','Combined',4,6,0,0)


% analysis on a subject-by-subject basic:
% sort sequence: by orientation and starting point; 
SortSequence_Rotated_Individual({'Adults2'},'repeat','freeTouch',4,6,0,0)
% sort sequence RT: by orientation and starting point;
FindPatternRT_Rotated_individual({'Adults2'},'repeat','freeTouch',4,6,0,0)

