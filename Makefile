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

ifeq (,$(TOP))
$(warning TOP not defined, using asig_5p0)
TOP=asig_5p0
endif

CELL_DIR=$(abspath ./globalfoundries-pdk-libs-gf180mcu_fd_io/cells)

TOP_DIR:=$(abspath $(dir $(CELL_DIR)/$(TOP)))/$(TOP)
ifeq (,$(wildcard $(TOP_DIR)))
$(error directory $(TOP_DIR) don't exist)
endif

PEX_DIR=$(abspath ./pex)
ifeq (,$(wildcard $(PEX_DIR)))
$(shell mkdir -p $(PEX_DIR))
endif

LOGDIR=$(abspath logs)/$(TIMESTAMP_DAY)
ifeq (,$(wildcard $(LOGDIR)))
$(shell mkdir -p $(LOGDIR))
endif

# TODO: Are we catching stderr into log files?


TIMESTAMP_DAY=$$(date +%Y-%m-%d)
TIMESTAMP_TIME=$$(date +%H-%M-%S)


# Getting source file
#####################

## 1. Get all files ##

ALL_FILES:=$(wildcard $(CELL_DIR)/*) \
		   $(wildcard $(CELL_DIR)/asig_5p0/*) \
		   $(wildcard $(CELL_DIR)/bi_24t/*) \
		   $(wildcard $(CELL_DIR)/bi_t/*) \
		   $(wildcard $(CELL_DIR)/brk2/*) \
		   $(wildcard $(CELL_DIR)/brk5/*) \
		   $(wildcard $(CELL_DIR)/cor/*) \
		   $(wildcard $(CELL_DIR)/dvdd/*) \
		   $(wildcard $(CELL_DIR)/dvss/*) \
		   $(wildcard $(CELL_DIR)/fill1/*) \
		   $(wildcard $(CELL_DIR)/fill10/*) \
		   $(wildcard $(CELL_DIR)/fill5/*) \
		   $(wildcard $(CELL_DIR)/fillnc/*) \
		   $(wildcard $(CELL_DIR)/in_c/*) \
		   $(wildcard $(CELL_DIR)/in_s/*) \
		   $(wildcard $(PEX_DIR)/*)

## 2. Filter by type #

ALL_SCH:=$(filter %.sch,$(ALL_FILES))

ALL_LAYOUT:=$(filter %5lm.gds,$(ALL_FILES))

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

TOP_SCH:=$(filter %$(TOP).sch,$(SCH))

TOP_TB:=$(filter %$(TOP)-test.sch,$(TB))

TOP_GDS:=$(filter %$(TOP)_5lm.gds,$(GDS))

TOP_PEX:=$(filter %$(TOP).pex,$(PEX))
TOP_PEX_SYM:=$(filter %$(TOP)_flat.sym,$(SYM))

TOP_NETLIST_SCH:=$(filter %$(TOP).cdl,$(ALL_NETLIST))
TOP_NETLIST_GDS:=$(filter %$(TOP)_5lm.cir,$(ALL_NETLIST))


# Relevant directories
#################

MAGIC_LOG=$(LOGDIR)/$(TIMESTAMP_TIME)-magic-$(TOP).log
XSCHEM_LOG=$(LOGDIR)/$(TIMESTAMP_TIME)-xschem-$(TOP).log
NETGEN_LOG=$(LOGDIR)/$(TIMESTAMP_TIME)-netgen-$(TOP).log
KLAYOUT_LOG=$(LOGDIR)/$(TIMESTAMP_TIME)-klayout-$(TOP).log

MAGIC_LVS_LOG=$(LOGDIR)/$(TIMESTAMP_TIME)-magic-lvs-$(TOP).log
MAGIC_PEX_LOG=$(LOGDIR)/$(TIMESTAMP_TIME)-magic-pex-$(TOP).log
XSCHEM_LVS_LOG=$(LOGDIR)/$(TIMESTAMP_TIME)-xschem-lvs-$(TOP).log
KLAYOUT_LVS_LOG=$(LOGDIR)/$(TIMESTAMP_TIME)-klayout-lvs-$(TOP).log

# Configuration files
#####################

#XSCHEM_RCFILE=$(PDK_ROOT)/$(PDK)/libs.tech/xschem/xschemrc
XSCHEM_RCFILE=$(realpath ./xschemrc)

MAGIC_RCFILE=$(realpath ./magicrc)
MAGIC_LVS=$(realpath scripts/magic_lvs.tcl)
MAGIC_PEX=$(realpath scripts/magic_pex.tcl)

NETGEN_RCFILE=$(PDK_ROOT)/$(PDK)/libs.tech/netgen/setup.tcl


# Program Aliases
#################

GREP=grep --color=auto
RM=rm -rf

# https://xschem.sourceforge.io/stefan/xschem_man/developer_info.html
#--preinit 'set lvs_netlist 1; set spiceprefix 0'
XSCHEM=xschem --rcfile $(XSCHEM_RCFILE)
XSCHEM_NETLIST=xschem --rcfile ./xschemrc \
	--netlist \
	--netlist_path $(TOP_DIR) \
	--netlist_filename $(TOP).spice \
	--preinit 'set lvs_netlist 1' \
	--no_x \
	--quit

XSCHEM_NETLIST_WITHOUT_SPICEPREFIX=xschem --rcfile ./xschemrc \
	--netlist \
	--netlist_path $(TOP_DIR) \
	--netlist_filename $(TOP).spice \
	--preinit 'set lvs_netlist 1; set spiceprefix 0' \
	--no_x \
	--quit

KLAYOUT=klayout -t -d 1

MAGIC=PEX_DIR=$(PEX_DIR) LAYOUT=$(TOP_GDS) TOP=gf180mcu_fd_io__$(TOP) magic -rcfile $(MAGIC_RCFILE) -noconsole
MAGIC_BATCH=$(MAGIC) -nowrapper -nowindow -D -dnull

NETGEN=netgen -batch lvs

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
 	print-TOP_NETLIST_SCH \
	print-TOP_NETLIST_GDS


#########
## Xschem
#########


.PHONY:xschem
xschem:
	$(XSCHEM) $(TOP_SCH)


.PHONY: xschem-sch
xschem-sch:
	$(XSCHEM) $(TOP_SCH) |& tee $(XSCHEM_LOG)


.PHONY: xschem-tb
xschem-tb:
	$(XSCHEM) $(TOP_TB) |& tee $(XSCHEM_LOG)


.PHONY: xschem-lvs
xschem-lvs:
	$(XSCHEM_NETLIST) $(TOP_SCH) |& tee $(XSCHEM_LVS_LOG)


.PHONY: xschem-lvs-klayout-compatible
xschem-lvs-klayout-compatible:
	$(XSCHEM_NETLIST_WITHOUT_SPICEPREFIX) $(TOP_SCH) |& tee $(XSCHEM_LVS_LOG)
	sed -i '/C.*cap_mim_2f0_m4m5_noshield/s/c_width/W/' $(TOP_DIR)/$(TOP).spice
	sed -i '/C.*cap_mim_2f0_m4m5_noshield/s/c_length/L/' $(TOP_DIR)/$(TOP).spice
	sed -i '/R.*ppoly/s/r_width/W/' $(TOP_DIR)/$(TOP).spice
	sed -i '/R.*ppoly/s/r_length/L/' $(TOP_DIR)/$(TOP).spice


.PHONY: xschem-make-sym
xschem-make-sym:
	python scripts/gen_sym.py $(TOP_PEX) $(PEX_DIR)
	#$(XSCHEM) $(TOP_PEX_SYM)


##########
## Klayout
##########

# TODO: This rules are not verified
# TODO: Klayout DRC
# TODO: Klayout LVS

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
	$(RM) $(TOP_DIR)/*.lyrdb

	python $(KLAYOUT_HOME)/drc/run_drc.py \
		--path $(TOP_GDS) \
		--variant=D \
		--topcell=gf180mcu_fd_io__$(TOP) \
		--run_dir=$(TOP_DIR) \
		--run_mode=flat \
		--antenna \
		--density \
		--verbose || true

	$(KLAYOUT) -b -r $(KLAYOUT_HOME)/drc/gf180mcuD_mr.drc \
		-rd input=$(TOP_GDS) \
		-rd topcell=gf180mcu_fd_io__$(TOP) \
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
		-rd beol=true || true


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
	cd $(TOP_DIR) && $(MAGIC_BATCH) $(MAGIC_LVS) |& tee $(MAGIC_LVS_LOG)


.PHONY: magic-pex
magic-pex:
	cd $(TOP_DIR) && $(MAGIC_BATCH) $(MAGIC_PEX) |& tee $(MAGIC_PEX_LOG)
	make TOP=$(TOP) xschem-make-sym


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


#########
## Netgen
#########

.PHONY: netgen-lvs
netgen-lvs: magic-lvs xschem-lvs
	cd $(TOP_DIR) && $(NETGEN) "$(notdir $(TOP_NETLIST_GDS)) $(TOP)" "$(notdir $(TOP_NETLIST_SCH)) $(TOP)" $(NETGEN_RCFILE) |& tee $(NETGEN_LOG) || true
	cd $(TOP_DIR) && grep "Netlist" comp.out


.PHONY: netgen-magic-lvs
netgen-magic-lvs: magic-lvs xschem-lvs
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
