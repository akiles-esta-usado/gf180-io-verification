v {xschem version=3.4.4 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
B 2 1840 -340 2640 60 {flags=graph
y1=-1.6e-15
y2=-6.3e-23
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=2e-05
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node="vdd
"
color=9
dataset=-1
unitx=1
logx=0
logy=0
}
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
C {devices/code_shown.sym} 1230 -70 0 0 {name=SIMULATION only_toplevel=true
place=header
format="tcleval( @value )"
value="
.control
tran 1u 20u
remzerovec
plot vdd
write asig_5p0.raw
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
C {gf180mcu_fd_io__asig_5p0_flat.sym} 1290 -310 0 0 {name=x1}
C {devices/iopin.sym} 1470 -170 1 0 {name=p5 lab=DVSS}
C {devices/iopin.sym} 1490 -170 1 0 {name=p6 lab=VSS}
C {devices/iopin.sym} 1490 -330 3 0 {name=p7 lab=DVDD}
C {devices/iopin.sym} 1270 -250 2 0 {name=p8 lab=ASIG5V}
C {devices/iopin.sym} 1470 -330 3 0 {name=p9 lab=VDD}
C {devices/launcher.sym} 1900 -380 0 0 {name=h5
descr="load waves" 
tclcommand="xschem raw_read $netlist_dir/asig_5p0.raw tran"
}
