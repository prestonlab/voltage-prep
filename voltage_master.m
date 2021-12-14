function design = voltage_master(par)
%VOLTAGE_MASTER   Select environments and objects.
%
%  design = voltage_master(par)

n_tot = par.n_obj * par.n_env;
rand_obj = randsample(par.obj, n_tot);

if par.n_env > 1
    design.env = randsample(par.env, par.n_env)';
else
    design.env = par.env;
end
design.obj = reshape(rand_obj, [par.n_env par.n_obj]);
