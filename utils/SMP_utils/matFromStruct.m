function mat = matFromStruct(struct,fieldName)
% Each entry of the field should be a 1D vector of the same size

nX = size(struct,2);
nY = length(struct(1).(fieldName));

mat = zeros(nX,nY);
for i = 1:nX
    if length(struct(i).(fieldName)) ~= nY
        error("vectors must be the same length")
    end
    mat(i,:) = struct(i).(fieldName);
end

end