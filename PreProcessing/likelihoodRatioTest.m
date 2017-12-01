function output = likelihoodRatioTest(uLogL, rLogL, dof)
%likelihoodRatioTest Compute the log likelihood ratio test, if unrestricted
%model can be significantly rejected from restricted model. i.e, if they are
%different enough
%   output = likelihoodRatioTest(uLogL, rLogL, dof)

[h, pValue, stat, cValue] = lratiotest(uLogL, rLogL, dof);

output.h = h; % logical value/vecotr: 1 = rejection of null, meaning unrestricted model fits the data better than restricted model
output.pValue = pValue; % < 0.005 = significatnly difference = rather convincing
output.stat = stat; % test statistics
output.cValue = cValue; % critical values determined by alpha

end

