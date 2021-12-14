function out = voltage_output(phase, name, ext, n_sess, n_run)
%VOLTAGE_OUTPUT   Generate filenames for all output files.
%
%  out = voltage_output(phase, name, ext, n_sess, n_run)

out = struct();
for i = 1:length(name)
    % initialize for this type of output
    if strcmp(phase, 'disp')
        n_block = 2;
        out.(name{i}) = cell(n_sess, n_run, n_block);
    else
        n_block = 1;
        out.(name{i}) = cell(n_sess, n_run);
    end
    for j = 1:n_sess
        for k = 1:n_run
            for l = 1:n_block
                % file for this output type, session, and run
                if n_block > 1
                    filename = sprintf('%s_%s_%d_%d_%d%s', ...
                                       name{i}, phase, j, l, k, ext{i});
                else
                    filename = sprintf('%s_%s_%d_%d%s', ...
                                       name{i}, phase, j, k, ext{i});
                end
                out.(name{i}){j,k,l} = filename;
            end
        end
    end
end
