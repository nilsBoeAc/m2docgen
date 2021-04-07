classdef Dummy < handle
% text dummys that contain important information 
%% Description:
%   Objects of this class are used to store information about a m-file.
%   While parsing an m-file in the function MFile.parse
%   
%% Syntax:
%   dm = dummy(name, filling);
%
%% Input:
% required input values;
%   name - Heading of the dummy: "string"
%       This is the heading where the dummy should be placed within the
%       template, for example a dm.name = "DESCRIPTION" will be placed
%       under the description heading of the HTML template.
%   filling - text content: "string"
%       This is the content that should appear in the html document. Make
%       sure to not use newline characters in the string, but to use a
%       vertical string.
%
%% Properties:
%   name    - see inputs
%   filling - see inputs
%   type    - classification of the dummy: string
%   refPath - reference path that should be placed into a placeholder that
%             is currently within the filling (content) of the dummy. see
%             generation of function reference list.
%
%% Disclaimer:
%
% Last editor:  Pierre Ollfisch
% Last edit on: 07.04.2021
% Code version: 1.0
% Copyright (c) 2021
    
    %% Properties
    properties
        name    string;
        filling string;
        type    string;
        refPath string = "NA";
    end
    
    %% methods
    methods
        %% Dummy Constructor
        function obj = Dummy(name,filling)
            obj.name = name;
            obj.filling = filling;
        end
        
        %% additional functions
        function set.type(obj,ty)
            obj.type = ty;
        end
        
        function set.name(obj,name)
            % autotype braces around input string if missing
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
            % autocorrect .html if extension is missing from input string
            if(~contains(rp,".html"))
                rp = rp+".html";
            end
            obj.refPath = rp;
        end
        
        function set.filling(obj,fil)
            switch lower(obj.name)
                case {'{methods}' '{properties}' '{constructor}'}
%                     % search for comments and mark them up with color div
%                     strDivStart = '<div class="comment">';
%                     strDivEnd = '</div>';
%                     for l = 1:length(fil) % l= line
%                         if contains(fil(l), "%")
%                             txtLine = char(fil(l));
%                             idx = strfind(txtLine, "%");
%                             % split string at first % and insert div tag
%                             if idx(1) == 1
%                                 newTxt = [strDivStart, txtLine, strDivEnd];
%                             else
%                                 newTxt = [txtLine(1:idx(1)-1), strDivStart, ...
%                                     txtLine(idx(1):end), strDivEnd];
%                             end
%                             fil(l) = newTxt;
%                         end
%                     end
                    % fil = fil; % leave comments in
                case {'{description}' '{short_desc}' '{syntax}' ...
                        '{input}' '{output}' '{disclaimer}' '{references}'}
                    % Removes '%' in the entire text
                    fil = strrep(fil,"%","");
                otherwise
                    % Removes '%' in the entire text
                    fil = strrep(fil,"%","");
            end
            
            obj.filling = fil;
        end
    end
end