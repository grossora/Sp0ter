CXXFLAGS += -I. $(shell root-config --cflags) -g
LDFLAGS += $(shell root-config --libs) -g

CLASSES = SpaceChargeMicroBooNE
PROGRAMS = StudySCE , offset

spoter: clean clean2 $(CLASSES) offset 

all:		clean $(CLASSES) $(PROGRAMS) clean2

$(CLASSES):
	@echo '<<building' $@' object file>>'
	@$(CXX) -c $@.C -o $@.o $(CXXFLAGS) $(LDFLAGS)
	@rm -rf *.dSYM
$(PROGRAMS):
	@echo '<<compiling' $@'>>'
	@$(CXX) $@.cpp *.o -o $@ -I /usr/include/python2.7 $(CXXFLAGS) $(LDFLAGS)
	@rm -rf *.dSYM
clean:	
	rm -f $(PROGRAMS)
clean2:
	rm -f *.o
