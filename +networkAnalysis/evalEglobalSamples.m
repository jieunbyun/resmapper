function [EglobalSampleCellArray, sampleTimeArray] = evalEglobalSamples( roads, districts )

nDistrict = length( districts );
nSample = length( roads(1).damageStates );

nClosureDayArray = arrayfun( @(x) x.closureDays(:).', roads(:), 'UniformOutput', false );
for i = 1:length(nClosureDayArray)
    if length(nClosureDayArray{i}) < 2
        nClosureDayArray{i} = zeros(1, nSample);
    end
end

nClosureDayArray = cell2mat(nClosureDayArray);


nodePairIdArray = arrayfun( @(x) x.nodePair(:).', roads(:), 'UniformOutput', false );
nodePairIdArray = cell2mat(nodePairIdArray);

EglobalSampleCellArray = cell( nDistrict, nSample );
sampleTimeArray = cell( nSample, 1 );

for iSampleInd = 1:nSample
    iNClosureDays = nClosureDayArray( :, iSampleInd );
    iChangeTimes = unique( iNClosureDays );

    if iChangeTimes(1) ~= 0; iChangeTimes = [0; iChangeTimes]; end
    sampleTimeArray{ iSampleInd } = iChangeTimes;
    
    iNTimes = length( iChangeTimes );
    for ijTimeIndex = 1:iNTimes
        if ijTimeIndex < iNTimes
            ijTime = iChangeTimes( ijTimeIndex );

            ijNodePairArray = nodePairIdArray( iNClosureDays <= ijTime, : );
            ijGraph = graph( ijNodePairArray(:,1), ijNodePairArray(:,2) );

            ijNodeId2BinId = conncomp(ijGraph);

            for kDistrictId = 1:nDistrict
                kNodeIds = districts(kDistrictId).nodes_ID;
                ijkEglobal = evalEglobal( ijNodeId2BinId, kNodeIds );

                EglobalSampleCellArray{ kDistrictId, iSampleInd}(ijTimeIndex) = ijkEglobal;
            end
        else
            for kDistrictId = 1:nDistrict
                EglobalSampleCellArray{ kDistrictId, iSampleInd}(ijTimeIndex) = 1; % by definition, fully recovered in the end
            end
        end
    end

    if ~rem(iSampleInd, 50)
        disp(['Sample ' num2str(iSampleInd) ' done. (total: ' num2str(nSample) ')'])
    end
    
end
end


function Eglobal = evalEglobal( nodeId2binId, nodeIds )

if isempty( nodeId2binId )
    nodeId2binId = 1:max( nodeIds );
elseif max( nodeIds ) > length( nodeId2binId )
    maxBinId = max( nodeId2binId );
    nNodeSurplus = max( nodeIds ) - length( nodeId2binId );
    nodeId2binId = [nodeId2binId maxBinId+(1:nNodeSurplus)];
end
    

nodeBins = nodeId2binId( nodeIds );

binIds = unique( nodeBins );
nBins = length( binIds );
nConnectedPair = 0;
for iBinIndex = 1:nBins
    iBinId = binIds( iBinIndex );
    iNNode = sum( nodeBins == iBinId );
    
    iNConnectedPair = iNNode*(iNNode-1)/2; 
    nConnectedPair = nConnectedPair + iNConnectedPair;
end

nNode = length( nodeIds );
nNodePair = nNode*(nNode-1)/2;
Eglobal = nConnectedPair / nNodePair;
end