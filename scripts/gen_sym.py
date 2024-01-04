from pathlib import Path
import math

def get_subckt_declarations(netlist: Path | str) -> list[str]:

    declarations = list()

    with open(netlist, "r") as f:
        for line in f:
            if not line.startswith(".subckt"):
                continue

            declarations.append(line)

    return declarations


def get_ports(subckt: str) -> list[str]:
    return subckt.split(" ")[2::]


def position_ports(ports: list[str]) -> dict[str, list[str]]:
    positions = {
        "top": list(),
        "bottom": list(),
        "right": list(),
        "left": list(),
    }

    for port in ports:
        port = port.strip()
        if port.lower() in {"vdd", "dvdd"}:
            positions["top"].append(port)

        elif port.lower() in {"vss", "dvss"}:
            positions["bottom"].append(port)

        else:
            positions["left"].append(port)

    return positions


def draw_sym(netlist_name :str, positions: dict[str, list[str]]) -> str:
    content = [
        'v {xschem version=3.4.4 file_version=1.2',
        '}',
        'G {}',
        'K {type=subcircuit',
        'format="@name @pinlist @symname"',
        'template="name=x1"',
        'spice_sym_def="tcleval( .include [abs_sym_path gf180mcu_fd_io_pex.ngspice] )"',
        '}',
        'V {}',
        'S {}',
        'E {}',
    ]

    dx = 20
    dy = 20
    character_spacing = 10

    lateral_port_spacing = dy * max(len(positions["left"]), len(positions["right"]))
    top_names_spacing = character_spacing * max(len(i) for i in positions["top"]) if positions["top"] else 0
    left_names_spacing = character_spacing * max(len(i) for i in positions["left"]) if positions["left"] else 0
    right_names_spacing = character_spacing * max(len(i) for i in positions["right"]) if positions["right"] else 0
    bottom_names_spacing = character_spacing * max(len(i) for i in positions["bottom"]) if positions["bottom"] else 0

    max_lateral_name_spacing = max(left_names_spacing, right_names_spacing)

    name_spacing = 20 if lateral_port_spacing < 40 else 0
    len_symname = 10*len(f'{netlist_name}_flat')

    height = top_names_spacing + lateral_port_spacing + bottom_names_spacing + name_spacing
    width = 2*max_lateral_name_spacing + len_symname

    x_base = - width / 2
    y_base = - height / 2

    top_offset = dx * (len(positions["top"]) - 1)/2
    left_offset = dy * (len(positions["left"]) - 1)/2
    bottom_offset = dx * (len(positions["bottom"]) - 1)/2


    content.append(f"L 4 {x_base} {y_base} {x_base + width} {y_base} {{}}")
    content.append(f"L 4 {x_base} {y_base} {x_base} {y_base + height} {{}}")
    content.append(f"L 4 {x_base + width} {y_base} {x_base + width} {y_base + height} {{}}")
    content.append(f"L 4 {x_base} {y_base + height} {x_base + width} {y_base + height} {{}}")
    content.append(f"T {{@symname}} {x_base + width/2 - len_symname /2 + 5} {y_base + height/2 - 10} 0 0 0.3 0.3 {{font=Monospace}}")
    content.append(f"T {{@name}}    {x_base + width} {y_base-10} 0 0 0.2 0.2 {{font=Monospace}}")

    for i, port in enumerate(positions["top"]):
        # ■    ■    ■
        # |    |    |
        # ------------
        # P1   P2   P3
        # 1 -> 0
        # 2 -> 0.5
        # 3 -> 1
        L_start = (
            x_base + width/2 - top_offset + i*dx,
            y_base
        )
        L_end = (
            x_base + width/2 - top_offset + i*dx,
            y_base - 20 # To go up, subtract
        )

        content.append(f"L 7 {L_start[0]} {L_start[1]} {L_end[0]} {L_end[1]} {{}}")
        content.append(f"B 5 {L_end[0]-2.5} {L_end[1]-2.5} {L_end[0]+2.5} {L_end[1]+2.5} {{name={port} dir=inout}}")
        content.append(f"T {{{port}}} {L_start[0]-5} {L_start[1]+5} {3} 1 0.2 0.2 {{font=Monospace}}")


    for i, port in enumerate(positions["left"]):
        # ■ -- | P1
        # ■ -- | P2
        # ■ -- | P3
        L_start = (
            x_base,
            y_base + height/2 - left_offset + i*dy# - dy*len(positions["left"])/2 + i*dy # + top_names_spacing + i*dy
        )
        L_end = (
            x_base - dx,
            y_base + height/2 - left_offset + i*dy# - dy*len(positions["left"])/2 + i*dy # + top_names_spacing + i*dy
        )

        content.append(f"L 7 {L_start[0]} {L_start[1]} {L_end[0]} {L_end[1]} {{}}")
        content.append(f"B 5 {L_end[0]-2.5} {L_end[1]-2.5} {L_end[0]+2.5} {L_end[1]+2.5} {{name={port} dir=inout}}")
        content.append(f"T {{{port}}} {L_start[0]+5} {L_start[1] - 5} {0} 0 0.2 0.2 {{font=Monospace}}")


    for i, port in enumerate(positions["bottom"]):
        # P1   P2   P3
        # ------------
        # |    |    |
        # ■    ■    ■
        L_start = (
            x_base + width/2 - bottom_offset + i*dx,
            y_base + height
        )
        L_end = (
            x_base + width/2 - bottom_offset + i*dx,
            y_base + height + 20 # To go down, add
        )

        content.append(f"L 7 {L_start[0]} {L_start[1]} {L_end[0]} {L_end[1]} {{}}")
        content.append(f"B 5 {L_end[0]-2.5} {L_end[1]-2.5} {L_end[0]+2.5} {L_end[1]+2.5} {{name={port} dir=inout}}")
        content.append(f"T {{{port}}} {L_start[0]-5} {L_start[1]-5} {3} 0 0.2 0.2 {{font=Monospace}}")

    return content


def generate_sym(netlist: str, outdir: str):
    netlist_path = Path(netlist)

    if not netlist_path.exists():
        print(f"Netlist {str(netlist_path)} don't exist")
        return

    subckts = get_subckt_declarations(netlist_path)

    ports = get_ports(subckts[0])

    positions = position_ports(ports)

    sym = draw_sym(netlist_path.stem, positions)

    sym_path = Path(outdir) / f"{str(netlist_path.stem)}_flat.sym"
    sym_path.write_text("\n".join(sym))


import sys
if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"python {sys.argv[0]} <netlist_path> <sym_out_dir>")
        exit()

    netlist_path = Path(sys.argv[1])
    sym_directory = Path(sys.argv[2])

    generate_sym(netlist_path, sym_directory)