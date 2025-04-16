
PROJ_NAME=cartridge

AS        = dasm
AS_SRC    = $(PROJ_NAME).asm
AS_FLAGS  = -o$(OBJ)	# Output file name
AS_FLAGS += -f3			# Output format (raw). Othewise the origin address ($8000) is appended to the output file

OBJ=$(subst .asm,.out,$(AS_SRC))
CRT=$(subst .asm,.crt,$(AS_SRC))

EMULATOR       = x64sc
EMULATOR_FALGS = -cartcrt build/$(CRT)

# For coloring echo
GREEN := \033[0;32m
COL_RESET := \033[0m

all: clean crt
	@echo "$(GREEN)Moving artifacts to build directory...$(COL_RESET)"
	mv *.crt build
	mv *.out build

crt: obj
	@echo "$(GREEN)Converting to crt...$(COL_RESET)"
	cartconv -t normal -n "$(PROJ_NAME)" -i $(OBJ) -o $(PROJ_NAME).crt

obj:
	@echo "$(GREEN)Compiling asm...$(COL_RESET)"
	$(AS) $(AS_SRC) $(AS_FLAGS)

run: all
	$(EMULATOR) $(EMULATOR_FALGS)

clean:
	rm build/*

.SILENT: all
