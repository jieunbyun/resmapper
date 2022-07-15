function roads = sampleRoadDamage( roads, districts, GMs, roadFragilityMean, roadFragilityStd )

import function.*

nRoad = size( roads, 1 );
nSample = size( roads(1).damageStates, 2 );

for iRoadInd = 1:nRoad
    iRoad = roads(iRoadInd);
    iDist = iRoad.district;
    if iDist < 0 % No matching district
        iDist = randsample( length(districts), 1 );
    end

    if ~iRoad.isBridge
        iImArray = districts(iDist).pgd;
        iLength_km = iRoad.length * 1e-3; 
        iDamageStateSampleArray = sampleDamageStateArray( iImArray, roadFragilityMean{ iRoad.structType }, roadFragilityStd{ iRoad.structType }, iLength_km );

    else
        iSa1 = GMs( districts( iDist ).GM_ID ).Sa1;
        iImArray = iSa1 * ones( 1, nSample );
        iDamageStateSampleArray = sampleDamageStateArray( iImArray, roadFragilityMean{ iRoad.structType }, roadFragilityStd{ iRoad.structType } );
    end
   
    roads( iRoadInd ).damageStates = iDamageStateSampleArray;

    if isempty( roads( iRoadInd ).damageStates )
        ddd = 1;
    end

    if ~rem(iRoadInd, 1e3)
        disp(['Road ' num2str(iRoadInd) ' done. (total: ' num2str(nRoad) ')'])
    end
end
end

% % 
function DamageStateSampleArray = sampleDamageStateArray( imArray, roadFragilityCurveMean, roadFragilityCurveStd, length_km )

if length( roadFragilityCurveMean ) ~= length( roadFragilityCurveStd )
    error( 'The vector of fagility curve mean must have the same length with fragility curve std (i.e. number of damage states)' )
end

nSample = length( imArray(:) );
DamageStateSampleArray = zeros( size( imArray ) );
for iSampleIndex = 1:nSample
    
    iPgd = imArray( iSampleIndex );
    
    if nargin < 4
        iDamageState = sampleDamageState( iPgd, roadFragilityCurveMean, roadFragilityCurveStd );
    else
        iDamageState = sampleDamageState( iPgd, roadFragilityCurveMean, roadFragilityCurveStd, length_km );
    end
            
    DamageStateSampleArray( iSampleIndex ) = iDamageState;
    
end
end

% % 
function [damageState, sampleProb] = sampleDamageState( im, meanArray, logStdArray, length_km )

    damageProbs_normal = normcdf( log( im ), log( meanArray ), logStdArray );
    damageProbs_normal = damageProbs_normal(:)';
    damageProbs_normal = diff( fliplr( [1 damageProbs_normal 0] ) );
    damageProbs_normal = fliplr( damageProbs_normal );

    if nargin < 4
        damageProbs = damageProbs_normal;

    else
        damageProbs = evalDamageProbsWithLengths( damageProbs_normal, length_km );
    end

    damageState = randsample( length( damageProbs ), 1, true, damageProbs );
    sampleProb = damageProbs( damageState );

end

% % 
function damageProbs = evalDamageProbsWithLengths( damageProbs_normal, length_km )

    nDamageState = length( damageProbs_normal );
    damageProbs = zeros( 1, nDamageState );
    iDamageProbOld = 1;
    for iDamageStateIndex = nDamageState:-1:2
        iDamageProbNew = sum( damageProbs_normal( 1:(iDamageStateIndex-1) ) )^length_km;
        damageProbs( iDamageStateIndex ) = iDamageProbOld - iDamageProbNew;

        iDamageProbOld = iDamageProbNew;
    end
    damageProbs( 1 ) = iDamageProbNew;

end