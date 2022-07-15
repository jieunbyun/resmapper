function roads = evalNClosureDaysByBuilding( roads, districts, averageBuildingLength_m, clearResourceWeight, clearResource_day, roadsClearPriority )

nRoad = length(roads);
nSample = length(roads(1).damageStates);
nDamageState = length(districts(1).nDamagedBuildings) + 1; % damage states plus none-damage state

requiredCleanResourceArray = zeros( nRoad, nSample );
for iRoadInd = 1:nRoad
    iRoad = roads(iRoadInd);

    iDistId = iRoad.district;
    if iDistId < 0
        iDistId = randsample( length(districts), 1 );
    end

    iDist = districts(iDistId);
    iProb_per_buildingLength = iDist.nDamagedBuildings / iDist.area * 2 * averageBuildingLength_m;
    iProb_non_damage = max([0, 1-sum(iProb_per_buildingLength)]);

    iMeanNBuilding = round( iRoad.length / averageBuildingLength_m );

    iNDamageBuildingArray = zeros(nSample, nDamageState);
    for jSampleInd = 1:nSample
        ijBuildingDamageSample = randsample( nDamageState, iMeanNBuilding, true, [iProb_per_buildingLength iProb_non_damage] );
        
        ijNDamageBuilding = zeros(1,nDamageState);
        for kDamageState = 1:nDamageState
            ijNDamageBuilding(kDamageState) = sum(ijBuildingDamageSample == kDamageState);
        end
        iNDamageBuildingArray(jSampleInd,:) = reshape(ijNDamageBuilding, [1, 1, nDamageState]);
    end

    iRequiredCleanResourceArray = iNDamageBuildingArray .* repmat([clearResourceWeight(:).' 0], nSample, 1);
    iRequiredCleanResourceArray = sum(iRequiredCleanResourceArray, 2);
    requiredCleanResourceArray(iRoadInd, :) = iRequiredCleanResourceArray;

    if ~rem(iRoadInd, 1e3)
        disp(['[Sampling building damage] Road ' num2str(iRoadInd) ' done. (total: ' num2str(nRoad) ')'])
    end

end

disp( '[Sampling building damage] Completed.' )

roadNClosureDayByBuildingSamples = requiredCleanResourceArray / clearResource_day;
nClosureDayByBuildingArray = evalNClosureDayByBuilding( roadNClosureDayByBuildingSamples, roadsClearPriority );

for iRoadInd = 1:nRoad
    roads(iRoadInd).closureDays_building = nClosureDayByBuildingArray(iRoadInd,:);
end

end


function nClosureDayByBuildingArray = evalNClosureDayByBuilding( roadNClosureDayByBuildingSamples, roadsClearPriority )

[~,clearPrioritySortIndex] = sort( roadsClearPriority );

nClosureDayByBuildingArray = zeros( size( roadNClosureDayByBuildingSamples ) );
for iSampleIndex = 1:size( roadNClosureDayByBuildingSamples, 2 )
    iSample = roadNClosureDayByBuildingSamples( :, iSampleIndex );
    iSampleSortedByPriority = iSample( roadsClearPriority );
    iSampleSortedByPriorityCumsum = cumsum( iSampleSortedByPriority );
    iSampleSortedByPriorityCumsumCeil = ceil( iSampleSortedByPriorityCumsum );
    
    iNDays = iSampleSortedByPriorityCumsumCeil( clearPrioritySortIndex );
    nClosureDayByBuildingArray( :, iSampleIndex ) = iNDays;
end
end