all: $(O1) $(O2)
	echo $(BAKE_CPP_COMMAND) $(BAKE_CPP_FLAGS)
	echo $(BAKE_C_COMMAND) $(BAKE_C_FLAGS)
	echo $(BAKE_ASM_COMMAND) $(BAKE_ASM_FLAGS)
	echo $(BAKE_AR_COMMAND) $(BAKE_AR_FLAGS)
	echo $(BAKE_LD_COMMAND) $(BAKE_LD_FLAGS)
	echo DIR: $(lastword $(subst /, ,$(subst \\, ,$(CURDIR))))

clean:
	echo CleanIt
