function RL_table = writeResilienceLossCsv( districts, csvPath, result, result_cmp )

gisIDs = arrayfun( @(x) x.GIS_ID, districts );
RL_table = table( gisIDs, result.RL_mean.Eg, result.RL_std.Eg, result.RL_mean.Cm, result.RL_std.Cm, result.RL_mean.Ca, result.RL_std.Ca, ...
    result.RL_mean.Ch, result.RL_std.Ch, result.RL_mean.Cm_nNode, result.RL_mean.Ca_nNode, result.RL_mean.Ch_nNode);
RL_table.Properties.VariableNames = {'FID', 'RL_Eg_m', 'RL_Eg_s', 'RL_Cm_m', 'RL_Cm_s', 'RL_Ca_m', 'RL_Ca_s', 'RL_Ch_m', 'RL_Ch_s', 'RL_Cm_n', 'RL_Ca_n', 'RL_Ch_n'};

if nargin > 3 % evaluate difference between base result
    RL_table.('RL_Eg_d') = (result.RL_mean.Eg - result_cmp.RL_mean.Eg) ./ result_cmp.RL_mean.Eg;
    RL_table.('RL_Cm_d') = (result.RL_mean.Cm - result_cmp.RL_mean.Cm) ./ result_cmp.RL_mean.Cm;
    RL_table.('RL_Ca_d') = (result.RL_mean.Ca - result_cmp.RL_mean.Ca) ./ result_cmp.RL_mean.Ca;
    RL_table.('RL_Ch_d') = (result.RL_mean.Ch - result_cmp.RL_mean.Ch) ./ result_cmp.RL_mean.Ch;
end

RL_table.('Node_den') = result.nodeDensityInDistricts;

if strcmp( csvPath(end-3:end), '.csv' )
    writetable( RL_table, csvPath )
else
    writetable( RL_table, strcat( csvPath, '.csv' ) )
end