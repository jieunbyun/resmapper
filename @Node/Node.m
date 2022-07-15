classdef Node

    properties
        GIS_ID;
        type;
        clearPriority;
    end

    methods

        function node = Node(GIS_ID, type, clearPriority)
            if nargin > 0
                node.GIS_ID = GIS_ID;

                if nargin > 1
                    node.type = type;

                    if nargin > 2
                        if (clearPriority < 0) || (clearPriority > 1)
                            error( 'clearPriority must be either 1 (yes) or 0 (no).' )
                        else
                            node.clearPriority = clearPriority;
                        end
                    end
                end
            end
        end

    end

end