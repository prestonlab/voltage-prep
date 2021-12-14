function hdr = voltage_extra(hdr)
%VOLTAGE_EXTRA   Retrofit a header with an added session.
%
%  hdr = voltage_extra(hdr)

old_hdr = hdr;
par = hdr.par;

session = 3;

% environment and object information
newpar = struct();
newpar.env = [0 5];
newpar.obj = 17:24;
newpar.n_obj = 4;
newpar.n_env = 2;

obj_dir = fullfile(par.exp_dir, 'stimuli');
newpar.obj_files = cell(1, length(newpar.obj));
for j = 1:length(newpar.obj)
    newpar.obj_files{j} = ...
        fullfile(obj_dir, sprintf('object_%03d.jpg', newpar.obj(j)));
end

% pool design
dnew = struct();
dnew.learn = voltage_master(newpar);
hdr.design.learn.env = [hdr.design.learn.env; dnew.learn.env];
hdr.design.learn.obj = [hdr.design.learn.obj; dnew.learn.obj];

% study
par.study.nSessions = 1;
dnew.study = nav_design(dnew.learn.env, par.study);

% test
par.test.nSessions = 1;
dnew.test = nav_design(dnew.learn.env, par.test);

% disp
par.disp.nSessions = 1;
dnew.disp = disp_design(dnew.learn, par.disp);

% update the existing header with the new session
phase = {'learn' 'study' 'test' 'disp'};
pnav = {'study' 'test'};
for i = 1:length(phase)
    % update parameters
    if ~strcmp(phase{i}, 'learn')
        hdr.par.(phase{i}).nSessions = session;
    else
        pool_par = hdr.par.pool.learn;
        pool_par.env = [pool_par.env newpar.env];
        pool_par.obj = [pool_par.obj newpar.obj];
        pool_par.n_env = length(pool_par.env);
        pool_par.obj_files = [pool_par.obj_files newpar.obj_files];
        hdr.par.pool.learn = pool_par;
    end

    % update design
    update = hdr.design.(phase{i});
    new = dnew.(phase{i});
    f = fieldnames(new);
    for j = 1:length(f)
        if strcmp(f{j}, 'session')
            new.(f{j}) = repmat(session, size(new.(f{j})));
        end
        update.(f{j}) = [update.(f{j}); new.(f{j})];
    end
    hdr.design.(phase{i}) = update;
    
    % update output files
    if strcmp(phase{i}, 'disp')
        name = {'log' 'mat'};
        ext = {'.txt' '.mat'};
    elseif ismember(phase{i}, pnav)
        name = {'config' 'log' 'sync' 'frame'};
        ext = {'.txt' '.xml' '.xml' '.xml'};
    else
        continue
    end
    out = voltage_output(phase{i}, name, ext, ...
                         hdr.par.(phase{i}).nSessions, ...
                         hdr.par.(phase{i}).nRuns);
    hdr.output.(phase{i}) = out;
end

% write config files for all navigation tasks
for i = 1:length(pnav)
    phase = pnav{i};
    phase_par = hdr.par.(phase);
    for j = 1:phase_par.nSessions
        for k = 1:phase_par.nRuns
            config_file = fullfile(hdr.subj_dir, ...
                                   hdr.output.(phase).config{j,k});
            if exist(config_file, 'file')
                continue
            else
                fprintf('Writing config: %s\n', config_file);
                voltage_config(hdr, pnav{i}, j, k);
            end
        end
    end
end

% write header
header_file = fullfile(hdr.subj_dir, 'header.mat');
backup_file = fullfile(hdr.subj_dir, 'header_orig.mat');
fprintf('Header backup: %s\n', backup_file);
movefile(header_file, backup_file);
save(header_file, 'hdr');
