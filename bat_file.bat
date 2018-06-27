cd /var/www/cgi-bin/potential/data
cp /var/www/cgi-bin/potential/code/* /var/www/cgi-bin/potential/data/
cp /var/www/cgi-bin/potential/result/list_orig /var/www/cgi-bin/potential/data/
cp /var/www/cgi-bin/potential/result/list /var/www/cgi-bin/potential/data/
chmod 755 *
chown apache.apache *
nohup /var/www/cgi-bin/potential/data/tetraTest >nohup.out
nohup /var/www/cgi-bin/potential/data/decoyTest >nohup.out
sh /var/www/cgi-bin/potential/data/genFour-body.bat 
#nohup /var/www/cgi-bin/potential/data/general >nohup.out
nohup /var/www/cgi-bin/potential/data/general_threading >nohup.out
nohup /var/www/cgi-bin/potential/data/MJ >nohup.out
nohup /var/www/cgi-bin/potential/data/MJthreading >nohup.out
nohup /var/www/cgi-bin/potential/data/short >nohup.out
nohup /var/www/cgi-bin/potential/data/Pitor >nohup.out
nohup /var/www/cgi-bin/potential/data/summary >nohup.out
cp /var/www/cgi-bin/potential/data/score_summary.txt /var/www/cgi-bin/potential/result
cd /var/www/cgi-bin/potential/data
ls >name.txt
awk '{printf "rm -f /var/www/cgi-bin/potential/data/%s\n",$1}' </var/www/cgi-bin/potential/data/name.txt >/var/www/cgi-bin/potential/data/remove.bat
sh /var/www/cgi-bin/potential/data/remove.bat
rm -f -r /var/www/cgi-bin/potential/data/*

