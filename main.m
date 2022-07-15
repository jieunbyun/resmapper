clear;
rng(1)

%% Input (by users)
filename = 'istanbul_benchmark';
versionName = 'df'; % default setting
load( strcat( 'data/input/', filename, '.mat' ) )

% Parameters (can be modified according to local conditions)
closureRatioToRecoveryDays_overpass = 0.1; 
closureRatioToRecoveryDays_roadDamage = 0.5; 

averageBuildingLength_m = 15; 
clearResourceWeight = [1, 0.75, 0.25, 0.1]; 
clearResource_day = 2e2; 

nSample = 1000;

%% Mapping seismic resilience loss of a road network
run resMapper.m

%% Output
RL_table = networkAnalysis.writeResilienceLossCsv( districts, strcat('data/output/RL_', versionName), result );
% save( strcat( 'data/output/', filename, '_', versionName, '.mat' ) ) % Lead to very large data
