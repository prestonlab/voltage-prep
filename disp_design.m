function design = disp_design(pool_design, par)
%DISP_DESIGN   Create design for the display task.
%
%  design = disp_design(pool_design, par)

n_sess = par.nSessions;
n_run = par.nRuns;
n_rep = par.nReps;
n_act = par.nActualTrials;
n_null = par.nNullTrials;
n_trial = par.nTrials;

n_run_tot = n_sess * n_run;
[n_env, n_stim_env] = size(pool_design.obj);
n_env_sess = n_env / n_sess;
n_item_sess = n_env_sess * n_stim_env;

% divide environments and runs into sessions
env_session = [];
session = [];
run = [];
for i = 1:n_sess
    env_session = [env_session; repmat(i, [n_env_sess 1])];
    session = [session; repmat(i, [n_run 1])];
    run = [run; [1:n_run]'];
end
design.session = session;
design.run = run;

design.obj = NaN(n_run_tot, n_trial);
design.isnull = NaN(n_run_tot, n_trial);

% fixation color change times in ms
design.change = round(par.change(1) + rand(n_run_tot, n_trial) * diff(par.change));

% jittered isi in ms
design.isi = round(par.isi(1) + rand(n_run_tot, n_trial) * diff(par.isi));
design.onset = NaN(n_run_tot, n_trial);
for i = 1:n_run_tot
    % objects presented in this session
    ind = env_session == session(i);
    obj_sess_pool = pool_design.obj(ind,:);
    obj_sess_pool = obj_sess_pool(:)';

    % populations of trial type and objects
    trial_type = [repmat(0, [1 n_act]) repmat(1, [1 n_null])];
    act_obj = repmat(obj_sess_pool, [1 n_rep]);
    n_null_item = n_null/n_item_sess;
    if n_null_item > 1
        null_obj = repmat(obj_sess_pool, [1 n_null_item]);
    else
        null_obj = obj_sess_pool;
    end

    % order trial types and objects randomly, given no object repeats
    run_obj = ones(1, n_trial);
    while any(diff(run_obj)==0)
        rand_type = randsample(trial_type, n_trial);
        rand_act = randsample(act_obj, n_act);
        rand_null = randsample(null_obj, n_null);
        run_obj(rand_type == 0) = rand_act;
        run_obj(rand_type == 1) = rand_null;
    end
    design.obj(i,:) = run_obj;
    design.isnull(i,:) = rand_type;
    
    % onset
    onset = 0:par.stim:(par.stim * n_trial);
    onset = onset(1:end-1);
    design.onset(i,:) = onset + [0 cumsum(design.isi(i,1:end-1)/1000)];
end

% additional information about each object
design.env = NaN(n_run_tot, n_trial);
design.pos = NaN(n_run_tot, n_trial);
for i = 1:numel(design.obj)
    [env_ind, pos] = find(design.obj(i) == pool_design.obj);
    design.env(i) = pool_design.env(env_ind);
    design.pos(i) = pos - 1; % zero-index to match Unity input
end
