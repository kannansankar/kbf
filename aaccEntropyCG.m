function [S]= aaccEntropyCG(filein,entropyVersion,cutoff)

if(strcmp(entropyVersion,'Fractional'))
    MC=csvread('FracAACC.csv',1,1,[1 1 20 20]);
elseif(strcmp(entropyVersion,'Normalized'))
    MC=csvread('PropAACC.csv',1,1,[1 1 20 20]);
end

matOrder = ['A' 'I' 'L' 'V' 'M' 'F' 'W' 'G' 'P' 'C' 'N' 'Q' 'S' 'T' 'Y' 'D' 'E' 'R' 'H' 'K'];
[~,aa2intIndex]=sort(aa2int(matOrder));
aaMat = MC(aa2intIndex,aa2intIndex);

m = readPDB(filein,1); % read molecule

if(isfield(m,'IND') && isfield(m,'resName') && isfield(m,'resSeq'))
%n = size(m.IND,1); % return size of m.IND.[1]

    m.resName(strcmp(m.resName,'MSE'))=cellstr('MET');
    m.resName(strcmp(m.resName,'HSD'))=cellstr('HIS');
    m.resName(strcmp(m.resName,'SEC'))=cellstr('CYS');
    m.resName(strcmp(m.resName,'CGU'))=cellstr('GLU');
    m.resName(strcmp(m.resName,'HIC'))=cellstr('HIS');
    m.resName(strcmp(m.resName,'IAS'))=cellstr('ASP');
    m.resName(strcmp(m.resName,'GLX'))=cellstr('GLU');
    m.resName(strcmp(m.resName,'HSE'))=cellstr('HIS');
    m.resName(strcmp(m.resName,'PTR'))=cellstr('TYR');


    atomDistVector = pdist(m.IND);
    atomDist = squareform(atomDistVector);
    atomContact = atomDist<=cutoff;
    resContact = atomContact;

    %resOrder = unique(m.resSeq);
    %numRes = size(resOrder,1);

    %[~,first,~] = unique(m.resSeq,'first');
    %[~,last,~] = unique(m.resSeq,'last');
    %C=mat2cell(atomContact,last-first+1,last-first+1);
    %sumCells = cellfun(@(b)sum(b(:)),C,'UniformOutput',0);
    %sumMat = cell2mat(sumCells);
    %resContact = sumMat > 0;
    ind = aa2int(char(aminolookup(m.resName)));
    S = sum(sum(aaMat(ind,ind).*tril(resContact,-4)));

else 
    S = NaN;
end

