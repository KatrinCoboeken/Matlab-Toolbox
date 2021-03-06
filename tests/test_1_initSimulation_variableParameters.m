function [ErrorFlag, ErrorMessage,TestDescription] = test_1_initSimulation_variableParameters
%TEST_1_INITSIMULATION_VARIABLEPARAMETERS Test of Function checkInputOptions
% 
%   [ErrorFlag, ErrorMessage,TestDescription] = TEST_INITSIMULATION_VARIABLEPARAMETERS
%       ErrorFlag (boolean):
%               0 = 'Ok'
%               1 = 'User has to check something by hand or a warning exists
%               2 = 'Serious Error'
%       ErrorMessage (string): Description of the error
 
 
% Open Systems Pharmacology Suite;  support@systems-biology.com
% Date: 20-Sep-2010

global DCI_INFO;

ErrorFlag_tmp=0;
ErrorMessage_tmp{1}='';
TestDescription={};

xml=['models' filesep 'PopSim.xml'];

%% option = none
TestDescription{end+1}='1) option = none;';

initSimulation(xml,'none','report','none');

success=true;
for iTab=[2 4]
    success=success & isempty(DCI_INFO{1}.InputTab(iTab).Variables(1).Values);
end

if ~success
    ErrorFlag_tmp(end+1)=2;
    ErrorMessage_tmp{end+1}=sprintf('failed: %s',TestDescription{end});
end

%% option = 'all'
TestDescription{end+1}='2) option = all;';
initSimulation(xml,'all','report','none');


success=true;
for iTab=[2 4]
    success=success & ...
    length(DCI_INFO{1}.InputTab(iTab).Variables(1).Values)==...
    length(DCI_INFO{1}.InputTab(iTab-1).Variables(1).Values);
end

if ~success
    ErrorFlag_tmp(end+1)=2;
    ErrorMessage_tmp{end+1}=sprintf('failed: %s',TestDescription{end});
end


%% option = 'allNonFormula'
TestDescription{end+1}='3) option = allNonFormula;';
initSimulation(xml,'allNonFormula','report','none');

success=length(DCI_INFO{1}.InputTab(2).Variables(1).Values)==1408 && ...
length(DCI_INFO{1}.InputTab(4).Variables(1).Values)==1129;

if ~success
    ErrorFlag_tmp(end+1)=2;
    ErrorMessage_tmp{end+1}=sprintf('failed: %s',TestDescription{end});
end

%% 'structure' initializeIfFormula =default (with warning)
TestDescription{end+1}='4) "structure" initializeIfFormula =default (with warning);';

initStruct=[];
initStruct=initParameter(initStruct,'*');
initStruct=initSpeciesInitialValue(initStruct,'*');

initSimulation(xml,initStruct,'report','none');

success=true;
for iTab=[2 4]
    success=success & ...
    length(DCI_INFO{1}.InputTab(iTab).Variables(1).Values)==...
    length(DCI_INFO{1}.InputTab(iTab-1).Variables(1).Values);
end

if ~success
    ErrorFlag_tmp(end+1)=2;
    ErrorMessage_tmp{end+1}=sprintf('failed: %s',TestDescription{end});
end

%% 'structure' initializeIfFormula always
TestDescription{end+1}='5) "structure" initializeIfFormula always;';
initStruct=[];
initStruct=initParameter(initStruct,'*','always');
initStruct=initSpeciesInitialValue(initStruct,'*','always');

initSimulation(xml,initStruct,'report','none');

success=true;
for iTab=[2 4]
    success=success & ...
    length(DCI_INFO{1}.InputTab(iTab).Variables(1).Values)==...
    length(DCI_INFO{1}.InputTab(iTab-1).Variables(1).Values);
end

if ~success
    ErrorFlag_tmp(end+1)=2;
    ErrorMessage_tmp{end+1}=sprintf('failed: %s',TestDescription{end});
end

%% 'structure' initializeIfFormula never
logfile='initSimulation_variableParameters';
diary( ['log/' logfile '_' datestr(now,'yyyy_mm_dd') '.log']);
diary on;



ErrorFlag_tmp(end+1)=1;
ErrorMessage_tmp{end+1}=['check logfile:' logfile '!'];
%%
disp(' ');
TestDescription{end+1}='6) "structure" initializeIfFormula never for initParameter;';
disp(sprintf('Test: %s',TestDescription{end})); %#ok<*DSPS>
disp('expected is an errormessage');
initStruct=[];
initStruct=initParameter(initStruct,'*','never');

try
    initSimulation(xml,initStruct,'report','none');
catch exception
    disp(exception.message);
end

disp(' ');
disp('Test option never for initSpeciesInitialValue: expected is an errormessage');
TestDescription{end+1}='7) "structure" initializeIfFormula never for initSpeciesInitialValue;';
disp(sprintf('Test: %s',TestDescription{end})); %#ok<*DSPS>
initStruct=[];
initStruct=initSpeciesInitialValue(initStruct,'*','never');

try
    initSimulation(xml,initStruct,'report','none');
catch exception
    disp(exception.message);
end


disp(' ');
disp('Test unknown keyword for initParameter: expected is a warning');
TestDescription{end+1}='8) Test unknown keyword for initParameter: expected is a warning;';
disp(sprintf('Test: %s',TestDescription{end})); %#ok<*DSPS>
initStruct=[];
initStruct=initParameter(initStruct,'*','hallo');

try
    initSimulation(xml,initStruct,'report','none');
catch exception
    disp(exception.message);
end

%%
disp(' ');
disp('initParameter not existing Parameter: expected is a warning');
TestDescription{end+1}='9.1) Test not existing Parameter initParameter: expected is a warning;';
disp(sprintf('Test: %s',TestDescription{end})); %#ok<*DSPS>
initStruct=[];
initStruct=initParameter(initStruct,'hallo');

try
    initSimulation(xml,initStruct,'report','none');
catch exception
    disp(exception.message);
end

%%
disp(' ');
disp('initParameter not existing Parameter : expected is NO warning');
TestDescription{end+1}='9.2) Test not existing Parameter initParameter: expected is NO warning;';
disp(sprintf('Test: %s',TestDescription{end})); %#ok<*DSPS>
initStruct=[];
initStruct=initParameter(initStruct,'hallo','always','throwWarningIfNotExisting',false);

try
    initSimulation(xml,initStruct,'report','none');
catch exception
    disp(exception.message);
end

diary off;

%%Merge errors
[ErrorFlag,ErrorMessage,TestDescription]=mergeErrorFlag(ErrorFlag_tmp,ErrorMessage_tmp,TestDescription);

return
