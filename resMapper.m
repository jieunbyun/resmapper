% function resMapper()

%% Create objects from input data
nDistrict = size(district_table, 1);
districts = District;
districtNBuild.veryHeavy = 1; districtNBuild.heavy = 2; districtNBuild.moderate = 3; districtNBuild.slight = 4; 
for iDataInd = 1:nDistrict
    iData = district_table(iDataInd, :);
    iNBuild = [iData.nBuild_veryheavy iData.nBuild_heavy iData.nBuild_moderate iData.nBuild_slight];
    districts(iDataInd, 1) = District( iData.gis_id, iData.area_m2, iNBuild, soilTypeProportions );
end

nGM = size(GM_table, 1);
GMs = GM;
for iDataInd = 1:nGM
    iData = GM_table(iDataInd, :);
    GMs(iDataInd, 1) = GM( iData.gis_id, iData.Mw, iData.pga_g, iData.s1_g );
end

nRoad = size(road_table, 1);
roads = Road;
for iDataInd = 1:nRoad
    iData = road_table(iDataInd, :);
    roads(iDataInd, 1) = Road( iData.gis_id, iData.isBridge, iData.isMajor, iData.length_m, iData.structType );
end

nNode = size(node_table, 1);
nodeType.motorway = 1; nodeType.aerodome = 2; nodeType.hospital = 3;
for iDataInd = 1:nNode
    iData = node_table(iDataInd, :);

    iNodeType = [];
    if iData.motorway; iNodeType = [iNodeType nodeType.motorway]; end
    if iData.aerodome; iNodeType = [iNodeType nodeType.aerodome]; end
    if iData.hospital; iNodeType = [iNodeType nodeType.hospital]; end

    iClearPriority = iData.motorway;

    nodes(iDataInd, 1) = Node( iData.gis_id, iNodeType, iClearPriority );
end

% Connect objects
districts = addGMId(districts, GMs, table2array(districtGmJoin_table) );
districts = addNodes( districts, nodes, table2array(nodeDistrictJoin_table) );

roads = addNodePair( roads, nodes, table2array(roadNodeJoin_table) );
roads = addDistrict( roads, districts, table2array(roadDistrictJoin_table) );
roads = addOverpasses( roads, table2array(overpassJoin_table) );

%% Evaluate road closure
districts = samplePgdInInch( districts, GMs, nSample );

roads = sampleRoadDamage( roads, districts, GMs, roadFragilityMean, roadFragilityStd );
roads = sampleNRecoveryDayByRoadDamage( roads, roadRecoveryMean, roadRecoveryStd );

roads = evalClosureDaysByRoadDamage( roads, closureRatioToRecoveryDays_roadDamage );

roads = evalNClosureDaysByOverpass( roads, closureRatioToRecoveryDays_overpass );

roadsClearPriority = evalRoadsClearPriority( roads, nodes );
roads = evalNClosureDaysByBuilding( roads, districts, averageBuildingLength_m, clearResourceWeight, clearResource_day, roadsClearPriority );

roads = evalMaxClosureDays( roads );

%% Network analysis
[Eglobals, Eglobals_time] = networkAnalysis.evalEglobalSamples( roads, districts );
[resilienceLoss_Eglobal, resilienceLossMean_Eglobal, resilienceLossStd_Eglobal] = networkAnalysis.evalResilienceLossSamples( Eglobals, Eglobals_time );

[Connectivity_motorway, Connectivity_time_motorway] = networkAnalysis.evalSamplesConnectivity( roads, districts, nodes, nodeType.motorway );
[resilienceLoss_conn_motorway, resilienceLossMean_conn_motorway, resilienceLossStd_conn_motorway] = networkAnalysis.evalResilienceLossSamples( Connectivity_motorway, Connectivity_time_motorway );

[Connectivity_aerodome, Connectivity_time_aerodome] = networkAnalysis.evalSamplesConnectivity( roads, districts, nodes, nodeType.aerodome );
[resilienceLoss_conn_aerodome, resilienceLossMean_conn_aerodome, resilienceLossStd_conn_aerodome] = networkAnalysis.evalResilienceLossSamples( Connectivity_aerodome, Connectivity_time_aerodome );

[Connectivity_hospital, Connectivity_time_hospital] = networkAnalysis.evalSamplesConnectivity( roads, districts, nodes, nodeType.hospital );
[resilienceLoss_conn_hospital, resilienceLossMean_conn_hospital, resilienceLossStd_conn_hospital] = networkAnalysis.evalResilienceLossSamples( Connectivity_hospital, Connectivity_time_hospital );

result.RL_mean.Eg = resilienceLossMean_Eglobal; 
result.RL_mean.Cm = resilienceLossMean_conn_motorway; 
result.RL_mean.Ca = resilienceLossMean_conn_aerodome; 
result.RL_mean.Ch = resilienceLossMean_conn_hospital; 

result.RL_std.Eg = resilienceLossStd_Eglobal; 
result.RL_std.Cm = resilienceLossStd_conn_motorway; 
result.RL_std.Ca = resilienceLossStd_conn_aerodome; 
result.RL_std.Ch = resilienceLossStd_conn_hospital; 

nDistrictNode = arrayfun(@(x) length(x.nodes_ID), districts);
nDistrictNodePair = nDistrictNode.*(nDistrictNode-1)/2;
result.RL_mean.Cm_nNode = resilienceLossMean_conn_motorway.*nDistrictNode; 
result.RL_mean.Ca_nNode = resilienceLossMean_conn_aerodome.*nDistrictNode; 
result.RL_mean.Ch_nNode = resilienceLossMean_conn_hospital.*nDistrictNode;  

result.nodeDensityInDistricts = nDistrictNode ./ arrayfun(@(x) x.area, districts);
result.nodeDensityInDistricts = result.nodeDensityInDistricts * 1e6; % /km^2