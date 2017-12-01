%% Plot duration versus weight & current

clear

[files,path,iter] = selectFiles();
fileName = fullfile(path,files{1});
data1 = xlsread(fileName,1,'B1:F5'); % Excel range
data2 = xlsread(fileName,1,'I1:M5');
data3 = xlsread(fileName,1,'P1:T5');
data4 = xlsread(fileName,1,'AD1:AH3');

%% average
average1 = mean(data1,2);
average2 = mean(data2,2);
average3 = mean(data3,2);
average4 = mean(data4,2);

%% standard deviation
std1 = std(data1');
std2 = std(data2');
std3 = std(data3');
std4 = std(data4');

%% standard error
num1 = size(data1,2);
num2 = size(data2,2);
num3 = size(data3,2);
num4 = size(data4,2);
stde1 = std1 / sqrt(num1);
stde2 = std2 / sqrt(num2);
stde3 = std3 / sqrt(num3);
stde4 = std4 / sqrt(num4);

%% plotting
close all

fig1 = figure;
hold on
bar(average4) % single data % CHANGE
errorbar(average4,stde4,'ro') % CHANGE
ax1 = gca;
ax1.XTick = 1:num4; % CHANGE
ax1.XTickLabels = {'shit', 'shit','shit'}; % CHANGE
xlabel('Current (mA)')
ylabel('Force (N)')
legend('Weight 20g') % CHANGE
hold off

fig2 = figure;
hold on
bar([average2,average3]) % compare % CHANGE
xArray1 = (1:5) - 0.15;
xArray2 = (1:5) + 0.15;
errorbar(xArray1,average2,stde2,'bo') % errorbar 1 % CHANGE
errorbar(xArray2,average3,stde3,'ro') % errorbar 2 % CHANGE
ax1 = gca;
ax1.XTick = 1:num1; % CHANGE
ax1.XTickLabels = {'20','40','50','70','100'}; % CHANGE
xlabel('Weight (g)')
ylabel('Force (N)')
legend({'average2';'average3'}) % CHANGE
hold off





