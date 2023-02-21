function idx = getTrialIdx(trial,varargin)
% option to include table argument or not

if nargin == 1
    T = loadTableFromTrial(trial);
elseif nargin == 2
    T = varargin{1};
else
    error("too many input arguments")
end

idx = find(T.timestamp == trial.timestamp);

return