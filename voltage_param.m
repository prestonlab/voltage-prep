function par = voltage_param()
%VOLTAGE_PARAM   Parameters for Voltage.
%
%  par = voltage_param()

par.exp_dir = fileparts(mfilename('fullpath'));
par.experiment = 'voltage';

%% display options

par.fixColor = 0;
par.backColor = 255;
par.txtColor = 0;
par.txtSize = 50;
par.numSize = 100;
par.labelSize = 40;
par.stimSep = 100;
par.bookendFixTime = 4;

par.nPos = 28;
par.nEnv = 7;
par.nObj = 36;
par.env = 0:6;

%% pools

par.pool_names = {'prac' 'learn'};

% object and environment pools from volt v5
par.pool.prac.env = 6;
par.pool.prac.obj = 25:28;
par.pool.prac.n_obj = 4;
par.pool.prac.n_env = 1;

par.pool.learn.env = 1:4;
par.pool.learn.obj = 1:16;
par.pool.learn.n_obj = 4;
par.pool.learn.n_env = 4;

obj_dir = fullfile(par.exp_dir, 'stimuli');
for i = 1:length(par.pool_names)
    pool = par.pool.(par.pool_names{i});
    files = cell(1, length(pool.obj));
    for j = 1:length(pool.obj)
        files{j} = fullfile(obj_dir, sprintf('object_%03d.jpg', pool.obj(j)));
    end
    par.pool.(par.pool_names{i}).obj_files = files;
end

nav.pool = 'learn';
nav.nRuns = 1;
nav.nSessions = 1;
nav.nReps = 1;
nav.trialType = 0;
nav.movementSpeed = 10;
nav.successRadius = 8;
nav.objTime = 1.5;

roam.pool = 'prac';
roam.nRuns = 1;
roam.nSessions = 1;
roam.nReps = 1;
roam.trialType = 1;
roam.movementSpeed = 10;
roam.successRadius = 0;
roam.trialTime = 180;
roam.objTime = 0;

%% free roam slow

par.free_roam_slow = roam;
par.free_roam_slow.movementSpeed = 8;

%% free roam

par.free_roam = roam;

%% practice study

par.prac_study = nav;
par.prac_study.pool = 'prac';
par.prac_study.nRuns = 6;
par.prac_study.nReps = 4;
par.prac_study.trialTime = 60;

%% practice test

par.prac_test = nav;
par.prac_test.pool = 'prac';
par.prac_test.nReps = 1;
par.prac_test.trialType = 2;
par.prac_test.trialTime = 20;

%% study

par.study = nav;
par.study.nRuns = 3;
par.study.nSessions = 2;
par.study.nReps = 2;
par.study.trialTime = 60;

%% test

par.test = nav;
par.test.nRuns = 1;
par.test.nSessions = 2;
par.test.trialType = 2;
par.test.trialTime = 20;

%% practice disp

par.prac_disp.pool = 'prac';
par.prac_disp.nRuns = 1;
par.prac_disp.nSessions = 1;
par.prac_disp.nReps = 2;
par.prac_disp.nActualTrials = 8;
par.prac_disp.nNullTrials = 4;
par.prac_disp.nTrials = 12;
par.prac_disp.stim = 2;
par.prac_disp.change = [50 275];
par.prac_disp.isi = [800 1200];

%% disp

par.disp = par.prac_disp;
par.disp.pool = 'learn';
par.disp.nRuns = 4;
par.disp.nSessions = 2;
par.disp.nReps = 4;
par.disp.nActualTrials = 32;
par.disp.nNullTrials = 8;
par.disp.nTrials = 40;
