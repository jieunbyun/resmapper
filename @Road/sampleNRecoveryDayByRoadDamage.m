function roads = sampleNRecoveryDayByRoadDamage( roads, roadRecoveryMean, roadRecoveryStd )

import function.*

nRoad = length( roads ); 

for iRoadInd = 1:nRoad
    iStructType = roads(iRoadInd).structType;
    iDamageStateArray = roads(iRoadInd).damageStates;
    
    iNRecoveryDayArray = sampleRoadRecovery( roadRecoveryMean{ iStructType }, roadRecoveryStd{ iStructType }, iDamageStateArray );
    roads(iRoadInd).recoveryDays = iNRecoveryDayArray(:).';
end

end

% % 
function nRecoveryDayArray = sampleRoadRecovery( nRecoveryDayMeanArray, nRecoveryDayStdArray, damageStateArray )

if length( nRecoveryDayMeanArray ) ~= length( nRecoveryDayStdArray )
    error( 'The vector of recovery days mean must have the same length with that of std (i.e. the number of damage states - 1).' )
end

nSample = length( damageStateArray(:) );

nRecoveryDayArray = zeros( size( damageStateArray ) );
for iSampleIndex = 1:nSample
    iDamageState = damageStateArray( iSampleIndex );
    iDamageState = iDamageState - 1;
    
    if ~iDamageState
        iNRecoveryDay = 0;
    else
        iMean = nRecoveryDayMeanArray( iDamageState );
        iStd = nRecoveryDayStdArray( iDamageState );
        
        iNRecoveryDay = normrnd( iMean, iStd );
        iNRecoveryDay = ceil( iNRecoveryDay );
        iNRecoveryDay = max( [0, iNRecoveryDay] );
    end
    
    nRecoveryDayArray( iSampleIndex ) = iNRecoveryDay;
        
end
end