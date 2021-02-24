function printToc(obj)
% prints the obj.toc into the command window

    if iscell(obj.toc)
        preStr = " ";
        listElements(obj.toc, preStr);
    end
end

function listElements(myCell, preStr)
% recursive function.
    fn = string(myCell(:,1)); % fieldnames = toc - names
    for i = 1:numel(fn)
        disp(preStr + fn(i));
        if ~isempty(myCell{i,3})
            newStr = preStr + "   --- ";
            listElements(myCell{i,3}, newStr);
        end
    end
end