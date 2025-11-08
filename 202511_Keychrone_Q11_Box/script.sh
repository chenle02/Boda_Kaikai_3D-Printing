#!/usr/bin/env bash
# #!/bin/bash
# Bottom
openscad -o Left_bottom.stl -D 'part="bottom"' Left_170x140x35_all.scad
openscad -o Left_lid.stl -D 'part="lid"' Left_170x140x35_all.scad

# Bottom
openscad -o Right_bottom.stl -D 'part="bottom"' Right_190x140x35_all.scad
openscad -o Right_lid.stl -D 'part="lid"' Right_190x140x35_all.scad
