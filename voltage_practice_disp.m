function data = voltage_practice_disp(header)

%% Setup

par = header.parameters;
data = struct('subNr', header.subNr);
data.Environs = header.Environs; % do not use header.practice.envrions
data.dispStim = header.practice.disp;
data.actualOnsets = nan(par.practice.disp.nTotalTrials,1);
data.RT = nan(par.practice.disp.nTotalTrials,1);
data.resp = nan(par.practice.disp.nTotalTrials,1);
data.acc = nan(par.practice.disp.nTotalTrials,1);
data.respNull = [nan(par.practice.disp.nTotalTrials,1),data.dispStim(:,15)];
data.correctResp = data.dispStim(:,3);

% Set response options
oneKey = KbName('1!'); % button to output 1
twoKey = KbName('2@'); % button to output 2
threeKey = KbName('3#'); % button to output 3
fourKey = KbName('4$'); % button to output 4

posskeys = [oneKey twoKey threeKey fourKey];

%% Check for button box
intake=PsychHID('Devices');
extKeys=0;
for n=1:length(intake)
    if (intake(n).productID == 8 && strcmp(intake(n).usageName,'Keyboard')) % UT
        %     if intake(n).productID==16385 && strcmp(intake(n).usageName, 'Keyboard')
        extKeys=n;
    elseif strcmp(intake(n).usageName,'Keyboard')
        intKeys=n;
    end
end
if extKeys==0, disp('No Buttonbox Detected.'); end
dev = intKeys; % change this line to intKeys for running in the lab

%% Preload all stimuli
namepattern = [header.path.stim 'object_%03d.jpg'];
obj_stim = cell(par.nEnvTraining, par.nObjPerEnv);
for t=1:par.nEnvTraining % for each environment
    env = data.Environs(t,:);
    stimType = env(2:5);
    stimNr = env(6:9);
    for obj = 1:par.nObjPerEnv
        stimfname = sprintf(namepattern,stimNr(obj));
        obj_stim{t,obj} = imread(stimfname);
    end
end
data.stimNamePattern = namepattern;

%% %% Create output text file
outfname = sprintf('%s/%s_practice_disp_%d_%s',header.path.practicedata_subNr,header.exp,header.subNr,header.subInit);
%outfname = sprintf('%s%s_practice_disp_%d_%s',header.path.practicedata,header.exp,header.subNr,header.subInit);
if exist([outfname '.txt'],'file') == 2
    error('The data file for this scan already exists.  Please check your input parameters.');
end

formatString = '%0.4f\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%0.4f\t%d\t%d\t%0.3f\t%d\n';
fid=fopen([outfname '.txt'], 'w'); % open the file
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',...
    'onset (s)','relFixFlip (ms)','fixColor','envNr','sTypeA','sTypeB','sTypeC','sTypeD',...
    'env1','env2','env3','env4','stimType','trialTime','isNull','Resp','RT','Accuracy'); %Create header

%% open up the screen
oldEnableFlag = Screen('Preference','SuppressAllWarnings');
Screen('Preference', 'VisualDebugLevel', 1);
Screen('Preference', 'SkipSyncTests', 2); % will not show warning screen
[par.window, par.screenRect] = Screen(0, 'OpenWindow', par.backColor); % change me
[monitorFlipInterval] = Screen(par.window,'GetFlipInterval'); % gets the refresh time / monitor flip interval, to be used in calculating onsets below
par.xc = par.screenRect(3)/2;
par.yc = par.screenRect(4)/2;
par.xct = par.xc - par.txtSize/3; % center of screen for text
par.yct = par.yc - par.txtSize/3; % center of screen for text
Screen(par.window, 'TextSize', par.txtSize);
Screen(par.window, 'TextFont', 'Arial');
HideCursor;

% display some text
repText = 'Practice Detection Task';
Screen('TextSize',par.window,par.txtSize);
[normBoundsRect_repText,offsetBoundsRects_repText] = Screen('TextBounds',par.window,repText);
xcreptext = par.xc - normBoundsRect_repText(3)/2;
  
Screen(par.window, 'DrawText', repText, xcreptext, par.yc, par.txtColor);
Screen(par.window, 'Flip');

clear keyCode;
clear keyIsDown;

pa.TRIGGERED = 0;
while ~pa.TRIGGERED
    [keyIsDown, t, keyCode] = KbCheck(-1);
    if strcmp(KbName(keyCode), '5%')
        pa.TRIGGERED = 1;
    end
end

%startTime = GetSecs;
scannerStart = GetSecs;
startTime = scannerStart+par.bookendFixTime; 

data.beginTime = fix(clock);

% flip fixation on screen
Screen(par.window, 'TextSize', par.numSize);
Screen(par.window, 'DrawText', '+', par.xct, par.yct, par.fixColor);
Screen(par.window, 'Flip');
    
%% loop through all study trials
for t = 1:par.practice.disp.nTotalTrials
    
    % get trial onset
    ontime = data.dispStim(t,1);
    
    envNr = data.dispStim(t,4);
    
    switch data.dispStim(t,13);
        case 1 % A
            img = obj_stim{envNr,1};
        case 2 % B
            img = obj_stim{envNr,2};
        case 3 % C
            img = obj_stim{envNr,3};
        case 4 % D
            img = obj_stim{envNr,4};
    end
    
    if data.dispStim(t,15) == 1 % if it's a catch trial, do the flip
        %% flip 1: stimulus with black fixation
        % make texture for current trial presentation
        stim = Screen(par.window,'MakeTexture',img);
        
        % draw current trial image to buffer with fixation superimposed
        Screen(par.window, 'DrawTexture',stim);
        Screen(par.window, 'TextSize', par.numSize);
        Screen(par.window, 'DrawText', '+', par.xct, par.yct, par.fixColor);
        
        % calculate object presentation onset
        stimtime = startTime + ontime - monitorFlipInterval/2; % subtract refresh time / 2
        
        % flip presentation of image to screen at correct onset
        on = Screen(par.window,'Flip',stimtime);
        data.actualOnsets(t) = on - startTime;
        
        %% flip 2: stimulus with blue/green fixation
        % draw the colored fixation to buffer
        stim = Screen(par.window,'MakeTexture',img);
        
        % draw current trial image to buffer with COLORED fixation superimposed
        Screen(par.window,'DrawTexture',stim);
        Screen(par.window, 'TextSize', par.numSize);
        if data.dispStim(t,3)==1
            Screen(par.window,'DrawText', '+', par.xct, par.yct, [0 0 255]); % make it blue
        else
            Screen(par.window,'DrawText', '+', par.xct, par.yct, [60 179 113]); % make it green
        end
        
        objfliptime = stimtime + data.dispStim(t,2)/1000; % trial onset + time to colored flip
        
        % flip fixation to screen at correct onset
        on = Screen(par.window,'Flip',objfliptime);
        
        %% flip 3: blue/green fixation alone
        Screen(par.window, 'TextSize', par.numSize);
        if data.dispStim(t,3)==1
            Screen(par.window,'DrawText', '+', par.xct, par.yct, [0 0 255]); % make it blue
        else
            Screen(par.window,'DrawText', '+', par.xct, par.yct, [60 179 113]); % make it green
        end
        
        % calculate flip to blue/green fixation alone onset
        fixfliptime = stimtime + par.disp.stimTime; % trial onset + object duration (same as disp)
        
        % get response and RTs
        resp = [];
        % respstart = GetSecs; %start of response time
        while GetSecs < fixfliptime
            [keyIsDown, ~, keyCode] = KbCheck; %check for key response
            if keyIsDown
                if keyCode(oneKey)
                    resp = 1;
                    respstop = GetSecs;
                    break;
                elseif keyCode(twoKey)
                    resp = 2;
                    respstop = GetSecs;
                    break;
                end %end of keycode check
            end  %end of kbcheck
        end %end of while
        
        % flip fixation off screen at correct onset
        Screen(par.window,'Flip',fixfliptime);
        
        %% flip 4: black fixation alone
        Screen(par.window, 'TextSize', par.numSize);
        Screen(par.window, 'DrawText', '+', par.xct, par.yct, par.fixColor);
        
        % calculate flip to black fixation onset
        blackfixtime = stimtime + (par.practice.disp.trialTime-0.5);
        trialtime = stimtime + par.practice.disp.trialTime(t,1); % allow responses during any point in the trial (ECoG)
        
        while GetSecs < trialtime
            [keyIsDown, ~, keyCode] = KbCheck; %check for key response
            if keyIsDown
                if keyCode(oneKey)
                    resp = 1;
                    respstop = GetSecs;
                    break;
                elseif keyCode(twoKey)
                    resp = 2;
                    respstop = GetSecs;
                    break;
                end %end of keycode check
            end  %end of kbcheck
        end %end of while
        
        %Screen(par.window,'Flip',blackfixtime);
        
        %% save responses
        % assign RT and fixation response if participant didn't respond in time
        if isempty(resp)
            resp = nan;
            rt = nan;
        else
            %rt = respstop - respstart; %trial RT
            rt = respstop - objfliptime; % trial RT
        end
        
        % data.resp(t) =  str2double(resp(1));
        data.resp(t) =  resp(1); % this will hold all responses (also used below)
        data.RT(t) = rt(1);
        
        % create a data structure that counts the number of catch trial
        % nans (only used here with null trials)
        data.respNull(t,1) = resp(1);
                
        % calculate accuracy
        if resp == header.practice.disp(t,3) %correct response
            acc = 1;
            data.acc(t) = 1;
        else
            acc = 0;
            data.acc(t) = 0;
        end
        
        % save trial info to text file
        fprintf(fid,formatString,data.dispStim(t,:),data.resp(t),data.RT(t),acc);
        
    else % if not a catch trial, no flip (just black fixation)
        %% flip 1: stimulus with black fixation
        % make texture for current trial presentation
        stim = Screen(par.window,'MakeTexture',img);
        
        % draw current trial image to buffer with fixation superimposed
        Screen(par.window, 'DrawTexture',stim);
        Screen(par.window, 'TextSize', par.numSize);
        Screen(par.window, 'DrawText', '+', par.xct, par.yct, par.fixColor);
        
        % calculate object presentation onset
        stimtime = startTime + ontime - monitorFlipInterval/2; % subtract refresh time / 2
        
        % flip presentation of image to screen at correct onset
        on = Screen(par.window,'Flip',stimtime);
        data.actualOnsets(t) = on - startTime;
                
        %% flip 3: black fixation alone
        Screen(par.window, 'TextSize', par.numSize);
        Screen(par.window, 'DrawText', '+', par.xct, par.yct, par.fixColor);
        
        % calculate flip to blue/green fixation alone onset
        fixfliptime = stimtime + par.disp.stimTime; % trial onset + object duration (same as disp)
        
        % get response and RTs
        resp = [];
        % respstart = GetSecs; %start of response time
        while GetSecs < fixfliptime
            [keyIsDown, ~, keyCode] = KbCheck; %check for key response
            if keyIsDown
                if keyCode(oneKey)
                    resp = 1;
                    respstop = GetSecs;
                    break;
                elseif keyCode(twoKey)
                    resp = 2;
                    respstop = GetSecs;
                    break;
                end %end of keycode check
            end  %end of kbcheck
        end %end of while
        
        % flip fixation off screen at correct onset
        Screen(par.window,'Flip',fixfliptime);
                
        %% save responses
        % assign RT and fixation response if participant didn't respond in time
        if isempty(resp)
            resp = nan;
            rt = nan;
        else
            %rt = respstop - respstart; %trial RT
            rt = respstop - stimtime; % trial RT
        end
        
        % data.resp(t) =  str2double(resp(1));
        data.resp(t) =  resp(1);
        data.RT(t) = rt(1);
        
        % calculate accuracy
        if data.dispStim(t,15) == 0 % not a null trial (catch trial)
            acc = 0;
            data.acc(t) = 0;
        end
        
        % save trial info to text file
        fprintf(fid,formatString,data.dispStim(t,:),data.resp(t),data.RT(t),acc);
    end
    
end

clear t

WaitSecs(par.bookendFixTime);

% put relevant info into data structure
data.duration = GetSecs - startTime; % includes bookend fix at END
data.endTime = fix(clock);

clear startTime;

%% End experiment

ShowCursor;
Screen('CloseAll');
Screen('Preference','SuppressAllWarnings',oldEnableFlag);
clear screen;

data.parameters = par;
save(outfname,'data');

disp('---------------');
disp('Practice Detection task completed!');
disp('---------------');
disp(sprintf('# of Catch trials: %d',sum(data.dispStim(:,15))));
disp(sprintf('Catch NaNs: %d',sum(data.dispStim(:,15))-sum(~isnan(data.respNull(:,1)))));
disp(sprintf('Catch Acc: %0.3f',sum(data.respNull(:,1)==data.correctResp)/sum(data.dispStim(:,15))));
disp(sprintf('Catch Acc excl NaNs: %0.3f', mean(data.correctResp(~isnan(data.respNull(:,1)))==data.respNull(~isnan(data.respNull(:,1))))));
disp('---------------');
disp(' ');

