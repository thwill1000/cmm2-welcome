#!/bin/bash

release=0.3
release_dir="welcome-r$release"
base="$release_dir/welcome"

mkdir -p $base

cp ChangeLog $base
cp LICENSE $base
cp README.md $base
cp welcome.bas $base

sub_dirs=("chirps" "common" "eliza" "graphics" "life" "lunar" "menu" "pirate" "speech" "splash" "turtle")
for d in ${sub_dirs[@]}; do
  mkdir -p $base/$d
  cp -R $d/* $base/$d
done

cd $release_dir
zip -r ../$release_dir.zip welcome
cd ..
