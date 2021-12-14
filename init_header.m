function header = init_header(experiment, subj_info)
%INIT_HEADER   Initialize header information for an experiment.
%
%  header = init_header(experiment, subj_info)

header = struct();
header.experiment = experiment;
header.date = datestr(now);
header.setuptime = fix(clock);

if nargin == 2 && ~isempty(subj_info)
    header.subj_number = subj_info{1};
    header.subj_age = subj_info{2};
    header.subj_gender = subj_info{3};
    return
end

correct = false;
while ~correct
    fprintf('\nSubject Information\n-------------------\n');
    header.subj_number = input('Subject number:  ');
    header.subj_age = input('Subject age:  ');
    header.subj_gender = input('Is this male (1) or female (2)?  ');

    fprintf('\n');
    disp('---------------------------------------------');
    disp('Please make sure this information is correct.');
    disp('---------------------------------------------');
    disp(['Subject number: ', num2str(header.subj_number)]);
    disp(['Subject age:    ', num2str(header.subj_age)]);
    gender = {'male' 'female'};
    disp(['Subject gender: ', gender{header.subj_gender}]);
    disp('---------------------------------------------');
    disp('')

    yn = input('Is this correct?  (y,n):  ', 's');

    if isequal(upper(yn(1)), 'Y')
        correct = true;
    end
end
