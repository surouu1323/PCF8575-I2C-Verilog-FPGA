
TB_NAME  	?= tb
TESTNAME 	?= test
RADIX       ?= hexadecimal
RTL_FILES := $(filter-out %_copy.v %_old.v %_dis.v, $(wildcard ../src/*.v))
LOCATE ?= ..
COV_DIR = cov
LOG_DIR = log
VCD_DIR = vcd
#=================

# ========= BUILD & RUN =========
all: build run

all_wave:
	$(MAKE) build DEFINE=WAVE
	$(MAKE) run
	$(MAKE) wave

all_dec:
	$(MAKE) build DEFINE=DEC
	$(MAKE) run
	$(MAKE) dec

build:
	iverilog -g2012 $(if $(DEFINE),-D$(DEFINE)) -o ./$(TB_NAME).vcd ../tb/$(TB_NAME).v $(RTL_FILES)

run:
	vvp -l ./$(TESTNAME).log ./$(TB_NAME).vcd

wave:
	gtkwave ./dump.vcd

dec:
	"C:\Program Files\sigrok\PulseView\pulseview.exe" --clean --settings ./session.pvs --input-file ./dump_dec.vcd 

check:
	verilator --lint-only -f rtl.f
#	verilator --lint-only $(RTL_FILES)

clean:
	if exist .\vcd rmdir /s /q .\vcd
	if exist .\log rmdir /s /q .\log
	if exist .\vcd\*.vcd del /q .\vcd\*.vcd
	if exist *.vcd del /q *.vcd
	if exist *.log del /q *.log
	if exist *.ini del /q *.inis
	if exist *.wlf del /q *.wlf
	if exist transcript del /q transcript
	if exist $(COV_DIR)\*.ucdb del /q $(COV_DIR)\*.ucdb
	if exist $(COV_DIR)\work rmdir /s /q $(COV_DIR)\work



$(COV_DIR):
	if not exist $(COV_DIR) mkdir $(COV_DIR)

$(LOG_DIR):
	if not exist $(LOG_DIR) mkdir $(LOG_DIR)

$(VCD_DIR):
	if not exist $(VCD_DIR) mkdir $(VCD_DIR)
