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
        end % end if contains
    end % end for line
end %end for i
end % end function checkCrossRef