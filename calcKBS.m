function calcKBS(filelist,entropyVersion,CG)
finalList=importdata(filelist);
Fout = fopen(['KBS_values_' entropyVersion '.csv'],'w');
fprintf(Fout,['filename,KBS_' entropyVersion '\n']);

for i = 1:size(finalList,1)
    filein = finalList{i};
    
    fprintf('Starting %s ...',filein); 
    
    
    if(CG == 0)
        S = aaccEntropyAA(filein,entropyVersion,4.5);
    elseif(CG == 1)
        S = aaccEntropyCG(filein,entropyVersion,10);
    end
    
    fprintf(Fout,'%s,%.3f\n',filein,S);
    fprintf('Done\n'); 
end
fclose(Fout);   
