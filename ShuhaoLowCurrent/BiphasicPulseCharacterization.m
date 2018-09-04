%       Author LU SHUHAO
% Organization NUS SINAPSE
%
%

% CSV file
% ----------------------------------------------------------------------------------------------------------------------------------------
%CSV_DIR_PATH = 'G:\Users\lsilsh\Dropbox\NUS_SINAPSE\CSV\16Volt_Bi\2017-04-05_1742_Data\';
%CSV_DIR_PATH = 'G:\Users\lsilsh\Dropbox\NUS_SINAPSE\CSV_StimPulse\16Volt_Bi\2017-04-22_1700_Data\';
%CSV_DIR_PATH = 'C:\Users\AdminCOOP\Desktop\Data Characterization of LC\1K ohm resistor\300mA\';
CSV_DIR_PATH = 'C:\Users\AdminCOOP\Desktop\Data Characterization of LC\3.3K ohm resistor\';

CSV_FILES = strcat( CSV_DIR_PATH , '*.csv');

temp = dir( CSV_FILES );

CSV_RawDataFile_NameList = { temp.name }';
% CSV_RawDataFile_DateList = { temp.date }';
CSV_RawDataFile_DateList = { temp.name }';

CSV_RawDataFileList_Sorted = sortrows( [ CSV_RawDataFile_DateList CSV_RawDataFile_NameList ] , 1 );
CSV_RawDataFileList_Sorted( : , 1 ) = [];

CSV_FILE_NUM = numel( CSV_RawDataFile_NameList );

% Pulse Objects - Params Settings
% ----------------------------------------------------------------------------------------------------------------------------------------
% Initialization
PULSE_SAMPLE_SIZE = 1E+03;
PULSE_SAMPLE_INTERVAL = 5.00E-07;

Pulse_RawData_Voltage_Total = zeros( PULSE_SAMPLE_SIZE , CSV_FILE_NUM ); 

Pulse_RefLineSummary = zeros( CSV_FILE_NUM , 3 );
Pulse_RiseFallTimeSummary = zeros( CSV_FILE_NUM , 4 );
Pulse_RegionSummary = zeros( CSV_FILE_NUM , 12 );
Pulse_QSummary = zeros( CSV_FILE_NUM , 4 );
Pulse_GlitchPeakSummary = zeros( CSV_FILE_NUM , 4 );

% Input Current Objects
% ----------------------------------------------------------------------------------------------------------------------------------------
% CURRENT_DATA_SETS = CSV_FILE_NUM / 19;
CURRENT_DATA_SETS = CSV_FILE_NUM / length(CSV_RawDataFile_NameList);
%temp = [350;150;550;250;1000;950;850;650;900;600;750;200;400;700;450;500;800;300;100];
% temp = [ 100:50:1000 ]';
 CURRENT_STANDARD_SEQUENCE = [  100:50:400 ]';
%CURRENT_STANDARD_SEQUENCE = [  100 ]';

%temp1 = repmat( 1000:-50:100 , [ 4 1 ] );
%temp2 = repmat( 1000:-50:100 , [ 2 1 ] );
CURRENT_INPUT_SEQUENCE = repmat( CURRENT_STANDARD_SEQUENCE , CURRENT_DATA_SETS , 1 );
% CURRENT_STANDARD_SEQUENCE = [ 100:50:1000 ]';

CURRENT_GROUP_NUM = numel( unique( CURRENT_INPUT_SEQUENCE ) );

Current_RefLine_GroupMean = zeros( CURRENT_GROUP_NUM , 3 );
Current_RefLine_GroupStdev = zeros( CURRENT_GROUP_NUM , 3 );
Current_RiseFallTime_GroupMean = zeros( CURRENT_GROUP_NUM , 5 );
Current_RiseFallTime_GroupStd = zeros( CURRENT_GROUP_NUM , 5 );

% Resistor Object
% ----------------------------------------------------------------------------------------------------------------------------------------
%RESIS = 10.0E+03;
%RESIS = 1.98E+03;
%RESIS = 3.89E+03;
RESIS = 9.9E+03;

% Read all individual *.csv file
% ----------------------------------------------------------------------------------------------------------------------------------------
for i = 1 : CSV_FILE_NUM
    
    temp = strcat( CSV_DIR_PATH , char( CSV_RawDataFileList_Sorted(i) ) );
    
    % Read raw data
%     Pulse_RawData = csvread( temp , 0 , 3 );
Pulse_RawData = csvread( temp , 2 , 0 );

    % Extract voltage from raw data
    Pulse_RawData_Voltage = Pulse_RawData( : , 2 );
    
    Pulse_RawData_Voltage_Total( : , i ) = round(Pulse_RawData_Voltage,4);
    
end

% Calculate raw current data amplitude
% ----------------------------------------------------------------------------------------------------------------------------------------
Current_RawData_Total = Pulse_RawData_Voltage_Total ./ RESIS;
%Current_RawData_TotalSorted = sortrows( [ CURRENT_INPUT_SEQUENCE' ; Current_RawData_Total ]' , 1 )';

%
% Calculate parameters of biphasic pulse
% ----------------------------------------------------------------------------------------------------------------------------------------
for i = 1 : CSV_FILE_NUM
    
    [ GndRef , AnodRef , CathRef , ...
        AnodRiseTime , AnodFallTime , CathRiseTime , CathFallTime , ...
        AnodGlitchQ , AnodPulseQ , CathGlitchQ , CathPulseQ , ...
        AnodGlitchPeak , Index_AnodGlitchPeak , CathGlitchPeak , Index_CathGlitchPeak , ...
        Index_AnodRiseStart , Index_AnodRiseEnd , Index_AnodFallStart , Index_AnodFallEnd , ...
        Index_CathRiseStart , Index_CathRiseEnd , Index_CathFallStart , Index_CathFallEnd , ...
        Index_AnodGlitchStart , Index_AnodGlitchEnd , Index_CathGlitchStart , Index_CathGlitchEnd , stdRange, aveCath ,aveAnod] ...
    = BiphasicPulseCharacterize( Pulse_RawData_Voltage_Total( : , i ) , PULSE_SAMPLE_INTERVAL , RESIS );

    Pulse_RefLineSummary( i , : ) = [ GndRef aveAnod aveCath ];
    
    Pulse_RiseFallTimeSummary( i , : ) = [ AnodRiseTime AnodFallTime CathRiseTime CathFallTime ];
    
    Pulse_QSummary( i , : ) = [ AnodGlitchQ AnodPulseQ CathGlitchQ CathPulseQ ];
    
    Pulse_GlitchPeakSummary( i , : ) = [ Index_AnodGlitchPeak AnodGlitchPeak Index_CathGlitchPeak CathGlitchPeak ];
                                 
    Pulse_RegionSummary( i , : ) = [ Index_AnodRiseStart Index_AnodRiseEnd Index_AnodFallStart Index_AnodFallEnd ...
                                     Index_CathRiseStart Index_CathRiseEnd Index_CathFallStart Index_CathFallEnd ...
                                     Index_AnodGlitchStart Index_AnodGlitchEnd Index_CathGlitchStart Index_CathGlitchEnd];
    
end
%

%
% Calculate current reference line amplitude
% ----------------------------------------------------------------------------------------------------------------------------------------
Current_RefLineSummary = Pulse_RefLineSummary ./ RESIS;

% Add Current_Label_Input to each summary
% ----------------------------------------------------------------------------------------------------------------------------------------
Current_RefLineSummary_uA = [ CURRENT_INPUT_SEQUENCE Current_RefLineSummary .* 1.0E+06 ];
Current_RefLineSummary_uA_Sorted = sortrows( Current_RefLineSummary_uA , 1 );

% Calculate group mean & standard deviation - Anod / Cath Current Amp
% ----------------------------------------------------------------------------------------------------------------------------------------
for i = 1 : CURRENT_GROUP_NUM
    
    temp = find( Current_RefLineSummary_uA_Sorted( : , 1 ) == CURRENT_STANDARD_SEQUENCE(i) );
    
    temp1 = mean( Current_RefLineSummary_uA_Sorted( temp(1):temp(end) , 3 ) );
    temp2 = mean( Current_RefLineSummary_uA_Sorted( temp(1):temp(end) , 4 ) );
    
    temp3 = std( Current_RefLineSummary_uA_Sorted( temp(1):temp(end) , 3 ) );
    temp4 = std( Current_RefLineSummary_uA_Sorted( temp(1):temp(end) , 3 ) );
    
    Current_RefLine_GroupMean( i , : ) = [ CURRENT_STANDARD_SEQUENCE(i) temp1 temp2 ];
    Current_RefLine_GroupStdev( i , : ) = [ CURRENT_STANDARD_SEQUENCE(i) temp3 temp4 ];
    
end

% Calculate Absolute Error - Anod / Cath Current Amp
% ----------------------------------------------------------------------------------------------------------------------------------------
temp_anod_error = Current_RefLine_GroupMean( : , 1 ) - Current_RefLine_GroupMean( : , 2 );
temp_cath_error = Current_RefLine_GroupMean( : , 1 ) + Current_RefLine_GroupMean( : , 3 );

Current_AbsError_GroupeMean = [ Current_RefLine_GroupMean( : , 1 ) temp_anod_error temp_cath_error ];

% Calculate Group Mean and Standard Deviation - Rise/Fall Time
% ----------------------------------------------------------------------------------------------------------------------------------------
Current_RiseFallTimeSummary_Sorted = sortrows( [ CURRENT_INPUT_SEQUENCE Pulse_RiseFallTimeSummary ] , 1 );

temp1 = Current_RiseFallTimeSummary_Sorted( : , 2 );
temp2 = Current_RiseFallTimeSummary_Sorted( : , 3 );
temp3 = Current_RiseFallTimeSummary_Sorted( : , 4 );
temp4 = Current_RiseFallTimeSummary_Sorted( : , 5 );

for i = 1 : CURRENT_GROUP_NUM
    
    temp_index = ( Current_RiseFallTimeSummary_Sorted( : , 1 ) == CURRENT_STANDARD_SEQUENCE(i) );
    
    temp_mean1 = mean( temp1( temp_index ) );
    temp_mean2 = mean( temp2( temp_index ) );
    temp_mean3 = mean( temp3( temp_index ) );
    temp_mean4 = mean( temp4( temp_index ) );
    
    temp_std1 = std( temp1( temp_index ) );
    temp_std2 = std( temp2( temp_index ) );
    temp_std3 = std( temp3( temp_index ) );
    temp_std4 = std( temp4( temp_index ) );
    
    Current_RiseFallTime_GroupMean( i , : ) = [ CURRENT_STANDARD_SEQUENCE(i) temp_mean1  temp_mean2  temp_mean3  temp_mean4  ];
    Current_RiseFallTime_GroupStd( i , : ) = [ CURRENT_STANDARD_SEQUENCE(i) temp_std1 temp_std2 temp_std3 temp_std4 ];
    
end
%

% 
% Anod / Cath Current Glitch Amp
% ----------------------------------------------------------------------------------------------------------------------------------------
Current_GlitchPeakSummary = [ Pulse_GlitchPeakSummary( : , 1 ) ...
                              Pulse_GlitchPeakSummary( : , 2 ) ./ RESIS ...
                              Pulse_GlitchPeakSummary( : , 3 ) ...
                              Pulse_GlitchPeakSummary( : , 4 ) ./ RESIS ];

Current_GlitchPeakSummary_Sorted = sortrows( [ CURRENT_INPUT_SEQUENCE Current_GlitchPeakSummary ] , 1 );
                          



% Sort Anod/Cath GlitchQ and PulseQ
% ----------------------------------------------------------------------------------------------------------------------------------------
Current_QSummary_Sorted = sortrows( [ CURRENT_INPUT_SEQUENCE Pulse_QSummary ] , 1 );

%}