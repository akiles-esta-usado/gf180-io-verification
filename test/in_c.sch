v {xschem version=3.4.4 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 1500 -100 1500 -60 {
lab=DVSS}
N 1490 -60 1500 -60 {
lab=DVSS}
N 1520 -100 1520 -60 {
lab=VSS}
N 1520 -60 1530 -60 {
lab=VSS}
N 1500 -270 1500 -240 {
lab=DVDD}
N 1490 -270 1500 -270 {
lab=DVDD}
N 1520 -270 1520 -240 {
lab=VDD}
N 1520 -270 1530 -270 {
lab=VDD}
N 1660 -140 1690 -140 {
lab=PU}
N 1660 -160 1690 -160 {
lab=PD}
N 1690 -140 1690 -110 {
lab=PU}
N 1690 -110 1700 -110 {
lab=PU}
N 1700 -110 1710 -110 {
lab=PU}
N 1690 -160 1700 -160 {
lab=PD}
N 1700 -140 1720 -140 {
lab=PD}
N 1700 -160 1700 -140 {
lab=PD}
N 1670 -180 1700 -180 {
lab=Y}
N 1660 -180 1670 -180 {
lab=Y}
N 1700 -200 1700 -180 {
lab=Y}
N 1700 -200 1720 -200 {
lab=Y}
N 1710 -110 1720 -110 {
lab=PU}
N 1660 -200 1690 -200 {
lab=PAD}
N 1690 -230 1690 -200 {
lab=PAD}
N 1690 -230 1720 -230 {
lab=PAD}
N 1030 100 1070 100 {
lab=GND}
N 1050 100 1050 120 {
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
C {devices/code_shown.sym} 1230 -70 0 0 {name=SIMULATION only_toplevel=true
place=header
format="tcleval( @value )"
value="
.param T=100ns

vpad PAD n1 pulse(0 3.3 \{T/2\} 50ps 50ps \{T/2\} \{T\} 1)
vpad2 n1 n2 pulse(0 5 \{3*T/2\} 50ps 50ps \{T/2\} \{T\} 1)
vpad3 n2 n3 pulse(0 2.5 \{5*T/2\} 50ps 50ps \{T/2\} \{T\} 1)
vpad4 n3 0 pulse(0 1 \{7*T/2\} 50ps 50ps \{T/2\} \{T\} 1)

vpu PU 0 pulse(0 5 225ns 50ps 50ps \{T/2\} \{T\} 1)
vpd PD 0 pulse(0 5 325ns 50ps 50ps \{T/2\} \{T\} 1)

vdd0 DVDD 0 pulse(5 0 1ns 50ps 50ps 1ns 2ns 1)
vdd1 VDD 0 pulse(5 0 1ns 50ps 50ps 1ns 2ns 1)

.tran 25ns 500ns 
remzerovec
.control
save all

plot PAD
plot Y
write in_c.raw
.endc

"}
C {devices/gnd.sym} 1050 120 0 0 {name=l4 lab=GND}
C {devices/iopin.sym} 1030 100 2 0 {name=p3 lab=VSS}
C {devices/iopin.sym} 1070 100 0 0 {name=p4 lab=DVSS}
C {pex/gf180mcu_fd_io__in_c_flat.sym} 1510 -170 0 0 {name=x2}
C {devices/iopin.sym} 1490 -60 2 0 {name=p5 lab=DVSS}
C {devices/iopin.sym} 1530 -60 0 0 {name=p6 lab=VSS}
C {devices/iopin.sym} 1490 -270 2 0 {name=p7 lab=DVDD}
C {devices/iopin.sym} 1530 -270 0 0 {name=p8 lab=VDD}
C {devices/iopin.sym} 1720 -110 0 0 {name=p12 lab=PU}
C {devices/iopin.sym} 1720 -140 0 0 {name=p13 lab=PD}
C {devices/iopin.sym} 1720 -200 0 0 {name=p14 lab=Y}
C {devices/iopin.sym} 1720 -230 0 0 {name=p15 lab=PAD}
