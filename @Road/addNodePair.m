function roads = addNodePair( roads, nodes, roadNodeJoin_array )

% Get pointer from Node GIS ID to array ID (for computation efficiency)
nodeGisIds = arrayfun( @(x) x.GIS_ID, nodes );
nodeGisId_min = min(nodeGisIds);
nodeGisId_max = max(nodeGisIds);
nodeId_gis2array = zeros( (nodeGisId_max-nodeGisId_min)+1, 1 ); % GIS IDs can start from 0.

nNode = length(nodes);
for iNodeArrayId = 1:nNode
    iNodeGisId = nodes(iNodeArrayId).GIS_ID;
    nodeId_gis2array( iNodeGisId-nodeGisId_min+1 ) = iNodeArrayId;
end

% Match each road to a node pair
nRoad = length( roads );
for iRoadIndex = 1:nRoad

    iRoad = roads( iRoadIndex );
    iRoad_gisId = iRoad.GIS_ID;

    iNode_gisId = roadNodeJoin_array( roadNodeJoin_array( :, 1 ) == iRoad_gisId, 2 );
    iNodeArrayIds = nodeId_gis2array( iNode_gisId-nodeGisId_min+1 );
    if length( iNodeArrayIds ) ~= 2
        error( 'A road must have exactly two end nodes.' )
    else
        roads(iRoadIndex).nodePair = iNodeArrayIds(:).';
    end

end