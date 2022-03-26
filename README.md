# Conjunctive_Coding_Model
Refer to JNeurosci article:

**[Zhang, Zhen et al. Working memory for spatial sequences: Developmental and evolutionary factors in encoding ordinal and relational structures. 2022](https://www.jneurosci.org/content/42/5/850)**

Data used in the code is available at [Zenodo](https://zenodo.org/record/6385904#.Yj6wcyhBx3g)

Feel free to open a issue if you have any question.

## Data_Analysis (Fig1,2,4)

from Dr. ZHEN Yanfen

### Hints for using the scripts：

a0_DataScreening.m -  preprocessing of raw data

a1_DataManipulations.m  -   generate data and files needed for plotting

a2_Batch_Introduction.m  -   descriptions for plotting scripts，open this file and see how other scripts work

### Folders: 

Data  -   where data files are saved

DataManipulations - functions used in processing

AccuracyAndRT - where the table of accuracy and RT of each session/participant is saved

CorrelationSchool - the analysis of correlation between task performance and school performance of children

Figure - a folder for saving output figures
      

### Naming of subfolders in ‘Data’folder

% Adults = adults, sequence lenth = 4,5,6 ( main experiment)

% Children = children, squence lenth = 4 ( main experiment)

% MO = M1, sequence lenth = 3,4 ( main experiment)

% MG = M2, sequence lenth = 3,4 ( main experiment)

% Adults_3Dots = adults, sequence lenth = 3 

% Children_3Dots = children, sequence lenth = 3 

% Adults2 = adults, sequence lenth = 4 (multiple-session experiment) 

## Model_Fitting (Fig3,5)

### Folders: 

\>Datasets/ 

-Behavioral Raw Data

\>Functions/ 

-Functions for Data Setting, Model Fitting and Results plotting...

\>FiguresPlot/ 

-Scripts for Figures Plotting

\>Models/ 

-Functions with Different Model Designs

### Files: 

\>DataSetting***.m 

-Script for Data and Experiment Setting ***

\>Fitting***.m 

-Script for Model Fitting (across all Patterns) ***

\>ParamsTable***.m 

-Script for Model Params and Statistics (e.g. BIC, R-squared...) Table

\>ParamsStatistics4BS.m 

-Script for Parametric Statistics for Bootstrap Results

\>PermutationTest.m 

-Script for Random Permutation Tests between Participants

### Acronyms: 

\>***4BS 

-*** for Bootstrap

\>\*\*\*_CTMPinBS 

-*** with the Central Tendency Measures of the Parameters in Bootstrap

\>\*\*\*4CV 

-*** for Repeated K-fold Cross-Validation

\>\*\*\*4PT 

-*** for Random Permutation Tests

\>\*\*\*_DD 

-*** using some other Different Distribution

\>\*\*\*4CV_DD 

-*** for Repeated K-fold Cross-Validation using some other Different Distributions

\>\*\*\*WfixedParams 

-*** with Fixed Parameters

\>\*\*\*WOfreeParams 

-*** without Free Parameters

### [Example] Generate the Bootstrap results and Plot Figure 3: 

Step1. Run 'DataSetting.m' to generate all paticipants' files in 'DataSetAfterPreprocessing\' and 'PatternSet\';

Step2. Run 'DataSetting4BS.m' to generate files in 'PatternSet4BS\';

Step3. Run 'Fitting4BS.m' to generate files in 'FittingResults4BS\'(about 1min per fitting, could open multiple MATLABs to run parallel jobs);

Step4. Run 'Fitting_CTMPinBS.m' to generate files in 'FittingResults_medianPinBS\'(or 'FittingResults_meanPinBS\');

Step5. Run 'ParamsStatistics4BS.m' to generate files in 'FittingResults4BS\Parameters\';

Step6. Run 'FiguresPlotting\Fig3\Fig3***' to plot Figure 3 ***.
