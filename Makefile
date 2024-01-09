# User parameters
#################

# SEE THIS: https://www.gnu.org/software/make/manual/html_node/index.html#SEC_Contents

PDK=gf180mcuD

# TOP is a directory that contains relevant files that share the same name.
# - TOP/TOP.sch
# - TOP/TOP.sym
# - TOP/TOP-test.sch
# - TOP/TOP.gds
TOP=


# Utility variables
###################

TIMESTAMP_DAY=$$(date +%Y-%m-%d)
TIMESTAMP_TIME=$$(date +%H-%M-%S)
NPROCS:=$(shell grep -c ^processor /proc/cpuinfo)

ifeq (,$(TOP))
$(warning TOP not defined, using asig_5p0)
TOP=asig_5p0
endif

CELL_DIR=$(abspath ./globalfoundries-pdk-libs-gf180mcu_fd_io/cells)
PADRING_DIR=$(abspath ./openfasoc-tapeouts/gf180mcu_padframe)

# Klayout analysis are done in the GDS directory, inside gf*_fd_io folder.
TOP_DIR:=$(realpath $(CELL_DIR)/$(TOP))
ifeq (,$(TOP_DIR))
$(warning TOP_DIR variable can't be determined)
endif

PEX_DIR=$(abspath ./pex)
ifeq (,$(wildcard $(PEX_DIR)))
$(shell mkdir -p $(PEX_DIR))
endif

LVS_DIR=$(abspath ./lvs)
ifeq (,$(wildcard $(LVS_DIR)))
$(shell mkdir -p $(LVS_DIR))
endif

LOGDIR=$(abspath logs)/$(TIMESTAMP_DAY)
ifeq (,$(wildcard $(LOGDIR)))
$(shell mkdir -p $(LOGDIR))
endif

# TODO: Are we catching stderr into log files?



# Getting source file
#####################

## 1. Get all files ##

ALL_FILES:=$(wildcard $(CELL_DIR)/*) \
		   $(wildcard $(CELL_DIR)/*/*) \
		   $(wildcard $(PEX_DIR)/*) \
		   $(wildcard $(LVS_DIR)/*) \
		   $(wildcard test/*/*) \
		   $(wildcard /*) \
		   $(wildcard $(PADRING_DIR)/*) \
		   $(wildcard $(PADRING_DIR)/tb/*) \

## 2. Filter by type #

ALL_SCH:=$(filter %.sch,$(ALL_FILES))

ALL_LAYOUT:=$(filter %.gds,$(ALL_FILES))

ALL_NETLIST:= \
	$(filter %.spice,$(ALL_FILES)) \
	$(filter %.cdl,$(ALL_FILES)) \
	$(filter %.cir,$(ALL_FILES))


## 3. Filter by subtype ##

# Schematics
SCH:=$(filter-out %-test.sch,$(ALL_SCH))
SYM:=$(filter %.sym,$(ALL_FILES))

# Testbenches
TB:=$(filter %-test.sch,$(ALL_SCH))

# Parasitix extraction (pex)
PEX:=$(filter %.pex,$(ALL_FILES))

# Layout (gds)
GDS:=$(filter %.gds,$(ALL_LAYOUT))

# Garbage
CLEANABLE:= \
	$(filter %.log,$(ALL_FILES)) \
	$(filter %comp.out,$(ALL_FILES)) \
	$(filter %.ext,$(ALL_FILES)) \
	$(filter %.sim,$(ALL_FILES)) \
	$(filter %.nodes,$(ALL_FILES)) \
	$(filter %.drc,$(ALL_FILES))
# $(filter %.lyrdb,$(ALL_FILES))
# $(filter %.lvsdb,$(ALL_FILES))

## 3. Files related with the TOP

TOP_SCH:=$(realpath $(filter %$(TOP).sch,$(SCH)))

TOP_TB:=$(realpath $(filter %$(TOP)-test.sch,$(TB)))

TOP_GDS:=$(realpath $(filter %$(TOP)_5lm.gds,$(GDS)))
ifeq (, $(TOP_GDS))
TOP_GDS=$(realpath $(filter %$(TOP).gds,$(GDS)))
endif


TOP_PEX:=$(realpath $(filter %$(TOP).pex,$(PEX)))
TOP_PEX_SYM:=$(realpath $(filter %$(TOP)_flat.sym,$(SYM)))

#TOP_NETLIST_SCH:=$(filter %$(TOP).cdl,$(ALL_NETLIST))
# TOP_NETLIST_SCH have to meanings depending of what is TOP referencing:
# TOP references a IO GDS: TOP_NETLIST_SCH has no meaning because we don't make lvs in this repo
# TOP references a test: TOP_NETLIST_SCH references a tesbench netlist
TOP_NETLIST_SCH:=$(realpath $(filter %$(TOP).spice,$(ALL_NETLIST)))
TOP_NETLIST_GDS:=$(realpath $(filter %$(TOP).cir,$(ALL_NETLIST))) ## Add the _5lm into this name
TOP_NETLIST_PEX:=$(realpath $(filter %$(TOP).pex,$(ALL_NETLIST)))
TOP_NETLIST_PEX_SYM:=$(realpath $(filter %$(TOP)_flat.sym,$(SYM)))


# Relevant directories
#################

MAGIC_LOG=$(LOGDIR)/$(TIMESTAMP_TIME)-magic-$(TOP).log
MAGIC_LVS_LOG=$(LOGDIR)/$(TIMESTAMP_TIME)-magic-lvs-$(TOP).log
MAGIC_PEX_LOG=$(LOGDIR)/$(TIMESTAMP_TIME)-magic-pex-$(TOP).log

XSCHEM_LOG=$(LOGDIR)/$(TIMESTAMP_TIME)-xschem-$(TOP).log
XSCHEM_NETLIST_LOG=$(LOGDIR)/$(TIMESTAMP_TIME)-xschem-netlist-$(TOP).log

NGSPICE_LOG=$(LOGDIR)/$(TIMESTAMP_TIME)-ngspice-$(TOP).log

NETGEN_LOG=$(LOGDIR)/$(TIMESTAMP_TIME)-netgen-$(TOP).log

KLAYOUT_LOG=$(LOGDIR)/$(TIMESTAMP_TIME)-klayout-$(TOP).log
KLAYOUT_LVS_LOG=$(LOGDIR)/$(TIMESTAMP_TIME)-klayout-lvs-$(TOP).log
KLAYOUT_DRC_LOG=$(LOGDIR)/$(TIMESTAMP_TIME)-klayout-drc_$(TOP).log


# Configuration files
#####################

#XSCHEM_RCFILE=$(PDK_ROOT)/$(PDK)/libs.tech/xschem/xschemrc
XSCHEM_RCFILE=$(realpath ./xschemrc)

MAGIC_RCFILE=$(realpath ./magicrc)
MAGIC_LVS_SCRIPT=$(realpath scripts/magic_lvs.tcl)
MAGIC_PEX_SCRIPT=$(realpath scripts/magic_pex.tcl)

NETGEN_RCFILE=$(PDK_ROOT)/$(PDK)/libs.tech/netgen/setup.tcl


# Program Aliases
#################

GREP=grep --color=auto
RM=rm -rf

# https://xschem.sourceforge.io/stefan/xschem_man/developer_info.html
#--preinit 'set lvs_netlist 1; set spiceprefix 0'
XSCHEM=xschem --rcfile $(XSCHEM_RCFILE) \
	--netlist \
	--netlist_path $(dir $(TOP_SCH)) \
	--netlist_filename $(TOP).spice

XSCHEM_BATCH=$(XSCHEM) \
	--no_x \
	--quit

KLAYOUT=klayout -t -d 1

MAGIC=PEX_DIR=$(PEX_DIR) LVS_DIR=$(LVS_DIR) LAYOUT=$(TOP_GDS) TOP=gf180mcu_fd_io__$(TOP) magic -rcfile $(MAGIC_RCFILE) -noconsole
MAGIC_BATCH=$(MAGIC) -nowrapper -nowindow -D -dnull

NETGEN=netgen -batch lvs

NGSPICE=SPICE_USERINIT_DIR=$(PWD) ngspice -a --define=num_threads=$(NPROCS)

############
## Utilities
############

all: xschem


.PHONY: clean
clean:
	$(RM) $(CLEANABLE)


# https://www.cmcrossroads.com/article/printing-value-makefile-variable
# https://stackoverflow.com/questions/16467718/how-to-print-out-a-variable-in-makefile
print-% : ; $(info $*: $(flavor $*) variable - $($*)) @true


.PHONY: print-vars
print-vars : \
	print-TOP \
	print-TOP_DIR \
	print-TOP_SCH \
	print-TOP_TB \
	print-TOP_GDS \
	print-TOP_PEX \
 	print-TOP_NETLIST_SCH \
	print-TOP_NETLIST_GDS \
	print-TOP_NETLIST_PEX


.PHONY: gen-sym
gen-sym:
	python scripts/gen_sym.py $(TOP_PEX) $(PEX_DIR)
	#$(XSCHEM) $(TOP_PEX_SYM)


.PHONY: gen-lvs-sym
gen-lvs-sym:
	python scripts/gen_sym.py $(TOP_NETLIST_GDS) $(LVS_DIR)
	#$(XSCHEM) $(TOP_PEX_SYM)


#########
## Xschem
#########


.PHONY: xschem
xschem:
	$(XSCHEM) $(TOP_SCH) |& tee $(XSCHEM_LOG)


.PHONY: xschem-netlist
xschem-netlist:
	$(XSCHEM_BATCH) $(TOP_SCH) |& tee $(XSCHEM_LVS_LOG)


.PHONY: xschem-netlist-lvs
xschem-netlist-lvs:
	$(XSCHEM_BATCH) \
		--preinit 'set lvs_netlist 1' \
		$(TOP_SCH) |& tee $(XSCHEM_LVS_LOG)


.PHONY: xschem-netlist-lvs-klayout
xschem-netlist-lvs-klayout:
	$(XSCHEM_BATCH) \
		--preinit 'set lvs_netlist 1; set spiceprefix 0' \
		$(TOP_SCH) |& tee $(XSCHEM_LVS_LOG)

	make TOP=$(TOP) xschem-netlist-lvs-klayout-clean

.PHONY: xschem-netlist-lvs-klayout-clean
xschem-netlist-lvs-klayout-clean:
	sed -i '/C.*cap_mim_2f0_m4m5_noshield/s/c_width/W/' $(TOP_NETLIST_SCH)
	sed -i '/C.*cap_mim_2f0_m4m5_noshield/s/c_length/L/' $(TOP_NETLIST_SCH)
	sed -i '/R.*ppoly/s/r_width/W/' $(TOP_NETLIST_SCH)
	sed -i '/R.*ppoly/s/r_length/L/' $(TOP_NETLIST_SCH)


##########
## Ngspice
##########

.PHONY: ngspice-sim
ngspice-sim: xschem-netlist
	cd $(dir $(TOP_SCH)) && $(NGSPICE) $(TOP_NETLIST_SCH) |& tee $(NGSPICE_LOG)


##########
## Klayout
##########


.PHONY: klayout
klayout: klayout-view


.PHONY: klayout-view
klayout-view:
	$(KLAYOUT) -ne $(TOP_GDS) |& tee $(KLAYOUT_LOG)


.PHONY: klayout-edit
klayout-edit:
	$(KLAYOUT) -e $(TOP_GDS) |& tee $(KLAYOUT_LOG)


# KLAYOUT LVS
#############
# --help -h                           Print this help message.
# --layout=<layout_path>              The input GDS file path.
# --netlist=<netlist_path>            The input netlist file path.
# --variant=<combined_options>        Select combined options of metal_top, mim_option, and metal_level. Allowed values (A, B, C, D).
# --thr=<thr>                         The number of threads used in run.
# --run_dir=<run_dir_path>            Run directory to save all the results [default: pwd]
# --topcell=<topcell_name>            Topcell name to use.
# --run_mode=<run_mode>               Select klayout mode Allowed modes (flat , deep, tiling). [default: deep]
# --lvs_sub=<sub_name>                Substrate name used in your design.
# --verbose                           Detailed rule execution log for debugging.
# --schematic_simplify                Enable schematic simplification in input netlist.

## Operations in extracted netlist
# --no_net_names                      In extracted netlist Discard net names.
# --spice_comments                    In extracted netlist Enable netlist comments.
# --scale                             In extracted netlist Enable scale of 1e6.
# --net_only                          In extracted netlist Enable netlist object creation only.
# --top_lvl_pins                      In extracted netlist Enable top level pins only.
# --combine                           In extracted netlist Enable netlist combine only.
# --purge                             In extracted netlist Enable netlist purge all only.
# --purge_nets                        In extracted netlist Enable netlist purge nets only.

.PHONY: klayout-lvs-help
klayout-lvs-help:
	python $(KLAYOUT_HOME)/lvs/run_lvs.py --help


.PHONY: klayout-lvs-view
klayout-lvs-view:
	$(KLAYOUT) -e $(TOP_GDS) \
		-mn $(TOP_DIR)/$(TOP).lvsdb


.PHONY: klayout-lvs-only
klayout-lvs-only:
	python $(KLAYOUT_HOME)/lvs/run_lvs.py \
		--variant=D \
		--run_mode=flat \
		--verbose \
		--run_dir=$(TOP_DIR) \
		--layout=$(TOP_GDS) \
		--netlist=$(TOP_NETLIST_SCH) \
		--top_lvl_pins \
		--combine || true


# .PHONY: klayout-lvs-cir
# klayout-lvs-cir:
# 	python $(KLAYOUT_HOME)/lvs/run_lvs.py \
# 		--variant=D \
# 		--run_mode=flat \
# 		--verbose \
# 		--run_dir=$(TOP_DIR) \
# 		--layout=$(TOP_GDS) \
# 		--netlist=$(TOP_PEX) \
# 		--top_lvl_pins \
# 		--combine \
# 		--net_only || true


.PHONY: klayout-lvs
klayout-lvs: klayout-lvs-only
	make TOP=$(TOP) klayout-lvs-view


.PHONY: klayout-drc-view
klayout-drc-view:
	$(KLAYOUT) -e $(TOP_GDS) \
		-m $(TOP_DIR)/gf180mcu_fd_io__$(TOP)_5lm_antenna.lyrdb \
		-m $(TOP_DIR)/gf180mcu_fd_io__$(TOP)_5lm_density.lyrdb \
		-m $(TOP_DIR)/gf180mcu_fd_io__$(TOP)_5lm_main.lyrdb \
		-m $(TOP_DIR)/precheck_$(TOP).lyrdb


.PHONY: klayout-drc-only
klayout-drc-only:
	$(RM) $(dir $(TOP_DIR))/*.lyrdb

	python $(KLAYOUT_HOME)/drc/run_drc.py \
		--path $(TOP_GDS) \
		--variant=D \
		--topcell=$(basename $(notdir $(TOP_GDS))) \
		--run_dir=$(dir $(TOP_DIR)) \
		--run_mode=flat \
		--antenna \
		--density \
		--verbose || true |& tee $(KLAYOUT_DRC_LOG)

	$(KLAYOUT) -b -r $(KLAYOUT_HOME)/drc/gf180mcuD_mr.drc \
		-rd input=$(TOP_GDS) \
		-rd topcell=$(basename $(notdir $(TOP_GDS))) \
		-rd report=precheck_$(TOP).lyrdb \
		-rd conn_drc=true \
		-rd split_deep=true \
		-rd wedge=true \
		-rd ball=true \
		-rd gold=true \
		-rd mim_option=B \
		-rd offgrid=true \
		-rd verbose=true \
		-rd run_mode=flat \
		-rd feol=true \
		-rd beol=true || true |& tee $(KLAYOUT_DRC_LOG)


.PHONY: klayout-drc
klayout-drc: klayout-drc-only
	make TOP=$(TOP) klayout-drc-view


.PHONY: klayout-eval
klayout-eval: klayout-drc-only klayout-lvs-only


########
## Magic
########

# TODO: Magic DRC
# TODO: Do pex extraction include resistances?

.PHONY: magic
magic:
	$(MAGIC)


.PHONY: magic-edit
magic-edit:
	$(MAGIC) $(TOP_GDS) |& tee $(MAGIC_LOG)


# Working on the TOP_DIR for simplicity, maybe we can change a internal variable to write all there.
.PHONY: magic-lvs
magic-lvs:
	cd $(TOP_DIR) && $(MAGIC_BATCH) $(MAGIC_LVS_SCRIPT) |& tee $(MAGIC_LVS_LOG)
	make TOP=$(TOP) gen-lvs-sym


.PHONY: magic-pex
magic-pex:
	cd $(TOP_DIR) && $(MAGIC_BATCH) $(MAGIC_PEX_SCRIPT) |& tee $(MAGIC_PEX_LOG)
	make TOP=$(TOP) gen-sym


.PHONY: magic-pex-all
magic-pex-all:
	make TOP=asig_5p0 magic-pex
	make TOP=bi_t magic-pex
	make TOP=in_c magic-pex
	make TOP=dvdd magic-pex
	make TOP=dvss magic-pex
	# make TOP=in_s magic-pex
	# make TOP=bi_24t magic-pex
	# make TOP=brk2 magic-pex
	# make TOP=brk5 magic-pex
	# make TOP=cor magic-pex
	# make TOP=fill1 magic-pex
	# make TOP=fill10 magic-pex
	# make TOP=fill5 magic-pex
	# make TOP=fillnc magic-pex


.PHONY: magic-lvs-all
magic-lvs-all:
	make TOP=asig_5p0 magic-lvs
	make TOP=bi_t magic-lvs
	make TOP=in_c magic-lvs
	make TOP=dvdd magic-lvs
	make TOP=dvss magic-lvs
	# make TOP=in_s magic-lvs
	# make TOP=bi_24t magic-lvs
	# make TOP=brk2 magic-lvs
	# make TOP=brk5 magic-lvs
	# make TOP=cor magic-lvs
	# make TOP=fill1 magic-lvs
	# make TOP=fill10 magic-lvs
	# make TOP=fill5 magic-lvs
	# make TOP=fillnc magic-lvs

#########
## Netgen
#########

.PHONY: netgen-lvs
netgen-lvs: magic-lvs xschem-netlist
	cd $(TOP_DIR) && $(NETGEN) "$(notdir $(TOP_NETLIST_GDS)) $(TOP)" "$(notdir $(TOP_NETLIST_SCH)) $(TOP)" $(NETGEN_RCFILE) |& tee $(NETGEN_LOG) || true
	cd $(TOP_DIR) && grep "Netlist" comp.out


.PHONY: netgen-magic-lvs
netgen-magic-lvs: magic-lvs xschem-netlist
	cd $(TOP_DIR) && $(NETGEN) "$(notdir $(TOP_NETLIST_GDS)) $(TOP)_flat" "$(notdir $(TOP_NETLIST_SCH)) $(TOP)" $(NETGEN_RCFILE) |& tee $(NETGEN_LOG) || true
	cd $(TOP_DIR) && grep "Netlist" comp.out


##########
## Aliases
##########

# TODO: Alias for drc

.PHONY: lvs
lvs: netgen-lvs


.PHONY: pex
pex: magic-pex


#############
# Quick fixes
#############
