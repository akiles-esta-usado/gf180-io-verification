# Files, directories and Aliases
################################

MAGIC_LOG=$(LOG_DIR)/$(TIMESTAMP_TIME)-magic-$(TOP).log
MAGIC_LVS_LOG=$(LOG_DIR)/$(TIMESTAMP_TIME)-magic-lvs-$(TOP).log
MAGIC_PEX_LOG=$(LOG_DIR)/$(TIMESTAMP_TIME)-magic-pex-$(TOP).log

LVS_DIR=$(EXTRACTION_DIR)/lvs
PEX_DIR=$(EXTRACTION_DIR)/pex

# layout =   $env(LAYOUT)
# cellname = $env(TOP)
# lvsdir =   $env(LVS_DIR)
# pexdir =   $env(PEX_DIR)
# cellname = $env(TOP_GDS_CELLNAME)

MAGIC=PEX_DIR=$(PEX_DIR) LVS_DIR=$(LVS_DIR) LAYOUT=$(TOP_GDS) TOP=$(TOP_GDS_CELLNAME) magic -rcfile $(MAGIC_RCFILE) -noconsole
MAGIC_BATCH=$(MAGIC) -nowrapper -nowindow -D -dnull

define HELP_ENTRIES +=

Magic related rules:
  magic-validation:  Evaluates relevant file existence. It's used by other rules.
  magic-edit:        Open $(TOP).gds on magic
  magic-lvs:         Extracts the netlist without parasitics
  magic-pex:         Extracts the netlist with resistive and capacitive parasitics

endef

# Rules
#######

.PHONY: magic-validation
magic-validation:
ifeq (,$(wildcard $(MAGIC_LVS_SCRIPT)))
	$(call ERROR_MESSAGE, [magic] There's no magic lvs script)
endif
ifeq (,$(wildcard $(MAGIC_PEX_SCRIPT)))
	$(call ERROR_MESSAGE, [magic] There's no magic pex script)
endif
ifeq (,$(wildcard $(TOP_GDS)))
	$(call ERROR_MESSAGE, [magic] GDS file $(TOP_GDS) doesn't exist$)
endif
	$(call INFO_MESSAGE, [magic] directory:         $(TOP_GDS_DIR))
	$(call INFO_MESSAGE, [magic] GDS:               $(TOP_GDS))
	$(call INFO_MESSAGE, [magic] extracted netlist: $(wildcard $(TOP_GDS_DIR)/$(TOP)-extracted.spice))
	$(call INFO_MESSAGE, [magic] extracted pex:     $(wildcard $(TOP_GDS_DIR)/$(TOP)-pex.spice))
	$(call INFO_MESSAGE, [magic] rcfile:            $(MAGIC_RCFILE))


.PHONY: magic-edit
magic-edit: magic-validation
	$(MAGIC) $(TOP_GDS) |& tee $(MAGIC_LOG)


# Working on the TOP_DIR for simplicity, maybe we can change a internal variable to write all there.
.PHONY: magic-lvs
magic-lvs: magic-validation
	cd $(TOP_GDS_DIR) && $(MAGIC_BATCH) $(MAGIC_LVS_SCRIPT) |& tee $(MAGIC_LVS_LOG)


.PHONY: magic-pex
magic-pex: magic-validation
	cd $(TOP_GDS_DIR) && $(MAGIC_BATCH) $(MAGIC_PEX_SCRIPT) |& tee $(MAGIC_PEX_LOG)
