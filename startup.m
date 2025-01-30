p=pathdef;
path(p);
addpath(['.' filesep]);
addpath(genpath(['.' filesep 'third-party' filesep 'genpath_exclude']));

% if you prefer to retain your own version of some of the packages included in 'third-party', you can use genpath_exclude, as in these examples
% addpath(genpath_exclude(['.' filesep 'third-party'],{'altmany-export_fig-344'})); % excludes export_fig
% addpath(genpath_exclude(['.' filesep 'third-party'],{'altmany-export_fig-344','chronux'})); % excludes export_fig and chronux

% this include all 'third-party' packages in the current path; comment it out if you prefer to retain your own version of some of them
addpath(genpath(['.' filesep 'third-party']));

addpath(genpath(['.' filesep 'common']));
addpath(genpath(['.' filesep 'synth_train_generation']));
addpath(genpath(['.' filesep 'data_analysis']));

set(0, 'DefaultAxesFontSize', 20);
set(0, 'DefaultLineLineWidth', 2);
set(0, 'DefaultTextFontSize', 20);
set(0, 'DefaultErrorBarLineWidth', 2);
