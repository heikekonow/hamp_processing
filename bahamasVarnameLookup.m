function TrueNames = bahamasVarnameLookup(VariableNames)

% Load variable name table for different bahamas types
nametable = bahamasNetCDFVarTable;

TrueNames = cell(length(VariableNames),1);
for i=1:length(VariableNames)
    [row,~] = find(strcmp(VariableNames{i},nametable));
    if numel(unique(row))~=1
        if strcmp(VariableNames{i},'TIME')&&i==1
            row = 1;
            TrueNames{i,1} = nametable(row(1),1);
        elseif strcmp(VariableNames{i},'TIME')&&i~=1
            row = row(2);
            TrueNames{i,1} = nametable(row(1),1);
        else
            error('Something seems to be wrong with the nametable')
        end
    else
        TrueNames{i,1} = nametable(row(1),1);
    end
end

TrueNames = [TrueNames{:}];