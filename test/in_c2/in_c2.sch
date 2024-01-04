v {xschem version=3.4.4 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
B 2 1860 -480 2660 -80 {flags=graph
y1=0
y2=2
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=10e-6
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node=""
color=""
dataset=-1
unitx=1
logx=0
logy=0
}
B 2 1860 -80 2660 320 {flags=graph
y1=0
y2=2
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=10e-6
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node=""
color=""
dataset=-1
unitx=1
logx=0
logy=0
}
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
C {devices/code_shown.sym} 1230 0 0 0 {name=SIMULATION only_toplevel=true
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

.control
save all
tran 25ns 500ns 
remzerovec
write in_c2.raw
plot PAD
plot Y
.endc

"}
C {gf180mcu_fd_io__in_c_flat.sym} 1360 -340 0 0 {name=x2}
C {devices/iopin.sym} 1500 -160 1 0 {name=p5 lab=DVSS}
C {devices/iopin.sym} 1520 -160 1 0 {name=p6 lab=VSS}
C {devices/iopin.sym} 1500 -360 3 0 {name=p7 lab=DVDD}
C {devices/iopin.sym} 1520 -360 3 0 {name=p8 lab=VDD}
C {devices/iopin.sym} 1340 -240 2 0 {name=p12 lab=PU}
C {devices/iopin.sym} 1340 -260 2 0 {name=p13 lab=PD}
C {devices/iopin.sym} 1340 -280 2 0 {name=p14 lab=Y}
C {devices/iopin.sym} 1340 -300 2 0 {name=p15 lab=PAD}
C {devices/launcher.sym} 1915 -520 0 0 {name=h5
descr="load waves" 
tclcommand="xschem raw_read $netlist_dir/in_c.raw tran"
}
