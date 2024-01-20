all: print-vars
include ./scripts/base.mk

# User parameters
#################

PDK=gf180mcuD
TOP=

TIMESTAMP_DAY=$$(date +%Y-%m-%d)
TIMESTAMP_TIME=$$(date +%H-%M-%S)

# TOP is a directory that contains relevant files that share the same name.
# - TOP/TOP.sch
# - TOP/TOP.sym
# - TOP/TOP-test.sch
# - TOP/TOP.gds

# Getting Files
###############

## 0. Enforce proposed structure

ifeq (,$(realpath ./extraction))
$(shell mkdir -p ./extraction/lvs)
$(shell mkdir -p ./extraction/pex)
$(call WARNING_MESSAGE, created ./extraction/ directory and subdirectories)
endif

ifeq (,$(realpath ./padring/))
$(shell mkdir -p ./padring/)
$(call WARNING_MESSAGE, created ./padring/ directory)
endif

$(foreach padring_dir,\
	$(wildcard ./padring/*),\
	$(shell mkdir -p $(padring_dir)/extraction/lvs) \
	$(shell mkdir -p $(padring_dir)/extraction/pex))

## 1. Get all files ##

define GET_INTERESTING_FILES
  $(filter-out %.v, \
    $(filter-out %.lef, \
      $(filter-out %.lib, \
        $(filter-out %.json, \
          $(wildcard $(1)/*) \
        )
      )
    )
  )
endef

ALL_FILES:= \
	$(foreach io_pad, \
		$(wildcard globalfoundries-pdk-libs-gf180mcu_fd_io/cells/*), \
		$(call GET_INTERESTING_FILES, $(io_pad)) \
  ) \
	$(foreach padring_design, \
		$(wildcard padring/*), \
		$(call GET_INTERESTING_FILES, $(padring_design)) \
  ) \
  $(foreach padring_extraction, \
		$(wildcard padring/*/extraction/*), \
		$(call GET_INTERESTING_FILES, $(padring_design)) \
  ) \
  $(foreach padring_design_test, \
		$(wildcard padring/*/*), \
    $(call GET_INTERESTING_FILES, $(padring_design_test)) \
  ) \
	$(foreach pad_test, \
		$(wildcard test/*), \
		$(call GET_INTERESTING_FILES, $(pad_test)) \
  )

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

#

ifeq (,$(TOP))
# NEVER define TOP in this section. Empty TOP is useful as an indicator
$(warning $(COLOR_YELLOW)TOP not defined, using default values$(COLOR_END))
TOP_SCH=0_top.sch
else
TOP_SCH:=$(realpath $(filter %/$(TOP).sch,$(SCH)))
TOP_SCH_DIR:=$(abspath $(dir $(TOP_SCH)))

TOP_GDS:=$(realpath $(filter %/$(TOP).gds,$(GDS)))
TOP_GDS_CELL:=$(basename $(notdir $(TOP_GDS)))

TOP_GDS_DIR:=$(abspath $(dir $(TOP_GDS)))

# Extracted from schematics (xschem)
TOP_NETLIST_SCH:=$(realpath $(filter %/$(TOP).spice,$(ALL_NETLIST)))
TOP_NETLIST_LVS_NOPREFIX:=$(TOP_SCH_DIR)/$(TOP)-noprefix.spice
TOP_NETLIST_LVS_PREFIX:=$(TOP_SCH_DIR)/$(TOP)-prefix.spice

# Extracted from layout
# (klayout)
TOP_EXTRACTED_KLAYOUT:=$(realpath $(filter %/$(TOP).cir,$(wildcard $(TOP_GDS_DIR)/*)))
# (magic)
TOP_EXTRACTED_MAGIC:=$(realpath $(filter %/$(TOP)-extracted.spice,$(wildcard $(TOP_GDS_DIR)/*)))
TOP_EXTRACTED_PEX:=$(realpath $(filter %/$(TOP)-pex.spice,$(wildcard $(TOP_GDS_DIR)/*)))

endif

# Relevant directories
##################

LOG_DIR=$(abspath logs)/$(TIMESTAMP_DAY)
ifeq (,$(wildcard $(LOG_DIR)))
$(shell mkdir -p $(LOG_DIR))
endif

XSCHEM_RCFILE=$(realpath ./xschemrc)

MAGIC_RCFILE=$(realpath ./magicrc)
MAGIC_LVS_SCRIPT=$(realpath ./scripts/magic_lvs.tcl)
MAGIC_PEX_SCRIPT=$(realpath ./scripts/magic_pex.tcl)

NETGEN_RCFILE=$(realpath $(PDK_ROOT)/$(PDK)/libs.tech/netgen/setup.tcl)

# Rules
#######

define HELP_ENTRIES +=
Restrictions
  This makefile is adapted to work with two repos:
  - gf io pads from efabless
  - padring from fasoc

  Every netlist and parasitics file extracted should be stored in the repo.
  We should be able to have many tests per io pad.
  We should be able to have many padrings and a test suite for all of them

  The project structure in this context is the following:

  ├── README.md
  ├── Makefile
  ├── scripts/
  ├── globalfoundries-pdk-libs-gf180mcu_fd_io/    pdk official stuff
  ├── openfasoc-tapeouts/                         Example padring and incompatible tests
  ├── extraction/
  │   ├── lvs/
  │   └── pex/
  ├── tests/
  │   ├── asig_5p0/
  │   │   ├── test_a/
  │   │   │   └── test_a.sch
  │   │   └── test_b/
  │   │       └── test_b.sch
  │   └── in_c/
  │       ├── test_a/
  │       │   └── test_a.sch
  │       └── ...
  └── padring/
      ├── padring_1/
      │   ├── padring_1.gds
      │   ├── extraction/
      │   │   ├── lvs/
      │   │   └── pex/
      │   ├── test_a/
      │   │   └── test_a.sch
      │   ├── test_b/
      │   │   └── test_a.sch
      ├── ...

Help message for Makefile
  to execute any command, the syntax is

    $$ make TOP=<component> <command>

  for example:

    $$ make TOP=resistor klayout-drc
    $$ make TOP=ldo-top xschem
	$$ make TOP=ldo-top print-TOP_GDS_DIR

  clean:          Removes intermediate files.
  print-%:        For every variable, prints it's value
  print-vars:     Shows some variable values
  help:           Shows this help
  xschem:         Alias for xschem-sch
  klayout:        Alias for klayout-edit
  magic:          Alias for magic-edit
  create-module:  Generates empty files that conforms a basic module

endef


include ./scripts/xschem.mk
include ./scripts/klayout.mk
include ./scripts/magic.mk
include ./scripts/netgen.mk
include ./scripts/ngspice.mk


.PHONY: help
help:
	$(call INFO_MESSAGE, $(HELP_ENTRIES))



.PHONY: clean
clean:
	$(RM) $(CLEANABLE)


# https://www.cmcrossroads.com/article/printing-value-makefile-variable
# https://stackoverflow.com/questions/16467718/how-to-print-out-a-variable-in-makefile
#print-% : ; $(info $*: $(flavor $*) variable - $($*)) @true
print-% : ; $(info $*: $(flavor $*) variable - $($*)) @true


.PHONY: print-vars
print-vars : \
	print-TOP \
	print-TOP_SCH \
  print-TOP_SCH_DIR \
	print-TOP_TB \
	print-TOP_GDS \
 	print-TOP_NETLIST_SCH \
	print-TOP_NETLIST_GDS \
	print-TOP_NETLIST_PEX


.PHONY: xschem
xschem: xschem-sch


.PHONY: klayout
klayout: klayout-edit


.PHONY: magic
magic: magic-edit


.PHONY: create-module
create-module:
ifeq (,$(TOP))
	$(call ERROR_MESSAGE, TOP not defined, couldn't create any design)
endif
	mkdir -p $(TOP)
ifneq (,$(wildcard $(TOP)/$(TOP).sch))
	$(call WARNING_MESSAGE, schematic already exists)
else
	xschem --rcfile $(XSCHEM_RCFILE) \
	--no_x \
	--quit \
	--command "xschem clear; xschem saveas $(TOP)/$(TOP).sch"
endif

ifneq (,$(wildcard $(TOP)/$(TOP)-tb.sch))
	$(call WARNING_MESSAGE, schematic testbench already exists)
else
	xschem --rcfile $(XSCHEM_RCFILE) \
	--no_x \
	--quit \
	--command "xschem clear; xschem saveas $(TOP)/$(TOP)-tb.sch"
endif

ifneq (,$(wildcard $(TOP)/$(TOP).gds))
	$(call WARNING_MESSAGE, layout already exists)
else
	klayout -t -e -zz -r ./scripts/empty-gds.py -rd filepath=$(TOP)/$(TOP).gds
endif