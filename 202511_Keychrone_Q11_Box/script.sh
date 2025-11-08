#!/usr/bin/env bash
# #!/bin/bash
# Bottom
openscad -o Right_bottom.stl -D 'part="bottom"' ./Right_170x140x35_all.scad

# Lid
openscad -o Right_lid.stl -D 'part="lid"' ./Right_170x140x35_all.scad
