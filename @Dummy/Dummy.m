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
            switch lower(obj.name)
                case {'{methods}' '{properties}' '{constructor}'}
                    % search for comments and mark them up with color div
                    strDivStart = '<div class="comment">';
                    strDivEnd = '</div>';
                    for l = 1:length(fil) % l= line
                        if contains(fil(l), "%")
                            txtLine = char(fil(l));
                            idx = strfind(txtLine, "%");
                            % split string at first % and insert div tag
                            if idx(1) == 1
                                newTxt = [strDivStart, txtLine, strDivEnd];
                            else
                                newTxt = [txtLine(1:idx(1)-1), strDivStart, ...
                                    txtLine(idx(1):end), strDivEnd];
                            end
                            fil(l) = newTxt;
                        end
                    end
                    
                    
                case {'{description}' '{short_desc}' '{syntax}' ...
                        '{input}' '{output}' '{disclaimer}' '{references}'}
                    % Removes '%' at the beginning
                    fil = strrep(fil,"%","");
                otherwise
                    % Removes '%' at the beginning
                    fil = strrep(fil,"%","");
            end
            
            obj.filling = fil;
        end
    end
end