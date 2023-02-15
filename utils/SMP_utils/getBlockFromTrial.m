function trialBlock = getBlockFromTrial(trial, varargin)
% option to include table argument or not

if nargin == 1
    T = loadTableFromTrial(trial);
elseif nargin == 2
    T = varargin{1};
else
    error("too many input arguments")
end

trialIdx = find(T.timestamp == trial.timestamp);
trialBlock = T.trialBlock(trialIdx);

return