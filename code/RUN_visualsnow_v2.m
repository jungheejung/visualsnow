% Main Script: Psychtoolbox with counterbalanced intro images from .tsv

current_dir = pwd;
main_dir = fileparts(current_dir);

% Prompt for subject number and starting run index
subjectNum = input('Enter subject number (e.g., 1 for sub-01): ');
runStart = input('Enter starting run index (1-8): ');
subjectBIDS = sprintf('sub-%02d', subjectNum); % Format as sub-01, sub-02, etc.

% Confirmation prompt
confirmationMessage = sprintf('\nWe will start the scan for %s, run %d. \nWould you like to proceed? (y/n): ', subjectBIDS, runStart);
proceed = input(confirmationMessage, 's');

if ~strcmpi(proceed, 'y')
    fprintf('Scan aborted by the user.\n');
    return;
end

fprintf('Proceeding with the scan for %s, run %d.\n', subjectBIDS, runStart);


try
    % Setup Psychtoolbox
    Screen('Preference', 'SkipSyncTests', 1);
    [win, rect] = Screen('OpenWindow', max(Screen('Screens')), [0 0 0]);
    Screen('TextSize', win, 40);
    HideCursor;
    % Load Counterbalance Scheme
    counterbalanceFile = '../design/counterbalance_sequences.tsv';
    sequence = loadCounterbalance(counterbalanceFile, subjectBIDS);

    % Loop through runs starting from runStart
    for runIndex = runStart:8
        fprintf('Starting run %d for %s...\n', runIndex, subjectBIDS);
        image_dir = fullfile(main_dir, 'stimuli');
        % Load images and create textures
        images = makeTexture(win, image_dir, runIndex, sequence);

        % Run the experiment
        runExperiment(win, images.introTex, images.fixationTex, images.waitTex, images);
        %runExperiment(win, images.introTex, images.fixationTex, images.waitTex);

        % Log progress
        logProgress(subjectBIDS, runIndex, main_dir);
    end

    % Close Psychtoolbox
    Screen('CloseAll');
    ShowCursor;
catch e
    % Handle errors and close Psychtoolbox
    Screen('CloseAll');
    rethrow(e);
end

%% Subfunctions

% Function to Load Counterbalance Scheme
function sequence = loadCounterbalance(filePath, subjectBIDS)
% Read the .tsv file
data = readtable(filePath, 'FileType', 'text', 'Delimiter', '\t');

% Find the subject row
subjectRow = strcmp(data.subject, subjectBIDS);
if sum(subjectRow) == 0
    error('Subject ID not found in counterbalance file.');
end

% Extract sequence as a numeric array
sequence = table2array(data(subjectRow, 2:end)); % Skip the "Subject" column
end



% Function to Load Images and Convert to Textures
function images = makeTexture(win, image_dir, runIndex, sequence)

if sequence(runIndex) == 0
    introImagePath = fullfile(image_dir, 'eyes_closed.png');
else
    introImagePath = fullfile(image_dir, 'eyes_open.png');
end
% Load images
images.intro = imread(introImagePath);
images.fixation = imread(fullfile(image_dir, 'fixation.png'));
images.wait = imread(fullfile(image_dir, 'end.png'));

% Store the dimensions of each image
images.introSize = size(images.intro ); % [height, width, channels]
images.fixationSize = size(images.fixation);
images.waitSize = size(images.wait);

% Create textures
images.introTex = Screen('MakeTexture', win, images.intro);
images.fixationTex = Screen('MakeTexture', win, images.fixation);
images.waitTex = Screen('MakeTexture', win, images.wait);
end


% Function to Run a Single Experiment Block
function runExperiment(win, introTex, fixationTex, waitTex, images)
    % Get screen size
    [screenXpixels, screenYpixels] = Screen('WindowSize', win);
    
    % Function to calculate the dstRect while preserving aspect ratio
    function dstRect = calculateAspectRect(imageSize)
        % Get the dimensions of the image
        imageWidth = imageSize(2); % Width
        imageHeight = imageSize(1); % Height

        % Calculate the aspect ratio
        aspectRatio = imageWidth / imageHeight;

        % Scale based on the screen dimensions
        if (screenXpixels / screenYpixels) > aspectRatio
            % Image is taller relative to the screen, scale by height
            scaledHeight = screenYpixels * 0.8; % Use 80% of screen height
            scaledWidth = scaledHeight * aspectRatio;
        else
            % Image is wider relative to the screen, scale by width
            scaledWidth = screenXpixels * 0.8; % Use 80% of screen width
            scaledHeight = scaledWidth / aspectRatio;
        end

        % Center the scaled rectangle
        dstRect = CenterRectOnPointd([0 0 scaledWidth scaledHeight], ...
                                     screenXpixels / 2, screenYpixels / 2);
    end

    % Calculate rectangles for each texture
    % Calculate rectangles for each texture
    introDstRect = calculateAspectRect(images.introSize);
    fixationDstRect = calculateAspectRect(images.fixationSize);
    waitDstRect = calculateAspectRect(images.waitSize);
% Display Intro Image
Screen('DrawTexture', win, introTex, [], introDstRect);
Screen('Flip', win);

% Wait for '5%' key press
waitForKeyPress('5%');

% Show Fixation Image for 8 minutes
Screen('DrawTexture', win, fixationTex, [], fixationDstRect);
Screen('Flip', win);
WaitSecs(480); % 8 minutes 480s

% Show Wait Image
Screen('DrawTexture', win, waitTex, [], waitDstRect);
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
