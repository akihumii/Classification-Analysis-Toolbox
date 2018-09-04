%       Author LU SHUHAO
% Organization NUS SINAPSE
%
%

% Define plot file path
% ----------------------------------------------------------------------------------------------------------------------------------------
%PLOT_FOLDER = 'G:\Users\lsilsh\Dropbox\NUS_SINAPSE\CSV_StimPulse\16Volt_Bi\2017-04-22_1700_Plot\';
%PLOT_FOLDER = 'G:\Users\lsilsh\Dropbox\NUS_SINAPSE\CSV_StimPulse\16Volt_Bi\2017-04-22_1700_Plot\';
% PLOT_FOLDER = 'C:\Users\AdminCOOP\Desktop\Data Characterization of LC\3.3K ohm resistor\';
PLOT_FOLDER = CSV_DIR_PATH;
PLOT_FORMAT = '-djpeg';

fig = gcf;
fig.PaperPositionMode = 'auto';

%
%% Plot individual current amplitude vs sample point
% ----------------------------------------------------------------------------------------------------------------------------------------
for i = 1 : CSV_FILE_NUM
    
    figure;
    plot( Current_RawData_Total( : , i ) * 1.0E+06 );
    title( strcat( '|In Amp| =' , num2str( CURRENT_INPUT_SEQUENCE(i) ) , 'uA' ) );
    xlabel( 'Sample Points = 1000 , Interval = 0.5 uS' );
    ylabel( 'Current Amp (uA)' );
    ylim( [ -1E+03 +1E+03 ] );
    grid on;
    
    print( strcat( PLOT_FOLDER , 'Amp' , num2str(i) , '-' , num2str( CURRENT_INPUT_SEQUENCE(i) ) ) , PLOT_FORMAT );
    
end
%

%
%% Plot all current amplitude vs sample point together
% ----------------------------------------------------------------------------------------------------------------------------------------
for i = 1 : CSV_FILE_NUM
    
    figure;
    plot( Current_RawData_Total( : , i ) * 1.0E+06 );
    hold on;
    
end

    title( '|In Amp| = 100~1000 uA' );
    xlabel( 'Sample Points = 1000 , Interval = 0.5 uS' );
    
    ylabel( 'Current Amp (uA)' );
    set( gca , 'YTick' , [ -1100:100:1100 ] );
    %set( gcs , 'YTicksLabel' , {} );
    ylim( [ -1E+03 +1E+03] );
    
    grid on;    
      
    print( strcat( PLOT_FOLDER , 'AmpAll' ) , PLOT_FORMAT );
%

%
%% Plot Different Classified Region
% -------------------------------------------------------------------------------------------
%
for i = 1 : CSV_FILE_NUM
    
    figure;
    plot( Current_RawData_Total( : , i ) * 1.0E+06 );
    title( strcat( '|In Amp| =' , num2str( CURRENT_INPUT_SEQUENCE(i) ) , 'uA' ) );
    xlabel('Sample Points = 1000 , Interval = 0.5 uS');
    ylabel('Current Amp(uA)');
    ylim( [  -1E+03 +1E+03] );
    set( gca , 'YTick' , [-1100:100:1100] );
    grid on;
    
    hold on;
    
    temp_y_range = [ -1E+03 +1E+03 ];
    
    % Anod Rise Start
    temp = line( [ Pulse_RegionSummary( i , 1 ) Pulse_RegionSummary( i , 1 ) ] , temp_y_range  );
    temp.Color = 'r';

    % Anod Rise End
    temp = line( [ Pulse_RegionSummary( i , 2 ) Pulse_RegionSummary( i , 2 ) ] , temp_y_range  );
    temp.Color = 'r';

    % Anod Fall Start
    temp = line( [ Pulse_RegionSummary( i , 3 ) Pulse_RegionSummary( i , 3 ) ] , temp_y_range  );
    temp.Color = 'r';

    % Anod Fall End
    temp = line( [ Pulse_RegionSummary( i , 4 ) Pulse_RegionSummary( i , 4 ) ] , temp_y_range  );
    temp.Color = 'r';

    % Cath Rise Start
    temp = line( [ Pulse_RegionSummary( i , 5 ) Pulse_RegionSummary( i , 5 ) ] , temp_y_range  );
    temp.Color = 'r';

    % Cath Rise End
    temp = line( [ Pulse_RegionSummary( i , 6 ) Pulse_RegionSummary( i , 6 ) ] , temp_y_range  );
    temp.Color = 'r';

    % Cath Fall Start
    temp = line( [ Pulse_RegionSummary( i , 7 ) Pulse_RegionSummary( i , 7 ) ] , temp_y_range  );
    temp.Color = 'r';

    % Cath Fall End
    temp = line( [ Pulse_RegionSummary( i , 8 ) Pulse_RegionSummary( i , 8 ) ] , temp_y_range  );
    temp.Color = 'r';

    %
    % Anod Glitch Start
    temp = line( [ Pulse_RegionSummary( i , 9 ) Pulse_RegionSummary( i , 9 ) ] , temp_y_range  );
    temp.Color = 'm';

    % Anod Glitch End
    temp = line( [ Pulse_RegionSummary( i , 10 ) Pulse_RegionSummary( i , 10 ) ] , temp_y_range  );
    temp.Color = 'm';

    % Cath Glitch Start
    temp = line( [ Pulse_RegionSummary( i , 11 ) Pulse_RegionSummary( i , 11 ) ] , temp_y_range  );
    temp.Color = 'm';

    % Cath Glitch End
    temp = line( [ Pulse_RegionSummary( i , 12 ) Pulse_RegionSummary( i , 12 ) ] , temp_y_range  );
    temp.Color = 'm';
    %

    
    hold off;
    
    print( strcat( PLOT_FOLDER , 'Region' , num2str(i) ) , PLOT_FORMAT );
    
end
%

%
%% Plot current amplitude & reference line
% ----------------------------------------------------------------------------------------------------------------------------------------
figure
hold on
for i = 1 : CSV_FILE_NUM
    
%     figure;
    plot( Current_RawData_Total( : , i ) * 1.0E+06 );

    
    title( strcat( '|In Amp|=' , num2str( CURRENT_INPUT_SEQUENCE(i) ) , 'uA' ) );
    xlabel('Sample Points = 1000 , Interval = 0.5 uS');
    ylabel('Current Amp(uA)');
    ylim( [  -1E+03 +1E+03 ] );
    grid on;
    hold on;
    
    % Current Amp = GND
    temp = refline( [ 0 Current_RefLineSummary_uA( i , 2 ) ] );
    temp.Color = 'r';
    
    % Text Label - Current Amp = GND
    temp = text( PULSE_SAMPLE_SIZE , Current_RefLineSummary_uA( i , 2 ) , ...
                num2str( Current_RefLineSummary_uA( i , 2 ) ) ...
                );
    temp.Color = 'r';
    
    % Current Amp Anod
    temp = refline( [ 0 Current_RefLineSummary_uA( i , 3 ) ] );
    temp.Color = 'r';

    % Text Label - Current Amp Anod
    temp = text( PULSE_SAMPLE_SIZE , Current_RefLineSummary_uA( i , 3 ) , ...
            num2str( Current_RefLineSummary_uA( i , 3 ) ) ...
            );
    temp.Color = 'r';
     
    % Current Amp Cath
    temp = refline( [ 0 Current_RefLineSummary_uA( i , 4 ) ] );
    temp.Color = 'r';

    % Text Label - Current Amp Cath
    temp = text( PULSE_SAMPLE_SIZE , Current_RefLineSummary_uA( i , 4 ) , ...
            num2str( Current_RefLineSummary_uA( i , 4 ) ) ...
            );
    temp.Color = 'r';
    
    %
    % Text Label - Anod Glitch Peak/Index    
    temp = text( Current_GlitchPeakSummary( i , 1 ) , Current_GlitchPeakSummary( i , 2 ) * 1.0E+06 , ...
            num2str( Current_GlitchPeakSummary( i , 2 ) * 1.0E+06 ) ...
            );
    temp.Color = 'r';
    
    % Text Label - Cath Glitch Peak/Index
    temp = text( Current_GlitchPeakSummary( i , 3 ) , Current_GlitchPeakSummary( i , 4 ) * 1.0E+06 , ...
             num2str( Current_GlitchPeakSummary( i , 4 ) * 1.0E+06 ) ...
            );
    temp.Color = 'r';
    %
    
    % std Range
    xRange = xlim;
    temp = plot( xRange, [ stdRange stdRange ] );
    temp.Color = 'g';

%     hold off;
  
    print( strcat( PLOT_FOLDER , 'AmpWithRef' , num2str(i) , '-' , num2str( CURRENT_INPUT_SEQUENCE(i) ) ) , PLOT_FORMAT );
      
end
%

%
%% Plot Out Amp
% -------------------------------------------------------------------------------------------
temp_ax1 = subplot( 1,3,1 );
subplot( temp_ax1 );

temp = bar( [ Current_RefLineSummary_uA_Sorted( : , 3 ) Current_RefLineSummary_uA_Sorted( : , 4 ) ] );

title( 'Biphasic Out Amp' );

xlabel( 'No. Of Pulses' );
set( gca , 'XTick' , [ 0:10:100 ] );
%set( gca , 'XTickLabel' , { '100','200','300','400','500','600','700','800','900','1000','1100'} );

ylabel( 'Current Amp(uA)' );
ylim( [ -1.5E+03 +1.5E+03 ] );
legend( 'Anod' , 'Cath' );
grid on;
%

% Plot In Amp vs Out Amp Mean
temp_ax2 = subplot( 1,3,2 );
subplot( temp_ax2 );

temp_data = [ CURRENT_STANDARD_SEQUENCE Current_RefLine_GroupMean( : , 2 ) ...
              -CURRENT_STANDARD_SEQUENCE Current_RefLine_GroupMean( : , 3 ) ...
            ];

temp = bar( temp_data );

temp(1).FaceColor = 'r';
temp(1).EdgeColor = 'r';
temp(2).FaceColor = 'b';
temp(2).EdgeColor = 'b';
temp(3).FaceColor = 'r';
temp(3).EdgeColor = 'r';
temp(4).FaceColor = 'y';
temp(4).EdgeColor = 'y';

title( 'In Amp vs Out Amp Mean' );

xlabel( 'No. of Steps' );
set( gca , 'XTick' , [ 1:1:20 ] );

ylabel( 'Current Amp(uA)' );
ylim( [ -1.5E+03 +1.5E+03 ] );
legend( 'Anod In Stad' , 'Anod Out Mean' , 'Cath In Stad' , 'Cath Out Mean' );
grid on;

% Plot Absolute Error
temp_ax3 = subplot( 1,3,3 );
subplot( temp_ax3 );

temp_data = abs( Current_AbsError_GroupeMean( : , 2:3 ) );

bar( temp_data );

title( 'Absolute Error' );

xlabel( 'InStim Amp' );
set( gca , 'XTick' , [ 1:2:20 ] );
set( gca , 'XTickLabel' , { '100','200','300','400','500','600','700','800','900','1000','1100'} );

ylabel( 'Error Amplitude(uA)' );
legend( 'Anod Mean' , 'Cath Mean' );
grid on;

print( strcat( PLOT_FOLDER , 'AmpAbsError' ) , PLOT_FORMAT );
%

%
%% Plot Rise/Fall Time of Anod/Cath 
% -------------------------------------------------------------------------------------------

% Anod Rise Time
temp1 = Current_RiseFallTime_GroupMean( : , 2 ) * 1.0E+06;
temp2 = Current_RiseFallTime_GroupStd( : , 2 )  * 1.0E+06;

temp_ax = subplot( 2,2,1 );
subplot( temp_ax );

bar( temp1 );

title( 'Anod Rise Time' );
ylabel( 'Time (uS)' );
% ylim( [ 0 3 ] );

xlabel( 'InStim Amp(uA)' );
set( gca , 'XTick' , [1:2:20] );
set( gca , 'XTickLabel' , { '100','200','300','400','500','600','700','800','900','1000','1100'} );

grid on;

hold on;
temp = errorbar( temp1 , temp2 , 'r' );
set( temp , 'linestyle' , 'none' );
hold off;

% Anod Fall Time
temp1 = Current_RiseFallTime_GroupMean( : , 3 ) * 1.0E+06;
temp2 = Current_RiseFallTime_GroupStd( : , 3 )  * 1.0E+06;

temp_ax = subplot( 2,2,2 );
subplot( temp_ax );

bar( temp1 );

title( 'Anod Fall Time' );
ylabel( 'Time (uS)' );
%ylim( [ 0 3 ] );

xlabel( 'InStim Amp(uA)' );
set( gca , 'XTick' , [1:2:20] );
set( gca , 'XTickLabel' , { '100','200','300','400','500','600','700','800','900','1000','1100'} );

grid on;

hold on;
temp = errorbar( temp1 , temp2 , 'r' );
set( temp , 'linestyle' , 'none' );
hold off;

% Cath Rise Time
temp1 = Current_RiseFallTime_GroupMean( : , 4 ) * 1.0E+06;
temp2 = Current_RiseFallTime_GroupStd( : , 4 )  * 1.0E+06;

temp_ax = subplot( 2,2,3 );
subplot( temp_ax );

bar( temp1 );

title( 'Cath Rise Time' );
ylabel( 'Time (uS)' );
% ylim( [ 0 3 ] );

xlabel( 'InStim Amp(uA)' );
set( gca , 'XTick' , [1:2:20] );
set( gca , 'XTickLabel' , { '100','200','300','400','500','600','700','800','900','1000','1100'} );

grid on;

hold on;
temp = errorbar( temp1 , temp2 , 'r' );
set( temp , 'linestyle' , 'none' );
hold off;

% Cath Fall Time
temp1 = Current_RiseFallTime_GroupMean( : , 5 ) * 1.0E+06;
temp2 = Current_RiseFallTime_GroupStd( : , 5 )  * 1.0E+06;

temp_ax = subplot( 2,2,4 );
subplot( temp_ax );

bar( temp1 );

title( 'Cath Fall Time' );
ylabel( 'Time (uS)' );
% ylim( [ 0 3 ] );

xlabel( 'InStim Amp(uA)' );
set( gca , 'XTick' , [1:2:20] );
set( gca , 'XTickLabel' , { '100','200','300','400','500','600','700','800','900','1000','1100'} );

grid on;

hold on;
temp = errorbar( temp1 , temp2 , 'r' );
set( temp , 'linestyle' , 'none' );
hold off;

print( strcat( PLOT_FOLDER , 'RiseFallTime' ) , PLOT_FORMAT );
%

%
%% Plot GlitchQ and PulseQ
% Anod / Cath
% -------------------------------------------------------------------------------------------
temp_anod_glitch_Q = Current_QSummary_Sorted( : , 2 );
temp_anod_pulse_Q = Current_QSummary_Sorted( : , 3 );
temp_cath_glitch_Q = Current_QSummary_Sorted( : , 4 );
temp_cath_pulse_Q = Current_QSummary_Sorted( : , 5 );

temp_anod_glitch_Q_mean = zeros( numel( CURRENT_STANDARD_SEQUENCE ) , 1 );
temp_anod_pulse_Q_mean = zeros( numel( CURRENT_STANDARD_SEQUENCE ) , 1 );
temp_cath_glitch_Q_mean = zeros( numel( CURRENT_STANDARD_SEQUENCE ) , 1 );
temp_cath_pulse_Q_mean = zeros( numel( CURRENT_STANDARD_SEQUENCE ) , 1 );

for i = 1 : numel( CURRENT_STANDARD_SEQUENCE )
   
    figure;
    temp_mask = ( Current_GlitchPeakSummary_Sorted( : , 1 ) ==  CURRENT_STANDARD_SEQUENCE(i) );
    
    temp_anod_glitch_Q_mean( i , : ) = mean( temp_anod_glitch_Q( temp_mask ) );
    temp_anod_pulse_Q_mean( i , : ) = mean( temp_anod_pulse_Q( temp_mask ) );
    temp_cath_glitch_Q_mean( i , : ) = mean( temp_cath_glitch_Q( temp_mask ) );
    temp_cath_pulse_Q_mean( i , : ) = mean( temp_cath_pulse_Q( temp_mask ) );
    
end

% Plot Anod Glitch Q Mean
ax1 = subplot( 2 , 2 , 1 );
subplot( ax1 );

bar( temp_anod_glitch_Q_mean );
title( 'Charge Injection - Anod Glitch' );
%legend( 'Anod Glith' , 'Anod Pulse' );
ylabel( 'Charges(Coulomb)' );
xlabel( '100 ~ 1000uA Step = 50uA' );

set( gca , 'XTick' , [1:2:19] );
set( gca , 'XTickLabel' , {'100','200','300','400','500','600','700','800','900','1000'} );
grid on;
%

% Plot Cath Glitch
ax2 = subplot( 2 , 2 , 2 );
subplot( ax2 );

bar( temp_cath_glitch_Q_mean );
title( 'Charge Injection - Cath Glitch' );
%legend( 'Cath Glith' , 'Cath Pulse' );
ylabel( 'Charges(Coulomb)' );
xlabel( '100 ~ 1000uA Step = 50uA' );

set( gca , 'XTick' , [1:2:19] );
set( gca , 'XTickLabel' , {'100','200','300','400','500','600','700','800','900','1000'} );
grid on;
%

% Calculate ratio of GlitchQ / PulseQ
temp_anod_glitch_pulse_charge_ratio = temp_anod_glitch_Q_mean ./ temp_anod_pulse_Q_mean * 100;
temp_cath_glitch_pulse_charge_ratio = temp_cath_glitch_Q_mean ./ temp_cath_pulse_Q_mean * 100;

% Plot anod GlitchQ / anod PulseQ
ax3 = subplot( 2 , 2 , 3 );
subplot( ax3 );

bar( temp_anod_glitch_pulse_charge_ratio );
title( 'Charge Ratio - Anod Glitch/Pulse' );
legend( 'Anod Glith/Pulse' );
ylabel( 'Percent %' );
xlabel( '100 ~ 1000uA , Step = 50uA' );

set( gca , 'XTick' , [1:2:19] );
set( gca , 'XTickLabel' , {'100','200','300','400','500','600','700','800','900','1000'} );
grid on;

% Plot cath GlitchQ / cath PulseQ
ax4 = subplot( 2 , 2 , 4 );
subplot( ax4 );

bar( temp_cath_glitch_pulse_charge_ratio );
title( 'Charge Ratio - Cath Glitch/Pulse' );
legend( 'Cath Glith/Pulse' );
ylabel( 'Percent %' );
xlabel( '100 ~ 1000uA , Step = 50uA' );

set( gca , 'XTick' , [1:2:19] );
set( gca , 'XTickLabel' , {'100','200','300','400','500','600','700','800','900','1000'} );
grid on;

print( strcat( PLOT_FOLDER , 'QGlitchPulseRatio' ) , PLOT_FORMAT );


%

%





