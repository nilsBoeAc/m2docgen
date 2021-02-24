classdef TemplateHTML < handle
    % Template for creating HTML File for MATLAB Custom Documentation
    
    %% Properties
    properties
        name string;
        str string;
        
        % Ref Folder
        templFolder string; % root where templates are located
        
        % For Output:
        outFolder string;   % Output folder: Here will the html be stored
        styleFolder string; % Ref Folder where style are located for the output
        homePath string;    % Path to home.html
    end
    properties (Dependent)
        listFilKeys string;
    end
    
    %% Methods
    methods
        function obj = TemplateHTML(name,templateFolder,outFolder,styleFolder,homePath)
            % TemplateHTML Construct an instance of this class
            
            % Set location where template get from
            basisName ="mfile.tpl"; 
            [p,n,ext] = fileparts(name);
            obj.name = n;
            obj.templFolder = templateFolder;
            path = obj.templFolder+basisName;
            
            % Set Output folder
            obj.outFolder = outFolder;
            obj.styleFolder = styleFolder;
            obj.homePath = homePath;
            
            % Read template File
            fil = fopen(path);
            dat = textscan(fil,'%s','delimiter','\n');
            fclose(fil);
            obj.str = string(dat{1});
        end
                
        function parseStr(obj,dummyList)
            strT = obj.str;
            for di = 1:length(dummyList)
                key = dummyList{di}.name;
                filling = dummyList{di}.filling;
                refPath = dummyList{di}.refPath;
                
                switch char((dummyList{di}.type))
                    case char('functRef')
                        strT = filSTR(obj,strT,key,"");
                        strT = filSTR(obj,strT,"{TOTAL_CALL}","");
                        
                        % get Block for adding List
                        strBlock = getTPL(obj,dummyList{di}.type);
                        if(key == "{NAME_CALL}")
                            keyPlace = 'functRef above';
                        else
                            key = "{NAME_CALL}";
                            keyPlace = 'functReRef above';
                        end
                        
                        strBlock = filSTR(obj,strBlock,key,filling);
                        if(strcmp(refPath,"NA"))
                            strBlock = filSTR(obj,strBlock,"{REF_CALL}",filling+".html");
                        else
                            strBlock = filSTR(obj,strBlock,"{REF_CALL}",refPath);
                        end
                        
                        strT = addBlock(obj,strT,strBlock,keyPlace);
                    otherwise
                        strT = filSTR(obj,strT,key,filling);
                end
            end
            obj.str = strT;
        end % parseStr

        function createHTML(obj)
            finalStr = obj.str;
            outname = fullfile(obj.outFolder, obj.name + ".html");
            currDate = date;
            finalStr = filSTR(obj,finalStr,"{NAME}",obj.name);
            finalStr = filSTR(obj,finalStr,"{DATE}",string(currDate));
            finalStr = filSTR(obj,finalStr,"{YEAR}",string(currDate(end-3:end)));
            finalStr = filSTR(obj,finalStr,"{HOME_HTML}",obj.homePath);
            finalStr = filSTR(obj,finalStr,"{STYLE_FOLDER}",obj.styleFolder);
            obj.str = finalStr;
            
            if(~isempty(obj.listFilKeys))
                disp("Open Key-Words - remove Blocks:");
                disp(obj.listFilKeys);
                obj.str = removeBlocks(obj);
            end
            
            % write HTML
            fil = fopen(outname,'w');
            fprintf(fil,"\n%s",obj.str);
            fclose(fil); 
        end % createHTML
        
        function tplStr = getTPL(obj,type)
            file = obj.templFolder+type+".tpl";
            fil = fopen(file);
            dat = textscan(fil,'%s','delimiter','\n');
            fclose(fil);
            tplStr = string(dat{1});
        end  % getTPL      
    end
    
    %% File Adjust Functions
    methods
        function strT = filSTR(obj,strT,old,new)
            tline = 0;
            while(1)
                tline = tline+1;
                if(tline>length(strT))
                    break;
                end
                if(contains(strT(tline),old))
                    splitSTR = split(strT(tline),old);
                    fil = new;
                    fil(1) = splitSTR(1)+fil(1);
                    fil(end) = fil(end) + splitSTR(end);
                    strT = [strT(1:tline-1); fil; strT(tline+1:end)];
                end
            end
        end % filSTR
        
        function strT = addBlock(obj,strT,strBlock,keyword)
            tline = 0;
            while(1)
                tline = tline+1;
                if(tline>length(strT))
                    break;
                end
                if(contains(strT(tline),keyword))
                    strT = [strT(1:tline-1); strBlock; strT(tline:end)];
                    break;
                end
            end
        end % addBlock
        
        function strT = removeBlocks(obj)
            listT = obj.listFilKeys;
            for i = 1:length(listT)
                key = listT(i);
                startKey = "START "+key; endKey = "END "+key; 
                tline = 0; startLine = []; endLine = [];
                while(1)
                    tline = tline+1;
                    if(tline>length(obj.str))
                        break; 
                    end

                    if(contains(obj.str(tline),startKey))
                        startLine = tline;
                    end
                    if(contains(obj.str(tline),endKey))
                        endLine = tline;
                        break;
                    end
                end
                if(~isempty(startLine) || ~isempty(endLine))
                    obj.str = [obj.str(1:startLine); obj.str(endLine:end)];
                end
            end
            strT = obj.str;
        end % removeBlocks
    end
    
    methods
        %% set Functions
        function set.outFolder(obj,fd)
            tmp = char(fd);
            if(tmp(end)~="\")
                fd = fd+"\";
            end
            obj.outFolder = fd;
        end
        
        function set.styleFolder(obj,fd)
            tmp = char(fd);
            if(tmp(end)~="\")
                fd = fd+"\";
            end
            obj.styleFolder = fd;
        end
        
        function set.templFolder(obj,fd)
            tmp = char(fd);
            if(tmp(end)~="\")
                fd = fd+"\";
            end
            obj.templFolder = fd;
        end
        
        %% get Functions
    
        function listN = get.listFilKeys(obj)
            strT = obj.str;
            j = 0;
            word = strings;
            for i = 1:length(strT)
                if(contains(strT(i),"{"))
                    j = j+1;
                    chStr = char(strT(i));
                    idxS = strfind(chStr,'{');
                    idxE = strfind(chStr,'}');
                    word(j,1) = string(chStr(idxS+1:idxE-1));
                end
            end
            
            listN = word;
        end
    end
end

