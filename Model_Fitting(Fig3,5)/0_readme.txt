>Datasets/
	Behavioral Raw Data
>Functions/
	Functions for Data Setting, Model Fitting and Results plotting...
>FiguresPlot/
	Scripts for Figures Plotting
>Models/
	Functions with Different Model Designs

>DataSetting***.m
	Script for Data and Experiment Setting ***
>Fitting***.m
	Script for Model Fitting (across all Patterns) ***
>ParamsTable***.m
	Script for Model Params and Statistics (e.g. BIC, R-squared...) Table
>ParamsStatistics4BS.m
	Script for Parametric Statistics for Bootstrap Results
>PermutationTest.m
	Script for Random Permutation Tests between Participants

>***4BS
	*** for Bootstrap
>***_CTMPinBS
	*** with the Central Tendency Measures of the Parameters in Bootstrap
>***4CV
	*** for Repeated K-fold Cross-Validation
>***4PT
	*** for Random Permutation Tests

>***_DD
	*** using some other Different Distribution
>***4CV_DD
	*** for Repeated K-fold Cross-Validation using some other Different Distributions

>***WfixedParams
	*** with Fixed Parameters
>***WOfreeParams
	*** without Free Parameters

[Example] Generate the Bootstrap results and Plot Figure 3: 
Step1. Run 'DataSetting.m' to generate all paticipants' files in 'DataSetAfterPreprocessing\' and 'PatternSet\';
Step2. Run 'DataSetting4BS.m' to generate files in 'PatternSet4BS\';
Step3. Run 'Fitting4BS.m' to generate files in 'FittingResults4BS\'(about 1min per fitting, could open multiple MATLABs to run parallel jobs);
Step4. Run 'Fitting_CTMPinBS.m' to generate files in 'FittingResults_medianPinBS\'(or 'FittingResults_meanPinBS\');
Step5. Run 'ParamsStatistics4BS.m' to generate files in 'FittingResults4BS\Parameters\';
Step6. Run 'FiguresPlotting\Fig3\Fig3***' to plot Figure 3 ***.