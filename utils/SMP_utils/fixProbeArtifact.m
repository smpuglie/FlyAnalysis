function y = fixProbeArtifact(x, threshold)

% dx = [0 diff(x)];
% 
% %test:
% dxThresholdNeg = min(max(20,x-70),dxThresholdPos);
% 
% artifactStarts = find(dx < -dxThresholdNeg)-1;
% artifactEnds = find(dx > dxThresholdPos)+1;
% 
% nArtifacts = length(artifactStarts);
% 
% y = x;
% if nArtifacts ~= length(artifactEnds)
% %     figure; subplot(2,1,1); plot(x); subplot(2,1,2); plot(dx);
% %     error("choose a different threshold")
%     disp("trial artifact could not be resolved")
% %     nArtifacts = min(nArtifacts,length(artifactEnds)); %BAD
% else
%     for i = 1:nArtifacts
%         y(artifactStarts(i):artifactEnds(i)) = NaN;
%     end
% end

artifactStarts = find(x < threshold);
nArtifacts = length(artifactStarts);
y = x;
if nArtifacts > 0
%     figure; plot(x);
    disp("trial contains artifact")
end
for i = 1:nArtifacts
    artifactStart = artifactStarts(i) - 1;
    artifactEnd = find(x(artifactStart:end) > threshold,1) + artifactStart + 1;
    if isempty(artifactEnd)
        artifactEnd = length(x);
    end
    y(artifactStart:artifactEnd) = NaN;
end

end