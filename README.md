# Atalanata butterfly High Throughput Kyber-768 repository.

To test simulation, set key_encapsulation_tb.v as top and run simulation

To change the streaming width, set COEF_PER_CLOCK_CYCLE on line 52 of ntt_params.v to either (1<<5), (1<<6) or (1<<7),
and modify the LOG_N_MIN_COEF in python to 3, 2 or 1 respectively. A (1<<8) version currently works for the NTT and SHA,
but has not been tested with the full circuit. Because of the structure of the Bailey NTT and Keccak, anything below
1<<5 will not work.

Inputs are expected to come in as bursts and come out in streams. The ciphertext output is a bit idiosyncratic, 
but could be modified at low control logic cost to match the user's desired format.
