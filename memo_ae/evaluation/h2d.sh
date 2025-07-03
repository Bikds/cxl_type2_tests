ITERATION=10

# remember to update util/env.sh for CPU frequency and closet core
bash ../util_scripts/config_all.sh
source ../util_scripts/env.sh

test_block_lats(){
	echo "H2D Test Started"
	echo "CLOSEST_NODE: $CLOSEST_NODE, CLOSEST_CORE: $CLOSEST_CORE, TSC_FREQ: $TSC_FREQ"
	RESULT_FOLDER="h2d-$(date +'%m-%d-%H-%M-%S')"

	PROCESS_NODE=$CLOSEST_NODE
	# memory_node = 2
	MEMORY_NODE=2
	PROCESS_CORE=$CLOSEST_CORE

	CURR_RESULT_PATH=../results/$RESULT_FOLDER/
	mkdir -p $CURR_RESULT_PATH

	# L2R cache state loops: L-L1-0-R-LLC-0, L-L1-1-R-LLC-0, L-L1-0-R-LLC-1, L-L1-1-R-LLC-1
	# operation loops: ld, nt-ld, st, nt-st
	# V: req type (0: L2L, 1: L2R, 2:H2D, 3:D2H) 
	# W: local L1 hit, X: local LLC hit, Y: remote L1/DMC hit, Z: remote LLC hit
	
	for ((i=0;i<3;i=i+1)); do
		# set L1 hit and LLC hit based on i
		HIT_L1=$(($i%2))
		HIT_LLC=$(($i/2))
		
		for ((j=0;j<4;j=j+1)); do
			echo "[TEST] op: $j proc node: $PROCESS_NODE, mem node: $MEMORY_NODE, HIT_L1: $HIT_L1, HIT_LLC: $HIT_LLC"
			# 1 thread, 1 GB buffer, block latency
			LINE=$(sudo ../src/cxlMemTest -p $PROCESS_CORE -t 1 -S 1 -n $MEMORY_NODE -V 2 -W $HIT_L1 -X $HIT_LLC -T 3 -o $j -i $ITERATION -B -F $TSC_FREQ | grep -E "Median latency|Avg latency|Var latency")
			
			echo $LINE
			
			# Extract and store the Median latency
			if echo $LINE | grep -q "Median latency"; then
				LATS=$(echo $LINE | grep "Median latency" | awk -F 'Median latency among [0-9]+ iterations: ' '{print $2}' | awk -F ' ' '{print $1}')
				echo $LATS >> $CURR_RESULT_PATH/lats_median_l1_${HIT_L1}_llc_${HIT_LLC}_n${CLOSEST_NODE}.txt
				echo $LATS
			fi

			# Extract and store the Avg latency
			if echo $LINE | grep -q "Avg latency"; then
				LATS=$(echo $LINE | grep "Avg latency" | awk -F 'Avg latency among [0-9]+ iterations: ' '{print $2}' | awk -F ' ' '{print $1}')
				echo $LATS >> $CURR_RESULT_PATH/lats_avg_l1_${HIT_L1}_llc_${HIT_LLC}_n${CLOSEST_NODE}.txt
				echo $LATS
			fi

			# Extract and store the Var latency
			if echo $LINE | grep -q "Var latency"; then
				LATS=$(echo $LINE | grep "Var latency" | awk -F 'Var latency among [0-9]+ iterations: ' '{print $2}' | awk -F ' ' '{print $1}')
				echo $LATS >> $CURR_RESULT_PATH/lats_var_l1_${HIT_L1}_llc_${HIT_LLC}_n${CLOSEST_NODE}.txt
				echo $LATS
			fi
			
		done
	done

}

test_block_lats
