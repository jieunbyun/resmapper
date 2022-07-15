function [resilienceLossSampleArray, resilienceLossMean, resilienceLossStd] = evalResilienceLossSamples( networkFunctionalitySampleCellArray, sampleTimeArray )

nDistrict= size( networkFunctionalitySampleCellArray, 1 );
nSample = size(networkFunctionalitySampleCellArray, 2);

resilienceLossSampleArray = zeros( nDistrict, nSample );
for iSampleIndex = 1:nSample
    iTimes = sampleTimeArray{ iSampleIndex };

    for jDistrictIndex= 1:nDistrict
        ijResilienceLossArray = 1 - networkFunctionalitySampleCellArray{ jDistrictIndex, iSampleIndex }(:);
        ijResilienceLossSum = sum( diff( iTimes(:) ) .* ijResilienceLossArray(1:(end-1)) );
        
        resilienceLossSampleArray( jDistrictIndex, iSampleIndex ) = ijResilienceLossSum;
    end
end

resilienceLossMean = mean( resilienceLossSampleArray, 2 );
resilienceLossStd = std( resilienceLossSampleArray, [], 2 );