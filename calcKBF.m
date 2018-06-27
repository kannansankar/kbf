function calcKBF(filelist,entropyVersion,objFun)

finalList=importdata(filelist);
Fout = fopen(['KBF_values_' entropyVersion '_' objFun '.csv'],'w');
fprintf(Fout,['filename,KBF_' entropyVersion 'Entropy_' objFun '\n']);

if (strcmp(entropyVersion,'Fractional'))
    if (strcmp(objFun,'corrP'))
        W4b = 1; Wgf = 0.98733; Wsr = 0.12879; Waacc = 7.3537;
    elseif (strcmp(objFun,'corrS'))
        W4b = 1; Wgf = 0.60622; Wsr = 0.18115; Waacc = 9.3053;
    elseif (strcmp(objFun,'corrK'))
        W4b = 1; Wgf = 0.56953; Wsr = 0.16952; Waacc = 9.5437;
    elseif (strcmp(objFun,'rankN'))
        W4b = 1; Wgf = 0; Wsr = 0.73542; Waacc = 10.844;
    elseif (strcmp(objFun,'bdRMSD'))
        W4b = 1; Wgf = 3.3259; Wsr = 0.55543; Waacc = 19.168;
    elseif (strcmp(objFun,'bdZscore'))
        W4b = 1; Wgf = 0; Wsr = 0; Waacc = 1.7908;
    end
elseif (strcmp(entropyVersion,'Normalized'))
    if (strcmp(objFun,'corrP'))
        W4b = 1; Wgf = 0.79748; Wsr = 0.10605; Waacc = 4.6635;
    elseif (strcmp(objFun,'corrS'))
        W4b = 1; Wgf = 0.55838; Wsr = 0.10754; Waacc = 3.3806;
    elseif (strcmp(objFun,'corrK'))
        W4b = 1; Wgf = 0.58267; Wsr = 0.10236; Waacc = 3.5872;
    elseif (strcmp(objFun,'rankN'))
        W4b = 1; Wgf = 0; Wsr = 0.43964; Waacc = 4.0413;
    elseif (strcmp(objFun,'bdRMSD'))
        W4b = 1; Wgf = 8.3391; Wsr = 0.36455; Waacc = 13.281;
    elseif (strcmp(objFun,'bdZscore'))
        W4b = 1; Wgf = 0; Wsr = 0; Waacc = 20;
    end
end
    
eNative = zeros(size(finalList,1),1);
sNative = zeros(size(finalList,1),1);

    % Extract energies of structures
    energyData = importdata('score_summary.txt');
    list_models = energyData.textdata(3:end);
    energyVal = energyData.data;energyVal(energyVal==0)=NaN;
    for j = 1:size(finalList,1)
        eNative(j) = W4b*energyVal(j,1) + Wgf*energyVal(j,2) + Wsr*energyVal(j,3);
    end
        
    % Extract entropies of native structures
    entropyData = importdata(['KBS_values_' entropyVersion '.csv'],',');
    list_models = entropyData.textdata;
    entropyVal = entropyData.data;
    for j = 1:size(finalList,1)
        sNative(j) = Waacc*entropyVal(j,1);
    end
    
    fNative = eNative - sNative;
    
    for j = 1:size(finalList,1)
        fprintf(Fout,'%s,%.3f\n',finalList{j},fNative(j));
    end
    
fclose(Fout);       