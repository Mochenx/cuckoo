# -Wno-deprecated-declarations shuts up Apple OSX clang
FLAGS = -Wall -Wno-deprecated-declarations -D_POSIX_C_SOURCE=200112L -O3 -pthread 
LIBS = -lssl -lcrypto
# leave out -l crypto if using sha256.c instead of openssl
CC = cc -std=c99 $(FLAGS)
GPP = g++ -std=c++11 -DATOMIC $(FLAGS)
# leave out -std=c++11 -DATOMIC for older GCC versions lacking c++11 support

cuckoo4:	cuckoo.h cuckoo_miner.h simple_miner.cpp Makefile
	$(GPP) -o cuckoo4 -DSHOW -DIDXSHIFT=0 -DPROOFSIZE=6 -DSIZESHIFT=4 simple_miner.cpp $(LIBS)

cuckoo:		cuckoo.h cuckoo_miner.h cuckoo_miner.cpp Makefile
	$(GPP) -o cuckoo -g -DSHOW -DLOGNBUCKETS=0 -DIDXSHIFT=0 -DPROOFSIZE=6 -DSIZESHIFT=4 cuckoo_miner.cpp $(LIBS)

example:	cuckoo4
	./cuckoo4 -e 66 -h 39

cuckoo10:	cuckoo.h cuckoo_miner.h cuckoo_miner.cpp Makefile
	$(GPP) -o cuckoo10 -DSIZESHIFT=10 cuckoo_miner.cpp $(LIBS)

cuckoo15:	cuckoo.h cuckoo_miner.h cuckoo_miner.cpp Makefile
	$(GPP) -o cuckoo15 -DSIZESHIFT=15 cuckoo_miner.cpp $(LIBS)

cuckoo20:	cuckoo.h cuckoo_miner.h cuckoo_miner.cpp Makefile
	$(GPP) -o cuckoo20 -DSIZESHIFT=20 cuckoo_miner.cpp $(LIBS)

cuckoo20.1:	cuckoo.h cuckoo_miner.h cuckoo_miner.cpp Makefile
	$(GPP) -o cuckoo20.1 -DPART_BITS=1 -DSIZESHIFT=20 cuckoo_miner.cpp $(LIBS)

verify20:	cuckoo.h cuckoo.c Makefile
	$(CC) -o verify20 -DSIZESHIFT=20 cuckoo.c $(LIBS)

test:	cuckoo20 verify20 Makefile
	./cuckoo20 -h 85 | tail -1 | ./verify20 -h 85

cuckoo25:	cuckoo.h cuckoo_miner.h cuckoo_miner.cpp Makefile
	$(GPP) -o cuckoo25 -DSIZESHIFT=25 cuckoo_miner.cpp $(LIBS)

cuckoo25.1:	cuckoo.h cuckoo_miner.h cuckoo_miner.cpp Makefile
	$(GPP) -o cuckoo25.1 -DPART_BITS=1 -DSIZESHIFT=25 cuckoo_miner.cpp $(LIBS)

cuckoo28:	cuckoo.h cuckoo_miner.h cuckoo_miner.cpp Makefile
	$(GPP) -o cuckoo28 -DSIZESHIFT=28 cuckoo_miner.cpp $(LIBS)

cuckoo28.1:	cuckoo.h cuckoo_miner.h cuckoo_miner.cpp Makefile
	$(GPP) -o cuckoo28.1 -DPART_BITS=1 -DSIZESHIFT=28 cuckoo_miner.cpp $(LIBS)

speedup:	cuckoo28 Makefile
	for i in {1..4}; do echo $$i; (time for j in {0..6}; do ./cuckoo28 -t $$i -h $$j; done) 2>&1; done > speedup

cuckoo30:	cuckoo.h cuckoo_miner.h cuckoo_miner.cpp Makefile
	$(GPP) -o cuckoo30 -DSIZESHIFT=30 cuckoo_miner.cpp $(LIBS)

cuckoo30.1:	cuckoo.h cuckoo_miner.h cuckoo_miner.cpp Makefile
	$(GPP) -o cuckoo30.1 -DPART_BITS=1 -DSIZESHIFT=30 cuckoo_miner.cpp $(LIBS)

cuckoo30.2:	cuckoo.h cuckoo_miner.h cuckoo_miner.cpp Makefile
	$(GPP) -o cuckoo30.2 -DPART_BITS=2 -DSIZESHIFT=30 cuckoo_miner.cpp $(LIBS)

cuckoo30.3:	cuckoo.h cuckoo_miner.h cuckoo_miner.cpp Makefile
	$(GPP) -o cuckoo30.3 -DPART_BITS=3 -DSIZESHIFT=30 cuckoo_miner.cpp $(LIBS)

speedup30:	cuckoo30 Makefile
	for i in {1..4}; do echo $$i; (time for j in {0..9}; do ./cuckoo30 -t $$i -h $$j; done) 2>&1; done > speedup30

bounty28:	cuckoo.h bounty_miner.h bounty_miner.cpp Makefile
	$(GPP) -o bounty28 -DSIZESHIFT=28 bounty_miner.cpp $(LIBS)

bounty30:	cuckoo.h bounty_miner.h bounty_miner.cpp Makefile
	$(GPP) -o bounty30 -DSIZESHIFT=30 bounty_miner.cpp $(LIBS)

bounty32:	cuckoo.h bounty_miner.h bounty_miner.cpp Makefile
	$(GPP) -o bounty32 -DSIZESHIFT=32 bounty_miner.cpp $(LIBS)

cuda28:	cuda_miner.cu Makefile
	nvcc -o cuda28 -DSIZESHIFT=28 -arch sm_20 cuda_miner.cu -lssl -lcrypto 

cuda30:	cuda_miner.cu Makefile
	nvcc -o cuda30 -DSIZESHIFT=30 -arch sm_20 cuda_miner.cu -lssl -lcrypto

cuda32:	cuda_miner.cu Makefile
	nvcc -o cuda32 -DSIZESHIFT=32 -arch sm_20 cuda_miner.cu -lssl -lcrypto

cpubounty:	cuckoo28 bounty28 cuckoo30 bounty30 cuckoo32 bounty32 Makefile
	for c in 28 30 32; do for t in 1 2 4 8; do time for h in {0..9}; do ./cuckoo$$c -t $$t -h $$h; done; time for h in {0..9}; do ./bounty$$c -t $$t -h $$h; done;done; done

gpubounty:	cuckoo28 cuda28 cuckoo30 cuda30 cuckoo32 cuda32 Makefile
	for c in 28 30 32; do time for h in {0..9}; do ./cuckoo$$c -t 16 -h $$h; done; time for h in {0..9}; do ./cuda$$c -h $$h; done; done

speedup30.1:	cuckoo30.1 Makefile
	for i in {1..4}; do echo $$i; (time for j in {0..9}; do ./cuckoo30.1 -t $$i -h $$j; done) 2>&1; done > speedup30.1

speedup30.2:	cuckoo30.2 Makefile
	for i in {1..4}; do echo $$i; (time for j in {0..9}; do ./cuckoo30.2 -t $$i -h $$j; done) 2>&1; done > speedup30.2

speedup30.3:	cuckoo30.3 Makefile
	for i in {1..4}; do echo $$i; (time for j in {0..9}; do ./cuckoo30.3 -t $$i -h $$j; done) 2>&1; done > speedup30.3

cuckoo32:	cuckoo.h cuckoo_miner.h cuckoo_miner.cpp Makefile
	$(GPP) -o cuckoo32 -DSIZESHIFT=32 cuckoo_miner.cpp $(LIBS)

cuckoo32.1:	cuckoo.h cuckoo_miner.h cuckoo_miner.cpp Makefile
	$(GPP) -o cuckoo32.1 -DPART_BITS=1 -DSIZESHIFT=32 cuckoo_miner.cpp $(LIBS)

cuckoo32.2:	cuckoo.h cuckoo_miner.h cuckoo_miner.cpp Makefile
	$(GPP) -o cuckoo32.2 -DPART_BITS=2 -DSIZESHIFT=32 cuckoo_miner.cpp $(LIBS)

verify32:	cuckoo.h cuckoo.c Makefile
	$(CC) -o verify32 -DSIZESHIFT=32 cuckoo.c $(LIBS)

Cuckoo.class:	Cuckoo.java Makefile
	javac -O Cuckoo.java

SimpleMiner.class:	Cuckoo.java SimpleMiner.java Makefile
	javac -O Cuckoo.java SimpleMiner.java

java:	Cuckoo.class SimpleMiner.class Makefile
	java SimpleMiner -h 85 | tail -1 | java Cuckoo -h 85

cuda:	cuda_miner.cu Makefile
	nvcc -o cuda -DSIZESHIFT=14 -arch sm_20 cuda_miner.cu -lssl -lcrypto

runcuda:	cuda
	./cuda -h header

speedupcuda:	cuda28
	for i in 1 2 4 8 16 32 64 128 256 512; do echo $$i; (time for j in {0..6}; do ./cuda28 -t $$i -h $$j; done) 2>&1; done > speedupcuda

tar:	cuckoo.h cuckoo_miner.h cuckoo_miner.cpp osx_barrier.h simple_miner.cpp Makefile
	tar -cf cuckoo.tar cuckoo.h cuckoo_miner.h cuckoo_miner.cpp osx_barrier.h simple_miner.cpp Makefile
