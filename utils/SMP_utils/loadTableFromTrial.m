function T = loadTableFromTrial(trial)

tableName = regexprep(extractTrialStem(trial.name),"%d","Table");
tableName = regexprep(tableName,"_Raw","");

try
    T = load(tableName); % loads as T
catch
    error("table is not on the path")
end

try
    T = T.T;
catch
    error("table under a different variable name")
    % TODO smarter way?
end

return