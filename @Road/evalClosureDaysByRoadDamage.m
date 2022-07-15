function roads = evalClosureDaysByRoadDamage( roads, closureRatioToRecoveryDays_roadDamage )

for ii = 1:length(roads)
    roads(ii).closureDays_damage = ceil( roads(ii).recoveryDays * closureRatioToRecoveryDays_roadDamage );
end