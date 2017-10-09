#!/bin/bash

. ~/.bashrc
shopt -s expand_aliases

####  Parse User Input #####
if [ "$1" != "-ID" ] ;
then
  echo "Incorrect Paramater Usage"
  echo "Usage: opconsole_setup.ksh -ID <application id lowercase>"
  exit 1
else
  supper=$2
  sdowner=`echo $supper | tr '[:upper:]' '[:lower:]'`
fi

##############################################################################################

bridges=`ps -alef | grep -f ~/*k/check_daemon_new.env | grep bridge | awk '{ print $16" "$17" "$18}' | awk -F "/" '{ print $5}' | egrep [0-9] | perl -e 's/-//g' -p| perl -e 's/.*V//g' -p`

reporter=` ps -alef | grep -f ~/*k/check_daemon_new.env | grep -E "(reporter)" | awk '{ print $16" "$17" "$18}' | awk -F "/" '{ print $8}' | perl -e 's/-//g' -p| perl -e 's/.*V//g' -p`

cd $AB_HOME/../
export APP_NAME=$2
export host_file=`locate -i host-alias | grep -v bkp`
export host_dir=`echo $host_file | xargs dirname`
export host_base=`echo $host_file | xargs basename`
cp $host_file ${host_dir}/${host_base}.bkp.` date +%Y%m%d`			 
echo "ops-${APP_NAME} `hostname -s`" >> ${host_dir}/${host_base}	

export opconsole_file=`locate -i ab_opconsole_alias_file | grep -vE "(bkp|template)" `
export opconsole_dir=`echo $opconsole_file | xargs dirname`
export opconsole_base=`echo $opconsole_file | xargs basename`
cp $opconsole_file ${opconsole_dir}/${opconsole_base}.bkp.` date +%Y%m%d`
cat ab_opconsole_alias_file_template_do_not_delete | perl -e "s/app_mcad/$APP_NAME/g" -p >> ${opconsole_dir}/${opconsole_base}

for i in $reporter 
do
    echo " Restarting Ab Reporter version $i "
    eval $i
    ab-reporter restart
    ab-reporter status
done

for j in $bridges 
do
    echo "Restarting Ab Bridge version $j"
    eval $j
    add=`echo $j | awk '{ print(substr($0,1,1))"-"(substr($0,2,1))"-"(substr($0,3,1))} '`
    ab-bridge stop -workdir /*/abinitio/ab_work_dir/ab-bridge-V${add}/abi
    ab-bridge start -workdir /*/abinitio/ab_work_dir/ab-bridge-V${add}/abi
    ab-bridge status -workdir /*/abinitio/ab_work_dir/ab-bridge-V${add}/abi
done

