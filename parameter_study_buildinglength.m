clear;
rng(1)


load( 'data/output/istanbul_benchmark_df.mat' )
baseResult = result;
filename = 'istanbul_benchmark';

buildingLengths = [20 25];

for iParamTest = 1:length( buildingLengths )
    disp( ['Test ' num2str(iParamTest), '(/', num2str(length( buildingLengths )), ')'] )
    versionName = strcat('bl', num2str(iParamTest)); % clearance resource of building debris

    iBuildingLength = buildingLengths(iParamTest); 
    roads = evalNClosureDaysByBuilding( roads, districts, iBuildingLength, clearResourceWeight, clearResource_day, roadsClearPriority );
    
    roads = evalMaxClosureDays( roads );
    
    % Network analysis
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
    
    % Result
    RL_table = networkAnalysis.writeResilienceLossCsv( districts, strcat('data/output/RL_', versionName), result, baseResult );
    save( strcat( 'data/output/', filename, '_', versionName, '.mat' ) )
end