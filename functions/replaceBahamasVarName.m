function varNameUse = replaceBahamasVarName(varNameFind,bahamasVars)

% Script for replacing the bahamas variable name with a corresponding
% unified one. This is necessary, since bahamas variable names changed
% often...

% Load bahamas variable names
nametable = bahamasNetCDFVarTable;
% Find index of desired variable in list
[a,~] = find(strcmp(nametable,varNameFind));

% Get unique indices
a = unique(a);

% Check if found variables form name table are in its first column
c = ismember(nametable(a,:),bahamasVars);

% If the variable name is found in more than one column, select the first one listed
if size(c,1)>1
    c = c(1,:);
    a = a(1);
    disp('Att: selected first found variable; check if this is the right one!')
end

% If more than one variable is found, 
if sum(c)>1
    % Loop all bahamas variables
    for i=1:length(bahamasVars)
        % Get column of variables, i.e. the column corresponding to this
        % bahamas name format
        [~,col{i}] = find(strcmp(nametable,bahamasVars{i}));
    end
    
    % Concatenate all columns
    col = vertcat(col{:});
    % Count how often each column is used
    col_count = hist(col,unique(col));
    
    % Use the one with the most matching entries
    col_use = find(col_count==max(col_count));
    
    % Copy column value to c
    c = col_use;
end

% Copy bahamas variable name to output variable
varNameUse = nametable(a,c);
