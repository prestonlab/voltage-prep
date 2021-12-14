function voltage_config(hdr, phase, session, run)
%VOLTAGE_CONFIG   Output a config file for a navigation run.
%
%  voltage_config(hdr, phase, session, run)

config_file = fullfile(hdr.subj_dir, hdr.output.(phase).config{session,run});
fid = fopen(config_file, 'w');

par = hdr.par.(phase);
design = hdr.design.(phase);

fprintf(fid, '%d\n', hdr.subj_number);
fprintf(fid, '%s\n', hdr.subj_id);
fprintf(fid, '%d\n', par.successRadius);
fprintf(fid, '%d\n', par.movementSpeed);
fprintf(fid, '%d\n', par.trialType);
fprintf(fid, '%d\n', par.trialTime);
fprintf(fid, '%.1f\n', par.objTime);

obj_pos = hdr.design.obj_pos;
for i = 1:length(obj_pos)
    if i < length(obj_pos)
        fprintf(fid, '%d ', obj_pos(i));
    else
        fprintf(fid, '%d\n', obj_pos(i));
    end
end

% get the correct row to use
ind = find(design.session == session & design.run == run);
if length(ind) ~= 1
    error('Invalid session/run input.')
end

f = {'env' 'pos' 'obj'};
for i = 1:length(f)
    vec = design.(f{i})(ind,:);
    for j = 1:length(vec)
        if j < length(vec)
            fprintf(fid, '%d ', vec(j));
        else
            fprintf(fid, '%d\n', vec(j));
        end
    end
end
fclose(fid);
