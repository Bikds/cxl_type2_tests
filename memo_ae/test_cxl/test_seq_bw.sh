#!/bin/bash
NUM_THREADS=32
STEP=2
ITERATION=3
OP_MAX=3

# OPS=(0 1 2 3 6 7 8 9)
OPS=(0 1)
THREAD_CNT=(1 2 4 8 16 32)

bash ../../util_scripts/config_all.sh
source ../../util_scripts/env.sh

for ((j=0;j<=$NODE_MAX;j++)); do
    FOLDER_NAME=seq_bw_${j}_test
    CURR_RESULT_PATH=../results/$FOLDER_NAME
    mkdir -p $CURR_RESULT_PATH

    # for ((k=6;k<=6+$OP_MAX;k++)); do
    for k in ${OPS[@]}; do # op operation

        # for ((i=0;i<=$NUM_THREADS;i=i+$STEP)); do
        for i in ${THREAD_CNT[@]}; do # thread count
            if [ $i == 0 ];then
                continue
            fi

            echo "[TEST] node: $j, op: $k, num_thread: $i......"
            THROUGHPUT=`sudo ../src/cxlMemTest -p $CLOSEST_CORE -f -t $i -S 16 -n $j -d $j -T 1 -o $k -i $ITERATION | awk '/get_bw/ {print}'` 
            BW=`echo $THROUGHPUT | awk '{print $(NF-1)}'`
            echo $BW >> $CURR_RESULT_PATH/seq_bw_$k.txt
            echo $THROUGHPUT
        done
    done
done
