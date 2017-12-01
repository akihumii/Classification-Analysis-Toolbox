function gain = inputReferMultiplier(bitInfo)
%inputReferMultiplier Compute the multiplier based on the default table
%   gain = inputReferMultiplier(bitInfo)

R = 1047.13;

S1 = bitInfo(1);
S2 = bitInfo(3:4);

if S1 == 1
    D1 = 4;
else
    D1 = 1;
end

if isequal(S2,[0,0])
    D2 = 1;
elseif isequal(S2,[0,1])
    D2 = 1.95;
elseif isequal(S2,[1,0])
    D2 = 2.85;
elseif isequal(S2,[1,1])
    D2 = 1/5.4325;
end

gain = R / (D1 * D2);
end

