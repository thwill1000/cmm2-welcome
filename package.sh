#!/bin/bash

release=0.1
release_dir="welcome-r$release"
base="$release_dir/welcome"

mkdir -p $base
mkdir -p $base/common
mkdir -p $base/eliza
mkdir -p $base/graphics
mkdir -p $base/lunar
mkdir -p $base/menu
mkdir -p $base/pirate
mkdir -p $base/splash
mkdir -p $base/turtle

cp ChangeLog $base
cp LICENSE $base
cp README.md $base
cp welcome.bas $base
cp -R common/* $base/common
cp -R eliza/* $base/eliza
cp -R graphics/* $base/graphics
cp -R lunar/* $base/lunar
cp -R menu/* $base/menu
cp -R pirate/* $base/pirate
cp -R splash/* $base/splash
cp -R turtle/* $base/turtle

cd $release_dir
zip -r ../$release_dir.zip welcome
cd ..
