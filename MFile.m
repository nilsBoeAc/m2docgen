classdef MFile < handle
    % MFile
    
    %% Properties
    properties
        name string; % Name of File
        path string; % Full Path of File
        text string;  % text of File
        
        % 
        knownBlocks = ["DESCRIPTION","SYNTAX","INPUT","OUTPUT","REFERENCES","DISCLAIMER"];
        
        dummyList={}; %List with dummies
    end
    
    properties (Dependent)
        type string; % type of File{function,script,class} dep. on text
    end
    
    %% methods
    methods
        function obj = MFile(name,path)
            %MFile Constructor
            obj.name = name;
            obj.path = path;
            
            % open file and store text
            fil = fopen(obj.path+name);
            dat = textscan(fil,'%s','delimiter','\n');
            fclose(fil);
            
            % Reduced Text to header
            obj.text = string(dat{1});
        end
    end
    
    %% Get / Set Functions
    methods
        function set.path(obj,p)
            tmp = char(p);
            if(tmp(end)~="\")
                p = p+"\";
            end
            obj.path = p;
        end
        
        function t = get.type(obj)
            lineOne = lower(obj.text(1));
            if contains(lineOne,'function')
                t = "function";
            elseif contains(lineOne,'classdef')
                t = "class";
            else
                t = "script";
            end
        end
        
        function redTxt = reduceText(obj,txt)
            % reduce txt to only to comments lines
            redTxt(1) = txt(1);
            cI = 1;
            while(1)
                cI = cI+1;
                cL = char(txt(cI));
                cL = strrep(cL,' ','');
                if(~isempty(cL) && cL(1)=="%")
                    redTxt(cI,1) = txt(cI);
                else
                    break;
                end
            end
        end % reduceText
    end
    
    %% further Method
    methods
        function parseFile(obj)
            txt = obj.text;
            
            %% Check for SHORT_DESC (has to be first comment line
            cL = char(txt(2)); cL = strrep(cL,' ','');
            if ~(cL(1:2) == "%%")
                line = 2;
                while(1)
                    line = line+1;
                    if(line > length(txt))
                        lastLine = line;
                        break;
                    end
                    cL = char(txt(line));
                    cL = strrep(cL,' ','');
                    if (contains(upper(cL),"%%"))
                        lastLine = line;
                        break;
                    end
                end
                fil = txt(2:lastLine-1);
                dum = Dummy("{SHORT_DESC}",fil);
                obj.addDummy(dum);
            end
            
            %% Search for known Blocks
            for i = 1:length(obj.knownBlocks)
                line = 0;
                st_found = false;
                firstLine = -1; lastLine = -1;
                while(1)
                    line = line+1;
                    if(line >length(txt))
                        if(st_found)
                            lastLine = line-1;
                        end
                        break;
                    end
                    cL = char(txt(line));
                    cL = strrep(cL,' ','');
                    if contains(upper(cL),"%%"+obj.knownBlocks(i))
                        firstLine = line;
                        st_found = true;
                    elseif (contains(upper(cL),"%%") && st_found)
                        lastLine = line;
                        break;
                    end
                end %while
                if(firstLine>0 && lastLine>0)
                    fil = txt(firstLine+1:lastLine-1);
                    dum = Dummy(obj.knownBlocks(i),fil);
                    obj.addDummy(dum);
                end
            end %for
            
        end % parseFile
        
        function addDummy(obj,dum)
            obj.dummyList{end+1,1} = dum;
        end
        
        function checkCrossRef(obj,fctlist)
            % go through list and search file for function name
            txt = obj.text;
            for i = 1:size(fctlist,1)
                fName = fctlist(i,1);
                for line = 1:length(txt)
                    if (contains(txt(line),fName) && ~contains(txt(line),"%"))
                        refPath = fctlist(i,2);
                        dum = Dummy("{NAME_CALL}",fName);
                        dum.type = "functRef";
                        dum.refPath = refPath;
                        obj.addDummy(dum);
                        break;
                    end
                end
            end
        end
    end
end