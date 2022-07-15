function [ConnectivitySampleCellArray, sampleTimeArray] = evalSamplesConnectivity( roads, districts, nodes, destinationNodeTypeIndex )

if ~isscalar( destinationNodeTypeIndex )
    error( 'Destination node type must be given as a scalar' )
end

nDistrict = length( districts );
nSample = length( roads(1).damageStates );

nClosureDayArray = arrayfun( @(x) x.closureDays(:).', roads(:), 'UniformOutput', false );
nClosureDayArray = cell2mat(nClosureDayArray);

nodePairIdArray = arrayfun( @(x) x.nodePair(:).', roads(:), 'UniformOutput', false );
nodePairIdArray = cell2mat(nodePairIdArray);

destinationNodeIds = find( arrayfun( @(x) ismember( destinationNodeTypeIndex, x.type ), nodes ) );

ConnectivitySampleCellArray = cell( nDistrict, nSample );
sampleTimeArray = cell( nSample, 1 );
for iSampleIndex = 1:nSample
    iNClosureDays = nClosureDayArray( :, iSampleIndex );
    iChangeTimes = unique( iNClosureDays );
    if iChangeTimes(1) ~= 0; iChangeTimes = [0; iChangeTimes]; end
    sampleTimeArray{ iSampleIndex } = iChangeTimes;
    
    iNTimes = length( iChangeTimes );
    for ijTimeIndex = 1:iNTimes
        if ijTimeIndex < iNTimes
            ijTime = iChangeTimes( ijTimeIndex );

            ijNodePairArray = nodePairIdArray( iNClosureDays <= ijTime, : );
            ijGraph = graph( ijNodePairArray(:,1), ijNodePairArray(:,2) );

            ijNodeId2BinId = conncomp(ijGraph);
            
            if isempty( ijNodeId2BinId )
                ijNodeId2BinId = 1:max( destinationNodeIds );
                
            elseif any( destinationNodeIds > length( ijNodeId2BinId ) )
                ijMaxBinId = max( ijNodeId2BinId );
                ijNNodeSurplus = max(destinationNodeIds) - length( ijNodeId2BinId );
                ijNodeId2BinId = [ijNodeId2BinId ijMaxBinId+(1:ijNNodeSurplus)];
            end
            ijDestinationBins = ijNodeId2BinId( destinationNodeIds );
            

            for kDistrictId = 1:nDistrict
                kNodeIds = districts(kDistrictId).nodes_ID;
                ijkConnectedRatio = evalConnectedRatio( ijNodeId2BinId, kNodeIds, ijDestinationBins );

                ConnectivitySampleCellArray{ kDistrictId, iSampleIndex}(ijTimeIndex) = ijkConnectedRatio;
            end
        else
            for kDistrictId = 1:nDistrict
                ConnectivitySampleCellArray{ kDistrictId, iSampleIndex}(ijTimeIndex) = 1; % by definition, fully recovered in the end
            end
        end
    end

    if ~rem(iSampleIndex, 50)
        disp(['Sample ' num2str(iSampleIndex) ' done. (total: ' num2str(nSample) ')'])
    end
    
end
end


function connectedRatio = evalConnectedRatio( nodeId2binId, nodeIds, destinationBins )

if max( nodeIds ) > length( nodeId2binId )
    maxBinId = max( nodeId2binId );
    nNodeSurplus = max( nodeIds ) - length( nodeId2binId );
    nodeId2binId = [nodeId2binId maxBinId+(1:nNodeSurplus)];
end

nConnectedNodeIds = sum( ismember( nodeId2binId( nodeIds ), destinationBins ) );
connectedRatio = nConnectedNodeIds / length( nodeIds );
end