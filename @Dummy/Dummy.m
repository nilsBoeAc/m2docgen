classdef Dummy < handle
    % Dummy used in TemplateHTML
    
    %% Properties
    properties
        name string;
        filling string;
        type string;
        refPath string ="NA";
    end
    
    %% methods
    methods
        function obj = Dummy(name,filling)
            %Dummy Constructor
            obj.name = name;
            obj.filling = filling;
        end
        
        function set.type(obj,ty)
            obj.type = ty;
        end
        
        function set.name(obj,name)
            name = upper(name);
            tmp = char(name);
            if(~contains(tmp,'{'))
                %disp("In Dummy: [Name] does not contain '{'. Will be added!");
                name = "{"+name;
            end
            if(~contains(tmp,'}'))
                %disp("In Dummy: [Name] does not contain '}'. Will be added!");
                name = name+"}";
            end
            obj.name = name;
        end
        
        function set.refPath(obj,rp)
            if(~contains(rp,".html"))
                rp = rp+".html";
            end
            obj.refPath = rp;
        end
        
        function set.filling(obj,fil)
            % Removes '%' at the beginning
            fil = strrep(fil,"%","");
            obj.filling = fil;
        end
    end
end