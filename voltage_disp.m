function data = voltage_disp(hdr, phase, session, block, run, debug)
%VOLTAGE_DISP   Present stimuli in display task.
%
%  data = voltage_disp(header, phase, session, block, run, debug)

% 11/27/2012: fixation during reference lines added by MLS
%             press 5 before starting scanner to move from "Detection Task"
%             to fixation cross (have sub fixate during ref lines)
%             scanner should trigger experiment as normal!!!
% 05/2015: edited by KRS for volt 
%
% 02/2017: edited by KRS for voltage

%% Setup

if nargin < 6
    debug = false;
end

% get the design for this phase
if ~isfield(hdr.design, phase)
    error('Design not found for %s phase.', phase)
end
design = hdr.design.(phase);

% find the correct run in the design
ind = find(design.session==session & design.run==run);
if length(ind) ~= 1
    error('Session %d, run %d design not found for %s phase.', ...
          session, run, phase)
end
if ~any(block == [1 2])
    error('Block should be 1 or 2 (input: %d)', block)
end

% get the parameters for this phase
par = hdr.par; % main
phase_par = hdr.par.(phase); % phase-specific
pool_par = hdr.par.pool.(phase_par.pool); % stim pool information

% initialize data struct
data = struct();
data.subject = hdr.subj_number;
f = fieldnames(design);
for i = 1:length(f)
    data.(f{i}) = design.(f{i})(ind,:);
end

n_trial = phase_par.nTrials;

data.stim_onset = NaN(1, n_trial);
data.change_onset = NaN(1, n_trial);
data.stim_offset = NaN(1, n_trial);
data.resp = NaN(1, n_trial);
data.rt = NaN(1, n_trial);
data.acc = NaN(1, n_trial);
data.resp_all = cell(1, n_trial);
data.rt_all = cell(1, n_trial);

% Set response options
oneKey = KbName('space');

%% Preload all stimuli

obj_stim = cell(size(pool_par.obj_files));
for i = 1:length(pool_par.obj_files)
    obj_stim{i} = imread(pool_par.obj_files{i});
end
obj_number = pool_par.obj;

%% Create output text file

log_file = fullfile(hdr.subj_dir, hdr.output.(phase).log{session,run,block});
mat_file = fullfile(hdr.subj_dir, hdr.output.(phase).mat{session,run,block});

if ~debug && exist(mat_file, 'file')
    error('The data file for this run already exists: %s', mat_file);
end

% log settings
fields = {'stim_onset' 'stim_offset' 'obj' 'env' 'pos' 'isnull' 'resp' 'acc' 'rt' 'change'};
names = {'onset' 'offset' 'obj' 'env' 'pos' 'null' 'resp' 'acc' 'rt' 'change'};
format = {'%.4f' '%.4f' '%d' '%d' '%d' '%d' '%d' '%d' '%.4f' '%d'};

% open the file, print header
fid = fopen(log_file, 'w'); % run log
lfid = fopen(fullfile(hdr.subj_dir, hdr.log_file), 'a'); % main log
fprintf(lfid, 'Starting phase %s %d, session %d, run %d.\n', ...
        phase, block, session, run);
for i = 1:length(names)
    if i < length(names)
        fprintf(fid, '%s\t', names{i});
        fprintf(lfid, '%s\t', names{i});
    else
        fprintf(fid, '%s\n', names{i});
        fprintf(lfid, '%s\n', names{i});
    end
end

%% open up the screen
try

Screen('CloseAll');
Screen('Preference', 'VisualDebugLevel', 1);
if debug
    % use smaller screen for debugging purposes
    [par.window, par.screenRect] = Screen(0, 'OpenWindow', par.backColor, [0 0 1440/2 900/2]);
else
    [par.window, par.screenRect] = Screen(0, 'OpenWindow', par.backColor);
end

% get the refresh time / monitor flip interval, to be used in
% calculating onsets below
monitorFlipInterval = Screen(par.window,'GetFlipInterval'); 
par.xc = par.screenRect(3)/2;
par.yc = par.screenRect(4)/2;
Screen(par.window, 'TextSize', par.txtSize);
Screen(par.window, 'TextFont', 'Arial');
HideCursor;
Priority(MaxPriority(par.window));

if strcmp(phase, 'disp')
    repText = sprintf('Session %d, Detection Task %d: Run %d', ...
                      session, block, run);
else
    repText = 'Practice Detection Task';
end
Screen('TextSize',par.window,par.txtSize);

DrawFormattedText(par.window, repText, 'center', 'center', par.txtColor);
Screen(par.window, 'Flip');

% wait for button press (this serves as a check that the response
% button is registering properly)
while true
    [keyIsDown, ~, keyCode] = KbCheck(-1);
    if keyIsDown && keyCode(oneKey)
        break
    end
end
clear keyCode keyIsDown

% show fixation
Screen(par.window, 'TextSize', par.numSize);
DrawFormattedText(par.window, '+', 'center', 'center', par.fixColor);
scannerStart = Screen(par.window, 'Flip');

startTime = scannerStart+par.bookendFixTime; 
data.beginTime = fix(clock);

% loop through all study trials
for t = 1:n_trial
    % prep stim
    img = obj_stim{obj_number == data.obj(t)};
    [imx, imy, ~] = size(img);
    imrect = [par.xc-imx/2 par.yc-imy/2 par.xc+imx/2 par.yc+imy/2];
    syncrect = [0 0 40 40];

    %% flip 1: stimulus with black fixation
    % make texture for current trial presentation
    stim = Screen(par.window,'MakeTexture',img);
    Screen('DrawTexture', par.window, stim, [], imrect);
    % black square in corner for photometer; onset and offset will be at
    % same time as the object image
    Screen('FillRect', par.window, [0 0 0], syncrect);
    
    % draw current trial image to buffer with fixation superimposed
    Screen(par.window, 'TextSize', par.numSize);
    DrawFormattedText(par.window, '+', 'center', 'center', par.fixColor);
    
    % calculate object presentation onset
    stimtime = startTime + data.onset(t) - monitorFlipInterval/2;

    % flip presentation of image to screen at correct onset
    flip_stim = Screen(par.window,'Flip',stimtime);
    data.stim_onset(t) = flip_stim - startTime;

    if data.isnull(t)
        %% flip 2: stimulus with green fixation (catch trials only)
        % draw the colored fixation to buffer
        % draw current trial image to buffer with COLORED fixation superimposed
        Screen('DrawTexture', par.window, stim, [], imrect);
        Screen('FillRect', par.window, [0 0 0], syncrect);
        Screen(par.window, 'TextSize', par.numSize);

        % green fixation
        DrawFormattedText(par.window, '+', 'center', 'center', [60 179 113]);

        % trial onset + time to colored flip
        objfliptime = stimtime + data.change(t)/1000 - monitorFlipInterval/2;

        % flip fixation to screen at correct onset
        flip_change = Screen(par.window,'Flip',objfliptime);
        data.change_onset(t) = flip_change - startTime;
    end

    %% flip 3: black fixation alone
    Screen(par.window, 'FillRect', par.backColor);
    Screen(par.window, 'TextSize', par.numSize);
    % keep black so will be jittered from next trial
    DrawFormattedText(par.window, '+', 'center', 'center', par.fixColor);

    % calculate flip to fixation alone onset
    fixfliptime = stimtime + phase_par.stim - monitorFlipInterval/2;
    
    % collect responses until stimulus goes offscreen
    resp_all = [];
    stop_all = [];
    while GetSecs < fixfliptime
        [keyIsDown, keySec, keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(oneKey)
                stop_all = [stop_all keySec];
                resp_all = [resp_all 1];
            end
            KbReleaseWait(-1);
        end
    end
    
    % flip stimulus off screen at correct onset
    flip_fix = Screen(par.window,'Flip',fixfliptime);
    
    % collect more responses until end of trial
    trialtime = flip_fix + data.isi(t)/1000 - monitorFlipInterval/2;
    while GetSecs < trialtime
        [keyIsDown, keySec, keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(oneKey)
                stop_all = [stop_all keySec];
                resp_all = [resp_all 1];
            end
            KbReleaseWait(-1);
        end
    end
    
    data.stim_offset(t) = flip_fix - startTime;
    
    %% save responses
    % assign RT and fixation response if participant didn't respond in time
    if isempty(resp_all)
        resp = 0;
        rt_all = [];
        rt = NaN;
    else
        % get time relative to stimulus onset (not relative to change)
        resp = 1;
        rt_all = stop_all - stimtime;
        rt = rt_all(1);
    end
    data.resp(t) = resp;
    data.rt(t) = rt;
    data.resp_all{t} = resp_all;
    data.rt_all{t} = rt_all;
    
    % calculate accuracy
    if data.isnull(t) == data.resp(t)
        % catch trial with response or non-catch trial with no response
        data.acc(t) = 1;
    else
        data.acc(t) = 0;
    end
    
    % save trial info to text file
    for j = 1:length(fields)
        x = data.(fields{j})(t);
        if j < length(fields)
            fprintf(fid, [format{j} '\t'], x);
            fprintf(lfid, [format{j} '\t'], x);
        else
            fprintf(fid, [format{j} '\n'], x);
            fprintf(lfid, [format{j} '\n'], x);
        end
    end
    
    % close stimulus texture
    Screen('Close', stim);
    
    % write snapshot of data
    save(mat_file, 'data');
end

finish_time = trialtime + par.bookendFixTime;
while GetSecs() <= finish_time; end

% put relevant info into data structure
data.duration = GetSecs() - scannerStart;
data.endTime = fix(clock);

%% End experiment

ShowCursor;
Screen('CloseAll');
clear screen;

catch err
ShowCursor();
ListenChar(1);
Priority(0);
Screen('CloseAll');
fclose('all')
rethrow(err)
end

save(mat_file, 'data');

s = seconds(data.duration);
s.Format = 'hh:mm:ss';
fprintf(lfid, 'Run finished. Duration: %s (%d s). Accuracy: %.3f\n', ...
        char(s), round(data.duration), mean(data.acc));

fclose(fid);
fclose(lfid);

fprintf('---------------\n');
fprintf('# of catch trials: %d\n',nnz(data.isnull));
fprintf('Hit rate: %0.3f\n', mean(data.resp(data.isnull==1)==1))
fprintf('False alarm rate: %0.3f\n', mean(data.resp(data.isnull==0)==1))
fprintf('---------------\n');
