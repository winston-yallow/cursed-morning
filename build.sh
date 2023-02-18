#!/usr/bin/env bash
set -euo pipefail

# NOTE
#
# This script assumes these files/directories exist:
#
# ./godot [file]
# ./dist [dir]
#   ./windows [dir]
#   ./linux [dir]
#   ./Godot_v4.0-rc2.x86_64 [file]
#   ./Godot_v4.0-rc2.exe [file]
#
# The Godot binary at the root is used to run the export.
# It can be a link pointing to the actual binary file.
# The two Godot binaries in the ./dist folder should be
# normal editor binaries. They are copied into the exported
# project since the non-editor build of godot has bugs that
# prevent it from running this project.

dist_dir="./dist"
game_name="cursed_morning"

function build() {
    local platform="${1}"
    local binary_ext="${2}"
    local export_dir="${dist_dir}/${platform}"
    local editor_bin="Godot_v4.0-rc2.${binary_ext}"
    local game_bin="${game_name}.${binary_ext}"
    local game_pck="${game_name}.pck"
    local zip_name="${game_name}_${platform}.zip"

    ./godot --path "./project" --headless --export-release "${platform}"
    cp "${dist_dir}/${editor_bin}" "${export_dir}/${game_bin}"
    pushd "${export_dir}"
    zip "../${zip_name}" "${game_bin}" "${game_pck}"
    popd
}

build "linux" "x86_64"
build "windows" "exe"

