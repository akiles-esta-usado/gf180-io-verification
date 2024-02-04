v {xschem version=3.4.4 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
B 2 1850 -1040 2650 -640 {flags=graph
y1=-0.044
y2=3.2
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=9.65122e-09
x2=2.66668e-08
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node="A
\\"4mA (LVS);y0\\"
\\"4mA (PEX); y6\\"
\\"16mA (LVS);y3\\"
\\"16mA (PEX); y5\\"
\\"Mehdi 4mA;y4\\""
color="7 4 6 10 7 19"
dataset=-1
unitx=1
logx=0
logy=0
rainbow=1}
T {IE  OE  Input Output Control
----------------------------
0   0   IO Disable
0   1   Output Enabled
1   0   Input Enabled
1   1   Disallowed


CS  Input Type
--------------
0   CMOS Buffer
1   Schmitt Trigger


PU  PD  Resistive Pulling
-------------------------
0   0   Normal CMOS
0   1   Pull Down
1   0   Pull Up
1   1   Normal CMOS


SL Output Slew Rate
-------------------
0  Fast
1  Slow


PDRV1 PDRV0 Output drive strength
---------------------------------
0     0     4mA
0     1     8mA
1     0     12mA
1     1     16mA


DVDD  5V supply for output drivers
VDD   5V supply for pre-drive in I/O pads
DVSS  Ground for output drivers
VSS   Ground for pre-drive in I/O pads
IE    Input enable
PD    Pull-down enable
PU    Pull-up enable
Y     Data output to core
PAD   Data input from/output to bond pad
OE    Output enable
A     Data input from core
CS    CMOS/Schmitt trigger input select
SL    Fast/Slow slew rate select
PDRV0 Output drive strength selector
PDRV1 Output drive strength selector} -520 -1160 0 0 0.4 0.4 {font=monospace}
T {} -530 -350 0 0 0.4 0.4 {font=Monospace}
T {Each block can be ignored with property `spice_ignore=1`} 90 -1270 0 0 0.4 0.4 {}
N 150 -490 150 -470 {
lab=GND}
N 150 -610 150 -550 {
lab=DVDD}
N 210 -490 210 -470 {
lab=GND}
N 210 -610 210 -550 {
lab=VDD}
N 150 -470 210 -470 {
lab=GND}
N 270 -490 270 -470 {
lab=GND}
N 270 -610 270 -550 {
lab=DVSS}
N 330 -490 330 -470 {
lab=GND}
N 330 -610 330 -550 {
lab=VSS}
N 270 -470 330 -470 {
lab=GND}
N 210 -470 270 -470 {
lab=GND}
N 390 -300 390 -280 {
lab=GND}
N 390 -420 390 -360 {
lab=A}
N 510 -490 510 -470 {
lab=GND}
N 510 -610 510 -550 {
lab=IE}
N 570 -490 570 -470 {
lab=GND}
N 510 -470 570 -470 {
lab=GND}
N 570 -610 570 -550 {
lab=OE}
N 630 -490 630 -470 {
lab=GND}
N 570 -470 630 -470 {
lab=GND}
N 630 -610 630 -550 {
lab=PU}
N 690 -490 690 -470 {
lab=GND}
N 630 -470 690 -470 {
lab=GND}
N 690 -610 690 -550 {
lab=PD}
N 750 -490 750 -470 {
lab=GND}
N 690 -470 750 -470 {
lab=GND}
N 750 -610 750 -550 {
lab=SL}
N 810 -490 810 -470 {
lab=GND}
N 750 -470 810 -470 {
lab=GND}
N 810 -610 810 -550 {
lab=CS}
N 330 -470 510 -470 {
lab=GND}
C {devices/code_shown.sym} 1390 -1110 0 0 {name=s1
only_toplevel=false
value="
.control
save A y0 y3 y4 y5 y6

tran 100p 50n

*plot A PAD0 Y0
*plot A PAD0 PAD1 PAD2 PAD3
*plot A PAD0 PAD3 PAD4
*plot A Y0 Y3 Y4


write

.endc
"}
C {devices/code_shown.sym} 1390 -1280 0 0 {name=MODELS only_toplevel=true
format="tcleval( @value )"
value="
.include $::180MCU_MODELS/design.ngspice
.lib $::180MCU_MODELS/sm141064.ngspice typical
.lib $::180MCU_MODELS/sm141064.ngspice diode_typical
.lib $::180MCU_MODELS/sm141064.ngspice res_typical
.lib $::180MCU_MODELS/sm141064.ngspice mimcap_typical
.lib $::180MCU_MODELS/sm141064.ngspice moscap_typical
"}
C {devices/code_shown.sym} 0 -1000 0 0 {name="Mehdi Team"
only_toplevel=true
spice_ignore=1
format="tcleval( @value )"
value="
.include "./gf180mcu_fd_io__bi_t_openfasoc.spice"
* gf180mcu_fd_io__bi_t_extracted A CS DVDD DVSS IE OE PAD  PD PDRV0 PDRV1 PU SL VDD VSS Y
XDUT4                            A CS DVDD DVSS IE OE PAD4 PD VSS   VSS   PU SL VDD VSS Y4 gf180mcu_fd_io__bi_t_extracted
"}
C {devices/vsource.sym} 150 -520 0 0 {name=V1 value=\{v_max\}}
C {devices/gnd.sym} 150 -470 0 0 {name=l1 lab=GND}
C {devices/lab_wire.sym} 150 -590 0 0 {name=p1 sig_type=std_logic lab=DVDD}
C {devices/vsource.sym} 210 -520 0 0 {name=V2 value=\{v_max\}}
C {devices/lab_wire.sym} 210 -590 0 0 {name=p2 sig_type=std_logic lab=VDD}
C {devices/vsource.sym} 270 -520 0 0 {name=V3 value=0}
C {devices/lab_wire.sym} 270 -590 0 0 {name=p3 sig_type=std_logic lab=DVSS}
C {devices/vsource.sym} 330 -520 0 0 {name=V4 value=0}
C {devices/lab_wire.sym} 330 -590 0 0 {name=p4 sig_type=std_logic lab=VSS}
C {devices/vsource.sym} 390 -330 0 0 {name=V5 value="PULSE(0 \{v_max\} 10n 100p 100p \{t_on\} \{t_total\})"}
C {devices/lab_wire.sym} 390 -400 0 0 {name=p5 sig_type=std_logic lab=A}
C {devices/vsource.sym} 510 -520 0 0 {name=V7 value=\{v_max\}}
C {devices/lab_wire.sym} 510 -590 0 0 {name=p7 sig_type=std_logic lab=IE}
C {devices/vsource.sym} 570 -520 0 0 {name=V8 value=\{v_max\}}
C {devices/lab_wire.sym} 570 -590 0 0 {name=p8 sig_type=std_logic lab=OE}
C {devices/vsource.sym} 630 -520 0 0 {name=V9 value=0}
C {devices/lab_wire.sym} 630 -590 0 0 {name=p9 sig_type=std_logic lab=PU}
C {devices/vsource.sym} 690 -520 0 0 {name=V10 value=0}
C {devices/lab_wire.sym} 690 -590 0 0 {name=p10 sig_type=std_logic lab=PD}
C {devices/vsource.sym} 750 -520 0 0 {name=V11 value=0}
C {devices/lab_wire.sym} 750 -590 0 0 {name=p11 sig_type=std_logic lab=SL}
C {devices/gnd.sym} 390 -280 0 0 {name=l2 lab=GND}
C {devices/vsource.sym} 810 -520 0 0 {name=V13 value=\{v_max\}}
C {devices/lab_wire.sym} 810 -590 0 0 {name=p13 sig_type=std_logic lab=CS}
C {devices/code_shown.sym} 650 -380 0 0 {name=s2
only_toplevel=false
place=header
value="
.param v_max=3
.param t_total=20n
.param t_on=10n
"}
C {devices/launcher.sym} 1900 -1080 0 0 {name=h5
descr="load waves" 
tclcommand="xschem raw_read $netlist_dir/rawspice.raw tran"
}
C {devices/code_shown.sym} 0 -880 0 0 {name="PEX Simulation"
only_toplevel=true
format="tcleval( @value )"
spice_ignore=0
value="
.include "../../extraction/pex/gf180mcu_fd_io__bi_t_pex.spice"
* gf180mcu_fd_io__bi_t_pex DVSS DVDD PAD  SL A Y  PDRV1 PDRV0 PD CS OE IE PU VDD VSS
XDUT5                      DVSS DVDD PAD5 SL A Y5 VDD   VDD   PD CS OE IE PU VDD VSS gf180mcu_fd_io__bi_t_pex
XDUT6                      DVSS DVDD PAD6 SL A Y6 VSS   VSS   PD CS OE IE PU VDD VSS gf180mcu_fd_io__bi_t_pex
"}
C {devices/code_shown.sym} 0 -1140 0 0 {name="Clean Simulation"
only_toplevel=true
spice_ignore=0
format="tcleval( @value )"
value="
.include "../../extraction/lvs/gf180mcu_fd_io__bi_t_extracted.spice"
* gf180mcu_fd_io__bi_t VSS VDD DVSS DVDD PAD  CS PU PDRV0 PDRV1 PD IE SL A OE Y
XDUT0                  VSS VDD DVSS DVDD PAD0 CS PU VSS   VSS   PD IE SL A OE Y0  gf180mcu_fd_io__bi_t
XDUT3                  VSS VDD DVSS DVDD PAD3 CS PU VDD   VDD   PD IE SL A OE Y3  gf180mcu_fd_io__bi_t
"}
