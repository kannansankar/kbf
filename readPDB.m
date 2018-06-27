function AtomStruct = readPDB(molecule,outtype,map,allModels,verbose)
% AtomStruct = readPDB(molecule,outtype,map,allModels,verbose)
% 
% This function is used for reading in PDB file information into MATLAB.
% Its precursor was 'getSetupAll_NS.m' which is faster, but does not handle
% the presence of iCode or altLoc well.
% 
% This function reads structure files based on PDB format (fixed width) by
% building an array of structures - a structure for each line - but can
% return a structure or arrays if requested by outtype.
% 
% INPUTS:
%   molecule        path to the PDB file
%   outtype         the type of output desired.  See PARAMETERS
%   map             boolean - to generate an alpha carbon map
%   allModels       boolean - if true, return all MODELs
%   verbose         if true, show status messages
% 
% PARAMETERS:
% outtype == 0      function returns (x,y,z) coordinates only
% outtype == 1      function returns a structure of arrays (all data)
%                       For string data, the array is a cell array
% outtype == 2      function returns the crystallographic temperature factors only
% outtype == 3      returns coordinates and isotropic temperature factors
% outtype else      function returns an array of structures (all data)
%                       This is the same result as using 'pdbread' from the
%                       bioinformatics toolbox.
% 
% NOTE: If molecule is an NMR file (or any file with MODEL statements), then each MODEL
%       will be stored as a cell and AtomStruct will be a cell array.  If
%       outtype=1 and map=1, then the map is only stored in the first cell.
% NOTE: The "map" functionality can be efficiently reproduced for any atom
%       type with the following line of code:
%       atommap = find(strmpp(strtrim(AtomStruct.AtomName),'CA'));
% 
% DEFAULT:
%   outtype   = 0
%   map       = 0
%   allModels = 1
% 
% Author: Michael Zimmermann

if nargin < 1;              eval('help readPDB');
                            AtomStruct=0; return;   end
if ~exist('outtype','var'), outtype=0;              end
if ~exist('map','var'),     map=0;                  end
if ~exist('allModels','var'),allModels=1;           end
if ~exist('verbose','var'), verbose=0;              end
if nargout == 0,            disp('Please specify output variable(s)'); 
                            AtomStruct=0; return;   end

%IF NOT USING WINDOWS, DO: [status, result] = system( ['wc -l ', molecule] );
n           = perl('countlines.pl',molecule); %while (<>) {}; print $.,"\n";
n           = str2double(n);
b           = 0;
modelCount  = 0;
models      = {};
con         = {}; % contains CONECT record lines
cons        = 0;  % number of CONECT records found

% -------------------------------------------------------------------------
if(~exist(molecule,'file'))
    if verbose
        disp( '   --> File does not exist - Please check the path');
        disp(['   --> Attempt to read: "' molecule '" in readPDB.m failed.'])
    end
    AtomStruct=0;
    return
else
    fid = fopen(molecule);
    for a=1:n
        tline = fgetl(fid);
        
        if length(tline) < 6
            continue; % skip over END lines or blank lines
        end
        
        if strcmp(tline(1:6),'MODEL ')
            modelCount = modelCount+1;
            b = 0;
            if ~allModels && modelCount>1
                break; % we only want the first model
            end
        elseif strcmp(tline(1:6),'CONECT')
            cons = cons+1;
            con{cons} = [tline repmat(' ',1,31-length(tline))];
        elseif strcmp(tline(1:6),'ENDMDL')
            % save the model we read in to a cell
            if exist('ani','var')
                ani(end+1:numel(TmpAtomStruct)) = cell(numel(TmpAtomStruct)-numel(ani),1);
                for i = 1:numel(TmpAtomStruct)
                    TmpAtomStruct(i).ANISOU = ani{i};
                end
            end
            models{modelCount} = TmpAtomStruct;
            clear TmpAtomStruct ani
            b = 0;
        elseif (strcmp(tline(1:6),'ATOM  ') || strcmp(tline(1:6),'HETATM'))
            % we have a line of structure to read
            b = b+1;
            if length(tline) < 80
                tline = [tline repmat(' ',1,80-length(tline))];
            end

            % NOTE: the command 'pdbread' uses an "array of structures" rather
            % than a "structure of arrays"
            % This script takes their pdbread format and allows the user to use
            % it, or to return a structure of arrays, or just the (x,y,z).
            
            %%% many of these fields used to be within strtrim() calls, but
            %%% that made issues when printing PDBs.
            TmpAtomStruct(b) = struct('RecordName',{tline(1:6)},...
                           'AtomSerNo',{str2int(tline(7:11))},...
                           'AtomName',{tline(13:16)},...
                           'altLoc',{tline(17)},...
                           'resName',{tline(18:20)},...
                           'chainID',{tline(22)},...
                           'resSeq',{str2int(tline(23:26))},...
                           'iCode',{tline(27)},...
                           'X',{str2float(tline(31:38))},...
                           'Y',{str2float(tline(39:46))},...
                           'Z',{str2float(tline(47:54))},...
                           'occupancy',{str2int(tline(55:60))},...
                           'tempFactor',{str2float(tline(61:66))},...
                           'segID',{tline(73:76)},...
                           'element',{tline(77:78)},...
                           'charge',{tline(79:80)},...
                           'AtomNameStruct',struct('chemSymbol',{tline(13:14)},...
                                                   'remoteInd',{tline(15)},...
                                                   'branch',{tline(16)}));
        elseif strcmp(tline(1:6),'ANISOU')
            ani{b} = [...
                str2float(tline(29:35)) str2float(tline(50:56)) str2float(tline(57:63));...
                str2float(tline(50:56)) str2float(tline(36:42)) str2float(tline(64:70));...
                str2float(tline(57:63)) str2float(tline(64:70)) str2float(tline(43:49))];
            
        end
    end
    fclose(fid);
end

if ~exist('TmpAtomStruct','var') && (modelCount == 0)
    if verbose
        disp('   --> readPDB.m found no structure in the PDB file.')
    end
    AtomStruct.IND = [];
    return
end

% -------------------------------------------------------------------------
% See the following for more on structure arrays
% http://blogs.mathworks.com/pick/2008/04/22/matlab-basics-array-of-structures-vs-structures-of-arrays/
if isempty(models)
    % we have only one model - no need to process the cells
    if outtype == 0
        % only return the (x,y,z) coordinates
        AtomStruct = [cell2mat({TmpAtomStruct(:).X}); cell2mat({TmpAtomStruct(:).Y}); cell2mat({TmpAtomStruct(:).Z})]';
    elseif outtype == 1
        % return a structure of arrays - saves memory too!
        try
            AtomStruct.recordName = {TmpAtomStruct(:).RecordName}';
            AtomStruct.IND        = [cell2mat({TmpAtomStruct(:).X}); cell2mat({TmpAtomStruct(:).Y}); cell2mat({TmpAtomStruct(:).Z})]';
            AtomStruct.AtomSerNo  = (cell2mat({TmpAtomStruct(:).AtomSerNo}))';
            AtomStruct.AtomName   = {TmpAtomStruct(:).AtomName}';
            AtomStruct.altLoc     = char({TmpAtomStruct(:).altLoc}');
            AtomStruct.resName    = {TmpAtomStruct(:).resName}';
            AtomStruct.resSeq     = (cell2mat({TmpAtomStruct(:).resSeq}))';
            AtomStruct.chainID    = char({TmpAtomStruct(:).chainID});
            AtomStruct.iCode      = {TmpAtomStruct(:).iCode}';
            AtomStruct.occupancy  = (cell2mat({TmpAtomStruct(:).occupancy}))';
            AtomStruct.tempFactor = cell2mat({TmpAtomStruct(:).tempFactor})';
            AtomStruct.segID      = {TmpAtomStruct(:).segID}';
            AtomStruct.element    = {TmpAtomStruct(:).element}';
            AtomStruct.charge     = {TmpAtomStruct(:).charge}';
            AtomStruct.conect     = con;

            if exist('ani','var')
                AtomStruct.ANISOU = ani(:);
                % fill in trailing missing ANISOU records with blanks
                for i = length(AtomStruct.ANISOU)+1 : length(AtomStruct.IND)
                    AtomStruct.ANISOU{i} = [];
                end
            end
        catch ME
            if ~exist('TmpAtomStruct','var')
                % there was no structure information in the file
                AtomStruct.IND = [];
            end
        end
        
    elseif outtype == 2
        % return the isotropic temperature factors
        AtomStruct = cell2mat({TmpAtomStruct(:).tempFactor})';
    elseif outtype == 3
        % coordinates and temp factors
        AtomStruct.IND = [cell2mat({TmpAtomStruct(:).X}); cell2mat({TmpAtomStruct(:).Y}); cell2mat({TmpAtomStruct(:).Z})]';
        AtomStruct.tempFactor = cell2mat({TmpAtomStruct(:).tempFactor});
    else
        % return an array of structures
        AtomStruct = TmpAtomStruct;
    end
else
    % we have a multi-MODEL file.  Each MODEL is a cell of 'models'
    if outtype == 0
        A = cell(numel(models),1);
        AtomStruct = zeros(b,3,numel(models));
        for a = 1:numel(models)
            A{a} = [cell2mat({models{a}(:).X}); cell2mat({models{a}(:).Y}); cell2mat({models{a}(:).Z})];
            AtomStruct(:,:,a) = A{a}';
        end
    else
        AtomStruct = cell(numel(models),1);
        for a = 1:numel(models)
            A.recordName = {models{a}(:).RecordName}';
            A.IND = [cell2mat({models{a}(:).X}); cell2mat({models{a}(:).Y}); cell2mat({models{a}(:).Z})]';
            A.AtomSerNo = cell2mat({models{a}(:).AtomSerNo})';
            A.AtomName = {models{a}(:).AtomName}';
            A.altLoc = cell2mat({models{a}(:).altLoc})';
            A.resName = {models{a}(:).resName}';
            A.chainID = char({models{a}(:).chainID});
            A.resSeq = cell2mat({models{a}(:).resSeq})';
            A.iCode = {models{a}(:).iCode}';
            A.occupancy = cell2mat({models{a}(:).occupancy})';
            A.tempFactor = cell2mat({models{a}(:).tempFactor})';
            A.segID = {models{a}(:).segID}';
            A.element = {models{a}(:).element}';
            A.charge = {models{a}(:).charge}';
            if isfield(models{a},'ANISOU')
                A.ANISOU = {models{a}(:).ANISOU};
            end
            
            AtomStruct{a} = A;
        end
    end
    if ~allModels
        % we only have a 1x1 cell. No need to keep it as a cell array
        AtomStruct = AtomStruct{1};
    end
end

% -------------------------------------------------------------------------
if map
    if isstruct(AtomStruct),    n = length(AtomStruct.IND);
    elseif iscell(AtomStruct),  n = length(AtomStruct{1}.IND);
    else                        n = length(AtomStruct);
    end
    
    b = 1;
    for a = 1:n
        if isempty(models)
            if strcmp(strtrim(TmpAtomStruct(a).AtomName),'CA')
                tmpmap(b) = a;
                b = b+1;
            end
        else
            if strcmp(strtrim(models{1}(a).AtomName),'CA')
                tmpmap(b) = a;
                b = b+1;
            end
        end
    end
    
    if exist('tmpmap','var')
        if isstruct(AtomStruct),    AtomStruct.map2CA = tmpmap;
        elseif iscell(AtomStruct),  AtomStruct{1}.map2CA = tmpmap;
        else                        tmp = AtomStruct;
                                    clear AtomStruct;
                                    AtomStruct.IND=tmp;
                                    AtomStruct.map2CA = tmpmap;
        end
    end
end

% -------------------------------------------------------------------------
function val = str2int(str)
val = sscanf(str,'%d');
if isempty(val), val=0; end

function val = str2float(str)
val = sscanf(str,'%e');