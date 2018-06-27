# Run Yaping's four-body potential energy calculations
#sh clean.sh # Only before copying the PDB files
sh getname.sh
sh energy.sh # Note: Output of potentials will be in 'score_summary.txt'

#First get list of PDB files:-
ls *.pdb > list_structures.txt

# Run executable from MCC for KBF calculations
# Make sure MCR MATLAB RunTiem Version 2015b is installed in the machine
# Set the environmental variable LD_LIBRARY_PATH to the path of MCR installation
# By default, MCR gets installed in /usr/local/MATLAB/MATLAB_Runtime/v90

./run_kbf_matlab_part.sh $LD_LIBRARY_PATH

