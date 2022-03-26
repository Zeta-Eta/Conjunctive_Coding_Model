%% descriptions for plotting  scripts
% run a0_DataScreening.m, --> get clean datasets
% then run the lines in a1_DataManipulations.m, 
%   --> get the files needed for plotting
%
% read the comments and use the scripts below to get the figures and results

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% figures in manuscripts  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% fig 1:
% accuracy figure: 
%  error bars represent se of: 
%       participants for human beings
%       sessions for monkeys
Fig1_acc_N_error

%% fig 2
% plot accuracy of the 30 patterns in adults, childen and monkeys
Fig2_PatternACC_sorted

% p values for between - and within- pattern difference
Fig2_SqnsACC_Within_Btw2

% correlation of pattern accuracy in differnt group
Fig2_PatternCorrelation

%% fig 4
% RT figure: 
%  error bar represent se of: 
%       participants for human beings
%       sessions for monkeys
Fig4_RT_eachtouch

% rt figure: in a chunk mode(rows) * particpant group(columns) matrix
Fig4_ChunkMode_RT_Zscore

% correlation figure: correlation between sequence accuracy and complexity
Fig4_ChunkSize_Correlation


%%%%% end of figures in manuscripts  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% other results reported %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% participant-by-participant analysis (for adults in multiple session experiments)
 % significance of within and between pattern accuracy on subject-by-subject basic
individual_SqnsACC_Within_Btw  


%% starting point and seuquence orientation analysis
% Accuracies of sequences with different starting points
Sqns_StartingPoint

% Accuracies of sequences with different orientation (clockwise and counter-clockwise)
Sqns_SeqOrientation

%plot p value for starting point and orientation difference
SqnsACC_Within_OriStp

% within- and between pattern difference after excluding patterns with location bias in both monkeys
SqnsACC_Within_Btw_excluddSigInMonkeys  

%% correlation between exam score and task performance in children
% scripts saved in 'CorrelationSchool',data and function used can be found
% in subfolders

% calculate correlation between school performance and task performance
CalCorrelation

% calculate ovearll task accuracy of each individual
CalParticipants_OverallACC

% calculate task accuracy of each pattern/pattern category of each individual
CalParticipants_Pattern


%%%%%%%%%%%end of  other results reported %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





