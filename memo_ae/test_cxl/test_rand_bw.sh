#!/bin/bash
NUM_THREADS=32
STEP=2
ITERATION=3
OP_MAX=3

# OPS=(0 1 2 3 6 7 8 9)
OPS=(0 1)
# THREAD_CNT=(1 2 4 6 8)
THREAD_CNT=(1 2 4 8 16 32)
# THREAD_CNT=(1 2)
BATCH_SIZES=(32 64)

bash ../../util_scripts/config_all.sh
source ../../util_scripts/env.sh

for ((k=0;k<=$NODE_MAX;k++)); do # k node

    # for ((op=0;op<=$OP_MAX;op++)); do
    for op in ${OPS[@]}; do # op operation

        for i in ${THREAD_CNT[@]}; do # i thread
            FOLDER_NAME=rand_bw_${k}_test
            # batch_size=16 #
            echo "[INFO] ====> new core: ${i} <==== "

            # for ((j=0;j<7;j=j+1)); do # j blocksize
            for batch_size in ${BATCH_SIZES[@]}; do # batch size
                CURR_RESULT_PATH=../results/$FOLDER_NAME/
                mkdir -p $CURR_RESULT_PATH

                echo "[TEST] node: $k, op: $op, thread: ${i}, batch_size: ${batch_size} ......"
                # THROUGHPUT=`sudo ../src/cxlMemTest -p $CLOSEST_CORE -f -t $i -S 6 -n $k -T 1 -o $op -i $ITERATION -g $batch_size -r | awk '/get_bw/ {print}'` 
                THROUGHPUT=`sudo ../src/cxlMemTest -p $CLOSEST_CORE -f -t $i -S 16 -n $k -T 1 -o $op -i $ITERATION -g $batch_size -r | awk '/get_bw/ {print}'` 
                BW=`echo $THROUGHPUT | awk '{print $(NF-1)}'`
                echo $BW >> $CURR_RESULT_PATH/${i}_${op}.txt
                echo $THROUGHPUT
                # batch_size=$((batch_size*2))
            done
        done
    done
done