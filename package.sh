#!/bin/bash

release=1.0.0
release_dir="welcome-r$release"
base="$release_dir/welcome"

mkdir -p $base

cp ChangeLog $base
cp LICENSE $base
cp README.md $base
cp welcome.bas $base

sub_dirs=("common" "eliza" "fractals" "games" "graphics" "life" "mandelbrot-explorer" "menu" "misc" "pirate" "sound" "sprites" "turtle" "utils")
for d in ${sub_dirs[@]}; do
  mkdir -p $base/$d
  cp -R $d/* $base/$d
done

rm -rf $base/pirate/src/pirate.dmp
rm -rf $base/pirate/src/saves
rm -rf $base/pirate/src/scripts

cd $release_dir
zip -r ../$release_dir.zip welcome
cd ..
