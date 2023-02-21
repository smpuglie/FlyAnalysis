function T = loadTableFromTrial(trial,varargin)

tableName = regexprep(extractTrialStem(trial.name),"%d","Table");
tableName = regexprep(tableName,"_Raw","");

if nargin > 1 
    if varargin{1} ~= "led"
        error('The only option for input 2 is "led"')
    end

    tableName = regexprep(tableName,"_Table","_Table_wLedAmp");
end

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