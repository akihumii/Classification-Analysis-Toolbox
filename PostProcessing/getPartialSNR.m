fullfilenameAll = dir("*.fig")

range = 412:813;
for i = 1:numel(fullfilenameAll)
    h = openfig(fullfilenameAll(i).name);
    xEMGAll = arrayfun(@(x) x.YData(range), h.Children.Children, 'Uni', false);
    xEMG = [xEMGAll{:}];
    xEMG = xEMG(~isnan(xEMG));
    crossThreshLocs = cellfun(@(x) any(x>1e-5), xEMGAll);
    result.percentageCrossThresh(i,1) = mean(crossThreshLocs);
    result.meanValueAll(i,1) = mean(mean(vertcat(xEMGAll{crossThreshLocs}),2));
    result.maxValueAll(i,1) = mean(max(vertcat(xEMGAll{crossThreshLocs}),[],2));
    result.stdeValueAll(i,1) = std(mean(vertcat(xEMGAll{crossThreshLocs}),2))/numel(vertcat(xEMGAll{crossThreshLocs}));
    result.snrAll(i,1) = snr(xEMG,yEMG(1:numel(xEMG)));
    close(h)
    i
end
[~,result.p] = ttest(result.maxValueAll);
%%
figure
subplot(2,1,1)
hold on
bar(resultCh1.maxValueAll*1e6)
errorbar(resultCh1.maxValueAll'*1e6, resultCh1.stdeValueAll'*1e6, 'LineStyle', 'none', 'LineWidth', 2);
ylabel('Average CAP peak voltage (\muV)')
xticklabels(100:20:260)
title('Average CAP peak voltage and triggering probability ch1')
box on
yyaxis right
plot(resultCh1.percentageCrossThresh,'d','MarkerSize',8,'MarkerFaceColor','r')
ylim([0,1])
ylabel('Triggering Probability (threshold=10\muV)')

subplot(2,1,2)
hold on
bar(resultCh2.maxValueAll*1e6)
errorbar(resultCh2.maxValueAll*1e6, resultCh2.stdeValueAll*1e6, 'LineStyle', 'none');
xlabel('Stimulation Amplitude (\muA)')
xticklabels(100:20:260)
title('Average CAP peak voltage and triggering percentage ch2')
box on
yyaxis right
plot(resultCh2.percentageCrossThresh,'d','MarkerSize',8,'MarkerFaceColor','r')
ylim([0,1])
