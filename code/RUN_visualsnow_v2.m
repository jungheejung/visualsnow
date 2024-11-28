% Main Script: Psychtoolbox with counterbalanced intro images from .tsv

current_dir = pwd;
main_dir = fileparts(current_dir);
try
    % Setup Psychtoolbox
    Screen('Preference', 'SkipSyncTests', 1);
    [win, rect] = Screen('OpenWindow', max(Screen('Screens')), [0 0 0]);
    Screen('TextSize', win, 40);
    
    % Prompt for subject number and starting run index
    subjectNum = input('Enter subject number (e.g., 1 for sub-01): ');
    runStart = input('Enter starting run index (1-4): ');
    subjectBIDS = sprintf('sub-%02d', subjectNum); % Format as sub-01, sub-02, etc.
    
    % Confirmation prompt
    confirmationMessage = sprintf('We will start the scan for %s, run %d. Confirm (y/n): ', subjectBIDS, runStart);
    proceed = input(confirmationMessage, 's');
    
    if strcmpi(proceed, 'y')
        fprintf('Proceeding with the scan for %s, run %d.\n', subjectBIDS, runStart);
        
        % Load Counterbalance Scheme
        counterbalanceFile = './design/counterbalance_scheme.tsv';
        sequence = load_counterbalance(counterbalanceFile, subjectBIDS);
        
        % Loop through runs starting from runStart
        for runIndex = runStart:4
            fprintf('Starting run %d for %s...\n', runIndex, subjectBIDS);
            
            % Load images and create textures
            images = makeTexture(win, image_dur, runIndex);
            
            % Run the experiment
            runExperiment(win, images.introTex, images.fixationTex, images.waitTex);
            
            % Log progress
            logProgress(subjectBIDS, runIndex, main_dir);
        end
        
        % Close Psychtoolbox
        Screen('CloseAll');
    else
        fprintf('Scan aborted by the user.\n');
        return;
    end
    
catch e
    % Handle errors and close Psychtoolbox
    Screen('CloseAll');
    rethrow(e);
end

%% Subfunctions

% Function to Load Counterbalance Scheme
% function sequence = loadCounterbalance(filePath, subjectBIDS)
% % Read the .tsv file
% data = readtable(filePath, 'FileType', 'text', 'Delimiter', '\t');

% % Find the subject row
% subjectRow = strcmp(data.Subject, subjectBIDS);
% if sum(subjectRow) == 0
%     error('Subject ID not found in counterbalance file.');
% end

% % Extract sequence as a numeric array
% sequence = table2array(data(subjectRow, 2:end)); % Skip the "Subject" column
% end


% Function to Load Images and Convert to Textures
function images = makeTexture(win, image_dir, runIndex)

if sequence(runIndex) == 0
    introImagePath = fullfile(image_dir, 'eyes_closed.png');
else
    introImagePath = fullfile(image_dir, 'eyes_open.png');
end
% Load images
images.intro = imread(introImagePath);
images.fixation = imread(fullfile(image_dir, 'fixation.png'));
images.wait = imread(fullfile(image_dir, 'end.png'));

% Create textures
images.introTex = Screen('MakeTexture', win, images.intro);
images.fixationTex = Screen('MakeTexture', win, images.fixation);
images.waitTex = Screen('MakeTexture', win, images.wait);
end


% Function to Run a Single Experiment Block
function runExperiment(win, introTex, fixationTex, waitTex)
% Display Intro Image
Screen('DrawTexture', win, introTex);
Screen('Flip', win);

% Wait for '5%' key press
waitForKeyPress('5%');

% Show Fixation Image for 8 minutes
Screen('DrawTexture', win, fixationTex);
Screen('Flip', win);
WaitSecs(480); % 8 minutes

% Show Wait Image
Screen('DrawTexture', win, waitTex);
Screen('Flip', win);

% Wait for a key press to proceed
waitForKeyPress('e');
end

% Function to Wait for a Specific Key Press
function waitForKeyPress(targetKey)
while true
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown && strcmp(KbName(keyCode), targetKey)
        break;
    end
end
end

% Function to Log Progress
function logProgress(subjectBIDS, runIndex, main_dir)
logFile = fullfile(main_dir, sprintf('/design/progress_log%s.txt', subjectBIDS));
fid = fopen(logFile, 'a');
if fid == -1
    error('Unable to open progress log file.');
end
fprintf(fid, 'Subject: %s, Completed Run: %d, Timestamp: %s\n', ...
    subjectBIDS, runIndex, datestr(now));
fclose(fid);
end
