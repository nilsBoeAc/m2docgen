clear variables;

%% Function List
flist(1,1) = "eigs";
flist(1,2) = "start";
flist(2,1) = "sdm_FFT";
flist(2,2) = "start";
flist(3,1) = "sdb_FFT";
flist(3,2) = "start";

%% Path
homePath = "start.html";
root = pwd+"\Templates\Standard_V1";

%% First File
mf = MFile("sdm_eigenproblem.m",pwd);
mf.parseFile;
mf.checkCrossRef(flist);

tmpl = TemplateHTML(mf.name,root,pwd+"\mydoc",root,homePath);
tmpl.parseStr(mf.dummyList);
tmpl.createHTML;

%% Second File
mf = MFile("CalcFFT.m",pwd);
mf.parseFile;
mf.checkCrossRef(flist);

tmpl = TemplateHTML(mf.name,root,pwd+"\mydoc",root,homePath);
tmpl.parseStr(mf.dummyList);
tmpl.createHTML;


