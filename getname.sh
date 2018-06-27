ls -l *.pdb|awk '{print $9}'|sed 's/\.pdb//g' > name.txt
