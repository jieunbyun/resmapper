classdef District

    properties
        GIS_ID; % can be a vector
        area; % m2
        nDamagedBuildings; % can be a vector
        soilProportion; % Proportions of 10 landslide-susceptibility categories (ref. HAZUS-EQ model)
        GM_ID; % Corresponding Ground Motion area
        pgd; % inch
        nodes_ID; 
    end

    methods

        function district = District(GIS_ID, area, nDamagedBuildings, soilProportion, GM_ID, pgd, nodes_ID)
            if nargin > 0
                district.GIS_ID = GIS_ID;

                if nargin > 1
                    district.area = area;

                    if nargin > 2
                        district.nDamagedBuildings = nDamagedBuildings;

                        if nargin > 3
                            if length(soilProportion) ~= 10
                                error( 'Soil proportion must be given exactly for 10 landslide susceptibility categories.' )
                            else
                                district.soilProportion = soilProportion;
                            end

                            if nargin > 4
                                if ~isscalar(GM_ID)
                                    error( 'A district must correspond to exactly one ground motion area.' )
                                else
                                    district.GM_ID = GM_ID;
                                end

                                if nargin > 5
                                    district.pgd = pgd;

                                    if nargin > 6
                                        district.nodes_ID = nodes_ID;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

    end

end