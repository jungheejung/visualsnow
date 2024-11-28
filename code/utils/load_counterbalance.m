% Function to Load Counterbalance Scheme
function sequence = load_counterbalance(filePath, subjectID)
% Read the .tsv file
data = readtable(filePath, 'FileType', 'text', 'Delimiter', '\t');

% Find the subject row
subjectRow = strcmp(data.Subject, subjectID);
if sum(subjectRow) == 0
    error('Subject ID not found in counterbalance file.');
end

% Extract sequence for the subject
sequence = table2array(data(subjectRow, 2:end)); % Skip the "Subject" column
end