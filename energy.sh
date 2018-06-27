#!/bin/bash
chmod +x *
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:.
echo "Generating files ..."
for i in $(cat name.txt);
do
	echo -e $i".pdb" >> list
	echo -e $i".gen" >> list_outputGeneral.dat
	echo -e "./naccess "$i".pdb" >> batch.rsa.sh
	echo -e "./general "$i".pdb "$i".rsa "$i".gen" >> batch.gen.sh
done
cp list list_orig
echo "Batch naccess ..."
sh batch.rsa.sh
echo "tetra test & decoy test ..."
./tetraTest
./decoyTest
echo "Batch energy calculation ..."
sh batch.gen.sh
echo "general_threading ..."
./general_threading
echo "MJ ..."
./MJ
echo "MJthreading ..."
./MJthreading
echo "short ..."
./short
echo "Pitor ..."
./Pitor
echo "summary ..."
./summary
cp score_summary.txt score_summary.last
echo "done. check result in score_summary.txt"


