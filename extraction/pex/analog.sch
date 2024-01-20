v {xschem version=3.4.4 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 850 20 850 50 {
lab=ASIG5V}
N 930 20 930 50 {
lab=DVDD}
N 850 110 850 130 {
lab=GND}
N 930 110 930 130 {
lab=GND}
N 1010 20 1010 50 {
lab=VSS}
N 1090 20 1090 50 {
lab=DVSS}
N 1010 110 1010 130 {
lab=GND}
N 1090 110 1090 130 {
lab=GND}
N 1010 20 1010 50 {
lab=VSS}
N 1090 20 1090 50 {
lab=DVSS}
N 1010 110 1010 130 {
lab=GND}
N 1090 110 1090 130 {
lab=GND}
C {devices/code.sym} 950 -180 0 0 {name=MODELS
only_toplevel=true
place=header
format="tcleval( @value )"
value="
.include $env(PDK_ROOT)/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib $env(PDK_ROOT)/$env(PDK)/libs.tech/ngspice/sm141064.ngspice typical
.lib $env(PDK_ROOT)/$env(PDK)/libs.tech/ngspice/sm141064.ngspice diode_typical
.lib $env(PDK_ROOT)/$env(PDK)/libs.tech/ngspice/sm141064.ngspice res_typical
.lib $env(PDK_ROOT)/$env(PDK)/libs.tech/ngspice/sm141064.ngspice bjt_typical
.lib $env(PDK_ROOT)/$env(PDK)/libs.tech/ngspice/sm141064.ngspice mimcap_typical
.lib $env(PDK_ROOT)/$env(PDK)/libs.tech/ngspice/sm141064.ngspice moscap_typical
"}
C {devices/code_shown.sym} 1220 -130 0 0 {name=SIMULATION only_toplevel=true
place=header
format="tcleval( @value )"
value="
.include $env(PWD)/gf180mcu_fd_io__asig_5p0.pex

XP1 VSS VDD DVSS DVDD ASIG5V gf180mcu_fd_io__asig_5p0_flat

.tran 50n 100n

.control
plot vdd
.endc

"}
C {devices/vsource.sym} 850 80 0 0 {name=V1 value=3.3 savecurrent=false}
C {devices/vsource.sym} 930 80 0 0 {name=V2 value=3.3 savecurrent=false}
C {devices/vsource.sym} 1010 80 0 0 {name=V3 value=0 savecurrent=false}
C {devices/vsource.sym} 1090 80 0 0 {name=V4 value=0 savecurrent=false}
C {devices/gnd.sym} 850 130 0 0 {name=l1 lab=GND}
C {devices/gnd.sym} 930 130 0 0 {name=l2 lab=GND}
C {devices/gnd.sym} 1010 130 0 0 {name=l3 lab=GND}
C {devices/gnd.sym} 1090 130 0 0 {name=l4 lab=GND}
C {devices/iopin.sym} 850 20 0 0 {name=p1 lab=ASIG5V}
C {devices/iopin.sym} 930 20 0 0 {name=p2 lab=DVDD}
C {devices/iopin.sym} 1010 20 0 0 {name=p3 lab=VSS}
C {devices/iopin.sym} 1090 20 0 0 {name=p4 lab=DVSS}
