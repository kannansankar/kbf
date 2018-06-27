# ==== SHELL =================
# Run Yaping's four-body potential energy calculations
sh clean.sh # Only before copying the PDB files
sh getname.sh
sh energy.sh # Note: Output of potentials will be in 'score_summary.txt'

#First get list of PDB files:-
ls *.pdb > list_structures.txt

# Invoke MATLAB
/home/Softwares/MATLAB/R2015b/bin/matlab -nodesktop

# ==== MATLAB ================
# Read user input parameters from file
parameterStr = importdata('parameters.txt');
parameters = parameterStr.data;

# Get whether user asked for Fractional/Normalized entropies or both
Fractional = parameters(1);
Normalized = parameters(2);

# Get objective function parameters
corrP = parameters(3);
corrS = parameters(4);
corrK = parameters(5);
rankN = parameters(6);
bdRMSD = parameters(7);
bdZscore = parameters(8);

# Get whether user has submitted all-atom or coarse-grained
CG = parameters(9); # User only chooses one option. So either 0 (all-atom) or 1 (coarse-grained)

# Depending upon user's options, compute KBSs and KBFs
if (Fractional == 1)
    calcKBS('list_structures.txt','Fractional',CG);
    if (corrP == 1)
        calcKBF('list_structures.txt','Fractional','corrP')
    end
    if (corrS == 1)
        calcKBF('list_structures.txt','Fractional','corrS')
    end
    if (corrK == 1)
        calcKBF('list_structures.txt','Fractional','corrK')
    end
    if (rankN == 1)
        calcKBF('list_structures.txt','Fractional','rankN')
    end
    if (bdRMSD == 1)
        calcKBF('list_structures.txt','Fractional','bdRMSD')
    end
    if (bdZscore == 1)
        calcKBF('list_structures.txt','Fractional','bdZscore')
    end
end
  
if (Normalized == 1)
    calcKBS('list_structures.txt','Normalized',CG);
    if (corrP == 1)
        calcKBF('list_structures.txt','Normalized','corrP')
    end
    if (corrS == 1)
        calcKBF('list_structures.txt','Normalized','corrS')
    end
    if (corrK == 1)
        calcKBF('list_structures.txt','Normalized','corrK')
    end
    if (rankN == 1)
        calcKBF('list_structures.txt','Normalized','rankN')
    end
    if (bdRMSD == 1)
        calcKBF('list_structures.txt','Normalized','bdRMSD')
    end
    if (bdZscore == 1)
        calcKBF('list_structures.txt','Normalized','bdZscore')
    end
end

