function districts = samplePgdInInch( districts, GMs, nSample )

% Constant parameters
n_fun = @(Mw) 0.3419 * Mw^3 - 5.5214 * Mw^2 + 33.6154 * Mw - 70.7692;
criticalAccelerationOfEachSoilType = [0.60 0.50 0.40 0.35 0.30 0.25 0.20 0.15 0.10 0.05];
nSoilTypes = length(criticalAccelerationOfEachSoilType);

displacementFactorUpperBounds = csvread( 'data/params/PGDcurve_upperBound.csv' );
displacementFactorLowerBounds = csvread( 'data/params/PGDcurve_lowerBound.csv' );

% Sampling
nDistrict = length( districts );
for iDistInd = 1:nDistrict

    iDist = districts(iDistInd);
    iPga = GMs( iDist.GM_ID ).PGA;
    iSoilProportions = iDist.soilProportion;
    iMw = GMs( iDist.GM_ID ).Mw;
    iN = n_fun( iMw );
    
    iPgd_inchSampleArray = zeros( 1, nSample );
    for sampleIndex_j = 1:nSample
        ijSoilType = randsample( nSoilTypes, 1, true, iSoilProportions );
        ijCriticalAcceleration = criticalAccelerationOfEachSoilType( ijSoilType );

        ijAccelerationRatio = ijCriticalAcceleration / iPga;
        if ijAccelerationRatio > 1
            ijPgdInInch = 0;
        else
            
            ijLogDisplacementFactorUpperBound = interp1( displacementFactorUpperBounds(:,1), log( displacementFactorUpperBounds(:,2) ),  ijAccelerationRatio, 'linear', 'extrap' );
            ijLogDisplacementFactorLowerBound = interp1( displacementFactorLowerBounds(:,1), log( displacementFactorLowerBounds(:,2) ),  ijAccelerationRatio, 'linear', 'extrap' );

            ijDisplacementFactorUpperBound = exp( ijLogDisplacementFactorUpperBound );
            ijDisplacementFactorLowerBound = exp( ijLogDisplacementFactorLowerBound );
            ijDisplacementFactorLowerBound = max( [ijDisplacementFactorLowerBound 0] );
            
            if ijDisplacementFactorUpperBound > 0
                ijRandForDisplacementFactor = rand( 1 );
                ijLogDisplacementFator = log( ijDisplacementFactorLowerBound ) + ijRandForDisplacementFactor * ( log( ijDisplacementFactorUpperBound ) - log( ijDisplacementFactorLowerBound ) );
                ijDisplacementFator = exp( ijLogDisplacementFator );
            else
                ijDisplacementFator = 0;
            end

            ijPgdInInch = ijDisplacementFator * iPga * iN;

        end
        
        iPgd_inchSampleArray( sampleIndex_j ) = ijPgdInInch;
    end
    
    districts(iDistInd).pgd = iPgd_inchSampleArray(:).';
end