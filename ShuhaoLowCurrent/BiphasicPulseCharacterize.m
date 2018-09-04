%       Author LU SHUHAO
% Organization NUS SINAPSE
%
%

function [ GndRef , AnodRef , CathRef , ...
        AnodRiseTime , AnodFallTime , CathRiseTime , CathFallTime , ...
        AnodGlitchQ , AnodPulseQ , CathGlitchQ , CathPulseQ , ...
        AnodGlitchPeak , Index_AnodGlitchPeak , CathGlitchPeak , Index_CathGlitchPeak , ...
        Index_AnodRiseStart , Index_AnodRiseEnd , Index_AnodFallStart , Index_AnodFallEnd , ...
        Index_CathRiseStart , Index_CathRiseEnd , Index_CathFallStart , Index_CathFallEnd , ...
        Index_AnodGlitchStart , Index_AnodGlitchEnd , Index_CathGlitchStart , Index_CathGlitchEnd , stdRange , aveCath , aveAnod] ...
        = BiphasicPulseCharacterize( SampleData , SAMPLE_INTERVAL , RESIS )
   
% Find unique SampleData
% -----------------------------------------------------------------------------------------------------------------
SampleDataUnique = unique( SampleData );

% Histogram method - find reference line for ground , anod , and cath
% -----------------------------------------------------------------------------------------------------------------
format short
[ temp1 , temp2 ] = hist( SampleData , SampleDataUnique );

Hist_Occurance = temp1';
Hist_SampleData = temp2;

% Define GndRef

Hist_SampleData_Abs = abs(Hist_SampleData);
GndRef = min(Hist_SampleData_Abs);
HistIndex_GndRef = find(Hist_SampleData_Abs == GndRef);
 
% Find CathRef
HistOccurance_CathRef = max( Hist_Occurance( 1 : HistIndex_GndRef - 5 ) );

% Find average of cathodic stimulation value
HistOccurance_Index_CathRef = find(Hist_Occurance == HistOccurance_CathRef);

totalCath = 0;
totalNumOccuranceC = 0;
for i = -1:1
    totalCath = totalCath + Hist_Occurance(HistOccurance_Index_CathRef+i)*Hist_SampleData(HistOccurance_Index_CathRef+i);
    totalNumOccuranceC = totalNumOccuranceC + Hist_Occurance(HistOccurance_Index_CathRef+i);
end
aveCath = totalCath / totalNumOccuranceC;

HistIndex_CathRef = find( Hist_Occurance( 1 : HistIndex_GndRef - 1 ) == HistOccurance_CathRef , 1 , 'last' );

CathRef = Hist_SampleData( HistIndex_CathRef );

% Find AnodRef
HistOccurance_AnodRef = max( Hist_Occurance( HistIndex_GndRef + 5 : end ) );

% Find average of cathodic stimulation value

HistOccurance_Index_AnodRef = find(Hist_Occurance == HistOccurance_AnodRef);

totalAnod = 0;
totalNumOccuranceA = 0;

for i = -1:1
    totalAnod = totalAnod + Hist_Occurance(HistOccurance_Index_AnodRef+i)*Hist_SampleData(HistOccurance_Index_AnodRef+i);
    totalNumOccuranceA = totalNumOccuranceA + Hist_Occurance(HistOccurance_Index_AnodRef+i);
end
aveAnod = totalAnod / totalNumOccuranceA;

HistIndex_AnodRef = find( Hist_Occurance( HistIndex_GndRef + 1 : end ) == HistOccurance_AnodRef , 1 , 'last' );

AnodRef = Hist_SampleData( max( HistIndex_AnodRef ) + HistIndex_GndRef );

% Find Point Index - Anod/Gnd/Cath Reference Line
% -----------------------------------------------------------------------------------------------------------------
CathRef_I = find( SampleData == CathRef );
GndRef_I = find( abs(SampleData) == GndRef );
AnodRef_I = find( SampleData == AnodRef );

% Find start/end index of rise/fall transition to define each region
% -----------------------------------------------------------------------------------------------------------------

% affected by glitch, cannot use this approach -> Index_AnodRiseEnd = min( AnodRef_I );
Index_AnodFallStart = max( AnodRef_I );

% Index_AnodRiseEnd = min( AnodRef_I( AnodRef_I > Index_AnodRiseStart ) );
Index_AnodRiseEnd = AnodRef_I(1);

% affected by glitch, cannot use this approach -> Index_CathRiseEnd = min( CathRef_I );
Index_CathFallStart = max( CathRef_I );

Index_AnodRiseStart = max( GndRef_I ( GndRef_I < Index_AnodFallStart ) );
%Index_AnodRiseStart = floor( (Index_AnodRiseEnd +  Index_CathFallStart)/2 );
Index_AnodFallEnd = min( GndRef_I ( GndRef_I > Index_AnodFallStart ) );

Index_CathRiseStart = max( GndRef_I( GndRef_I < Index_CathFallStart ) );
Index_CathFallEnd = min( GndRef_I( GndRef_I > Index_CathFallStart ) );
%Index_CathFallEnd = floor( (Index_AnodRiseEnd +  Index_CathFallStart)/2 );

Index_CathRiseEnd = min( CathRef_I( CathRef_I > Index_CathRiseStart ) );

% Classify pulse region using the inedx
% -----------------------------------------------------------------------------------------------------------------
Region_PreAnod = SampleData( 1 : Index_AnodRiseEnd );

%Region_Anod = SampleData( Index_AnodRiseEnd : Index_AnodFallStart );

Region_PreCath = SampleData( 1 : Index_CathRiseStart );

Region_Baseline = SampleData( 1 : Index_CathRiseStart );

%Region_Cath = SampleData( Index_CathRiseEnd : Index_CathFallStart );

%Region_PostCath = SampleData( Index_CathFallEnd : end );

% Find Anod Upr/Lwr Cross Level
% -----------------------------------------------------------------------------------------------------------------
Level_AnodUprCross = GndRef + 0.9 * ( aveAnod - GndRef );
Level_AnodLwrCross = GndRef + 0.1 * ( aveAnod - GndRef );

% Find Cath Upr/Lwr Cross Level
% -----------------------------------------------------------------------------------------------------------------
Level_CathUprCross = GndRef + 0.1 * ( aveCath - GndRef );
Level_CathLwrCross = GndRef + 0.9 * ( aveCath - GndRef );

% Find Anod Rise Time
% -----------------------------------------------------------------------------------------------------------------
Region_AnodRise = SampleData( (Index_AnodRiseStart + 1) : (Index_AnodRiseEnd - 1) );

[ ~ , temp2 ] = min( abs( Region_AnodRise - Level_AnodLwrCross ) );

Index_AnodRise_LwrCrossPoint = Index_AnodRiseStart + temp2;

[ ~ , temp2 ] = min( abs( Region_AnodRise - Level_AnodUprCross ) );

Index_AnodRise_UprCrossPoint = Index_AnodRiseStart + temp2;

AnodRiseTime = abs( Index_AnodRise_LwrCrossPoint - Index_AnodRise_UprCrossPoint ) * SAMPLE_INTERVAL;

% Find Anod Fall Time
% -----------------------------------------------------------------------------------------------------------------
ANOD_FALL_TIME_POINT_LIMIT = 5;

if abs( Index_AnodFallEnd - Index_AnodFallStart ) > ANOD_FALL_TIME_POINT_LIMIT

    Region_AnodFall = SampleData( (Index_AnodFallStart + 1) : ( Index_AnodFallEnd - 1) );

    [ ~ , temp2 ] = min( abs( Region_AnodFall - Level_AnodLwrCross ) );

    Index_AnodFall_LwrCrossPoint = Index_AnodFallStart + temp2;

    [ ~ , temp2 ] = min( abs( Region_AnodFall - Level_AnodUprCross ) );

    Index_AnodFall_UprCrossPoint = Index_AnodFallStart + temp2;

    AnodFallTime = abs( Index_AnodFall_LwrCrossPoint - Index_AnodFall_UprCrossPoint ) * SAMPLE_INTERVAL;

else
   
    AnodFallTime = SAMPLE_INTERVAL * ( ANOD_FALL_TIME_POINT_LIMIT - 1 );
    
end

% Find Cath Rise Time
% -----------------------------------------------------------------------------------------------------------------
Region_CathRise = SampleData( (Index_CathRiseStart + 1) : ( Index_CathRiseEnd - 1) );

[ ~ , temp2 ] = min( abs( Region_CathRise - Level_CathLwrCross ) );

Index_CathRise_LwrCrossPoint = Index_CathRiseStart + temp2;

[ ~ , temp2 ] = min( abs( Region_CathRise - Level_CathUprCross ) );

Index_CathRise_UprCrossPoint = Index_CathRiseStart + temp2;

CathRiseTime = abs( Index_CathRise_LwrCrossPoint - Index_CathRise_UprCrossPoint ) * SAMPLE_INTERVAL;

% Find Cath Fall Time
% -----------------------------------------------------------------------------------------------------------------
CATH_FALL_TIME_POINT_LIMIT = 5;

if abs( Index_CathFallEnd - Index_CathFallStart ) > CATH_FALL_TIME_POINT_LIMIT
    
    Region_CathFall = SampleData( (Index_CathFallStart + 1) : (Index_CathFallEnd - 1) );

    [ ~ , temp2 ] = min( abs( Region_CathFall - Level_CathLwrCross ) );

    Index_CathFall_LwrCrossPoint = Index_CathFallStart + temp2;

    [ ~ , temp2 ] = min( abs( Region_CathFall - Level_CathUprCross ) );

    Index_CathFall_UprCrossPoint = Index_CathFallStart + temp2;

    CathFallTime = abs( Index_CathFall_LwrCrossPoint - Index_CathFall_UprCrossPoint ) * SAMPLE_INTERVAL;

else
    
    CathFallTime = SAMPLE_INTERVAL * ( CATH_FALL_TIME_POINT_LIMIT - 1 ) ;
    
end

% Calculate Anod/Cath Pulse Q
% -----------------------------------------------------------------------------------------------------------------
AnodPulseQ = sum( SampleData( Index_AnodRiseStart : Index_AnodFallEnd ) ./ RESIS * SAMPLE_INTERVAL );
CathPulseQ = sum( SampleData( Index_CathRiseStart : Index_CathFallEnd ) ./ RESIS * SAMPLE_INTERVAL );

% Find AnodGlitchPeak / CathGlitchPeak
% -----------------------------------------------------------------------------------------------------------------
% AnodGlitchPeak = max( Region_PreAnod );
AnodGlitchPeak = max(SampleData(Index_CathFallEnd : Index_AnodRiseStart));
% CathGlitchPeak = min( Region_InterPulse );
CathGlitchPeak = min(SampleData(1 : Index_CathRiseStart));

% Calculate Anod/Cath Glitch Q
% -----------------------------------------------------------------------------------------------------------------
if AnodGlitchPeak > ( GndRef + 5 * std( Region_Baseline ) )
    
    % Find index - Anod Glitch Peak
    Index_AnodGlitchPeak = find( ( Region_PreAnod == AnodGlitchPeak ) , 1 );
    
    if SampleData(Index_CathFallStart : Index_AnodRiseEnd) == 0   
        Index_AnodGlitchStart = max( GndRef_I( GndRef_I < Index_AnodGlitchPeak ) );
        %Index_AnodGlitchEnd = min( GndRef_I( GndRef_I > Index_AnodGlitchPeak ) );
    else
        % Find index - Anod Glitch Region
        center_Zero_Region = Index_CathFallStart : Index_AnodRiseEnd;
        center_Zero_Region_sorted = sort(SampleData(center_Zero_Region));
        First_larger_then_zero = center_Zero_Region_sorted(find(center_Zero_Region_sorted > 0,1,'first'));
        Index_AnodGlitchStart = find(SampleData(center_Zero_Region) == First_larger_then_zero,1,'last')+Index_CathFallStart;
        %Index_AnodGlitchStart = max( GndRef_I( GndRef_I < Index_AnodGlitchPeak ) );
        %Anodic_dotdot = find(SampleData == Hist_SampleData( find(Hist_SampleData < aveAnod,1,'last')));
        %Index_AnodGlitchEnd = Anodic_dotdot(find(Anodic_dotdot > Index_AnodGlitchPeak,1,'first'));
    end
    
    if SampleData(Index_AnodRiseEnd : Index_AnodFallStart) == 0 
        Index_AnodGlitchEnd = min( GndRef_I( GndRef_I > Index_AnodGlitchPeak ) );
    else
        Anodic_dotdot = find(SampleData == Hist_SampleData( find(Hist_SampleData < aveAnod,1,'last')));
        Index_AnodGlitchEnd = Anodic_dotdot(find(Anodic_dotdot > Index_AnodGlitchPeak,1,'first'));
    end
    % Define Anod Glitch Region
    Region_AnodGlitch = SampleData( (Index_AnodGlitchStart + 1) : (Index_AnodGlitchEnd - 1) );
    
    % Calculate Anod Glitch Q
    AnodGlitchQ = sum( Region_AnodGlitch ./ RESIS * SAMPLE_INTERVAL );
    
else
    
    AnodGlitchPeak = 0;
    Index_AnodGlitchStart = 0;
    Index_AnodGlitchEnd = 0;
    Index_AnodGlitchPeak = 0;
    AnodGlitchQ = 0;
    
end

stdRange = 5 * std( Region_Baseline );
if CathGlitchPeak < ( GndRef - stdRange )
    
    % Find index - Cath Glitch Peak
    Index_CathGlitchPeak = find( ( Region_PreCath == CathGlitchPeak ) , 1 );
    
    %if SampleData(Index_CathRiseStart : Index_CathRiseEnd) == 0
        Index_CathGlitchStart = max( GndRef_I( GndRef_I < Index_CathGlitchPeak ) );
        %Index_CathGlitchEnd = min( GndRef_I( GndRef_I > Index_CathGlitchPeak ) );
    %else
        % Find index - Cath Glitch Region
        %Index_CathGlitchStart = max( GndRef_I( GndRef_I < Index_CathGlitchPeak ) );
        %Cathdoic_dotdot = find(SampleData == Hist_SampleData( find(Hist_SampleData > aveCath,1,'first')));
        %Index_CathGlitchEnd = Cathdoic_dotdot(find(Cathdoic_dotdot > Index_CathGlitchPeak,1,'first'));
    %end
    
    if SampleData(Index_CathRiseStart : Index_CathRiseEnd) == 0
        Index_CathGlitchEnd = min( GndRef_I( GndRef_I > Index_CathGlitchPeak ) );
    else
        Cathdoic_dotdot = find(SampleData == Hist_SampleData( find(Hist_SampleData > aveCath,1,'first')));
        Index_CathGlitchEnd = Cathdoic_dotdot(find(Cathdoic_dotdot > Index_CathGlitchPeak,1,'first'));
    end

    % Define Cath Glitch Region
    Region_CathGlitch = SampleData( (Index_CathGlitchStart + 1) : (Index_CathGlitchEnd - 1) );

    % Calculate Cath Glitch Q
    CathGlitchQ = sum( Region_CathGlitch ./RESIS * SAMPLE_INTERVAL );
  
else
    
    CathGlitchPeak = 0;
    Index_CathGlitchStart = 0;
    Index_CathGlitchEnd = 0;
    Index_CathGlitchPeak = 0;
    CathGlitchQ = 0;
    
end

% debug plot
%{
figure
    temp_y = [ -8 8 ];

    plot( SampleData );
    grid on;
    grid minor;
    title( 'Classify Pulse Region' );
    ylabel( 'Pulse Amp (Volt)' );
    xlabel( 'No. of Sample Point' );
    
    temp = line( [ Index_AnodRiseStart Index_AnodRiseStart ] , temp_y  );
    temp.Color = 'r';

    temp = line( [ Index_AnodRiseEnd Index_AnodRiseEnd ] , temp_y  );
    temp.Color = 'r';

    temp = line( [ Index_AnodFallStart Index_AnodFallStart ] , temp_y  );
    temp.Color = 'r';

    temp = line( [ Index_AnodFallEnd Index_AnodFallEnd ] , temp_y  );
    temp.Color = 'r';

    temp = line( [ Index_CathRiseStart Index_CathRiseStart ] , temp_y  );
    temp.Color = 'r';

    temp = line( [ Index_CathRiseEnd Index_CathRiseEnd ] , temp_y  );
    temp.Color = 'r';

    temp = line( [ Index_CathFallStart Index_CathFallStart ] , temp_y  );
    temp.Color = 'r';

    temp = line( [ Index_CathFallEnd Index_CathFallEnd ] , temp_y  );
    temp.Color = 'r';

    temp = line( [ Index_AnodGlitchStart Index_AnodGlitchStart ] , temp_y  );
    temp.Color = 'm';

    temp = line( [ Index_AnodGlitchEnd Index_AnodGlitchEnd ] , temp_y  );
    temp.Color = 'm';

    temp = line( [ Index_CathGlitchStart Index_CathGlitchStart ] , temp_y  );
    temp.Color = 'm';

    temp = line( [ Index_CathGlitchEnd Index_CathGlitchEnd ] , temp_y  );
    temp.Color = 'm';
%}

end % end of function