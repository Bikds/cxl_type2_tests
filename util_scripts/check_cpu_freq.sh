# sudo cpupower --cpu all frequency-info | grep "current CPU frequency"
CPUPATH=/fast-lab-share/yangz15/emr1_back/linux-6.5.10/tools/power/cpupower
# Run cpupower with LD_LIBRARY_PATH preserved under sudo
sudo env LD_LIBRARY_PATH=$CPUPATH $CPUPATH/cpupower --cpu all frequency-info | grep "current CPU frequency"
