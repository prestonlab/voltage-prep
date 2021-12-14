function hdr = voltage_header(par, subj_info, overwrite)
%VOLTAGE_HEADER   Create header for a Voltage participant.
%
%  To use standard parameters and be prompted for subject info,
%  just enter:
%    voltage_header
%
%  Full usage:
%    hdr = voltage_header(par, subj_info, overwrite)
%
%  INPUTS:
%        par:  parameter struct created by voltage_param. If not
%              specified, standard parameters will be used (most
%              common)
%
%  subj_info:  cell array with {subj_number subj_age subj_gender}.
%              If not specified, user will be prompted for information
%
%  overwrite:  if true, existing data for the subject will be
%              overwritten (default: false)
%
%  OUTPUTS:
%      hdr:  header struct with information to run the participant.
%            If no output specified, a variable named "hdr" will
%            be created in the base workspace.

if nargin < 1 || isempty(par)
    par = voltage_param();
end    
    
if nargin < 2 || isempty(subj_info)
    subj_info = {};
end

if nargin < 3
    overwrite = false;
end

SITE = 'DS';

hdr = init_header(par.experiment, subj_info);
hdr.subj_id = sprintf('%s%03d', SITE, hdr.subj_number);
hdr.subj_dir = fullfile(par.exp_dir, 'data', hdr.subj_id);
if ~exist(fullfile(par.exp_dir, 'data'))
    mkdir(fullfile(par.exp_dir, 'data'));
end
if exist(hdr.subj_dir, 'dir')
    if ~overwrite
        error('Subject directory already exists: %s\n', hdr.subj_dir)
    end
else
    mkdir(hdr.subj_dir);
end

% set the random seed based on the current time
rng('default');
rng('shuffle');
hdr.rand_settings = rng();

hdr.par = par;

% determine environments and objects to use; assign objects to
% positions
all_obj = [];
all_env = [];
for i = 1:length(par.pool_names)
    pool = par.pool_names{i};
    hdr.design.(pool) = voltage_master(par.pool.(pool));
    all_obj = [all_obj; hdr.design.(pool).obj];
    all_env = [all_env; hdr.design.(pool).env];
end

% place each object in the correct position in the world
env_list = [];
for i = par.env
    env_list = [env_list repmat(i, [1 4])];
end
obj_pos = zeros(1, par.nPos);
for i = 1:size(all_env, 1)
    obj_pos(env_list == all_env(i)) = all_obj(i,:);
end
unused = setdiff(1:par.nObj, all_obj(:));
ind = find(obj_pos == 0);
obj_pos(ind) = unused(1:length(ind));
hdr.design.obj_pos = obj_pos;

% free roam
% make two trials; program crashes for some reason if you just have 1
hdr.design.free_roam_slow.session = 1;
hdr.design.free_roam_slow.run = 1;
hdr.design.free_roam_slow.env = [hdr.design.prac.env hdr.design.prac.env];
hdr.design.free_roam_slow.obj = [0 0];
hdr.design.free_roam_slow.pos = [0 0];

hdr.design.free_roam = hdr.design.free_roam_slow;

% learning
hdr.design.prac_study = nav_design(hdr.design.prac.env, par.prac_study);

% during practice, make first two runs group by object and spawn position (one
% repetition for each)
obj = [];
pos = [];
obj_rand = randsample(0:3, 4);
for i = [1 3]
    pos_run = [];
    obj_run = [];
    for j = 0:1
        pos_rand = randsample(0:3, 4);
        for k = 1:length(pos_rand)
            pos_run = [pos_run repmat(pos_rand(k), [1 2])];
        end
        obj_run = [obj_run repmat(obj_rand(i+j), [1 8])];
    end
    obj = [obj; obj_run];
    pos = [pos; pos_run];
end

% make second two runs show objects in grouped order
for i = 1:2
    obj_run = [];
    obj_rand = randsample(0:3, 4);
    for j = 1:length(obj_rand)
        obj_run = [obj_run repmat(obj_rand(j), [1 4])];
    end
    obj = [obj; obj_run];
end

hdr.design.prac_study.pos(1:2,:) = pos;
hdr.design.prac_study.obj(1:4,:) = obj;

hdr.design.prac_test = nav_design(hdr.design.prac.env, par.prac_test);
hdr.design.study = nav_design(hdr.design.learn.env, par.study);
hdr.design.test = nav_design(hdr.design.learn.env, par.test);

hdr.design.prac_disp = disp_design(hdr.design.prac, par.prac_disp);
hdr.design.disp = disp_design(hdr.design.learn, par.disp);

% set paths for all output files
pnav = {'free_roam_slow' 'free_roam' 'prac_study' 'prac_test' ...
        'study' 'test'};
phases = [pnav {'prac_disp' 'disp'}];
for i = 1:length(phases)
    phase = phases{i};
    phase_par = par.(phase);
    
    % output file types and names
    if ismember(phase, pnav)
        name = {'config' 'log' 'sync' 'frame'};
        ext = {'.txt' '.xml' '.xml' '.xml'};
    else
        name = {'log' 'mat'};
        ext = {'.txt' '.mat'};
    end
    
    % generate all file names and place in standard struct
    out = voltage_output(phase, name, ext, ...
                         phase_par.nSessions, phase_par.nRuns);
    hdr.output.(phase) = out;
end

% write config files for all navigation tasks
for i = 1:length(pnav)
    phase = pnav{i};
    phase_par = par.(phase);
    for j = 1:phase_par.nSessions
        for k = 1:phase_par.nRuns
            voltage_config(hdr, pnav{i}, j, k);
        end
    end
end

hdr.log_file = 'log.txt';
hdr.file = 'header.mat';
save(fullfile(hdr.subj_dir, hdr.file), 'hdr');

if nargout == 0
  assignin('base', 'hdr', hdr);
end
