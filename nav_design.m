function design = nav_design(env_pool, par)
%NAV_DESIGN   Create design for a navigation task.
%
%  design = nav_design(env_pool, par)

n_run = par.nRuns;
n_sess = par.nSessions;
n_rep = par.nReps;

% numbers
n_obj = 4;
n_tot = n_sess * n_run;
n_env = length(env_pool);
n_env_sess = n_env / n_sess;
n_stim = n_rep * n_obj * n_env_sess;

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

% counterbalance environment, object, and position order across trials
obj_ind = (1:n_obj) - 1;
pos_ind = (1:n_obj) - 1;
env = NaN(n_tot, n_stim);
pos = NaN(n_tot, n_stim);
obj = NaN(n_tot, n_stim);
for i = 1:n_tot
    % get environments for this session, randomize initial order
    env_sess_pool = env_pool(env_session == session(i))';
    if length(env_sess_pool) > 1
        rand_env = randsample(env_sess_pool, n_env_sess);
    else
        rand_env = env_sess_pool;
    end
    
    % interleave the environments
    env(i,:) = repmat(rand_env, [1 n_obj * n_rep]);

    % randomize object and position
    for j = 1:n_env_sess
        ind = env(i,:)==env_sess_pool(j);
        obj(i,ind) = tile_no_rep(obj_ind, n_rep);
        pos(i,ind) = tile_no_rep(pos_ind, n_rep);
    end
end
design.env = env;
design.pos = pos;
design.obj = obj;


function y = tile_no_rep(x, n)

  y = ones(size(x));
  while any(diff(y) == 0)
      y = [];
      for i = 1:n
          y = [y randsample(x, length(x))];
      end
  end
  