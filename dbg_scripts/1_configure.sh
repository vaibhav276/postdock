#!/bin/bash

# Disbale optimization
sed -i 's/O2/O0/g' $PGSRCROOT/configure
cd $PGSRCROOT

# Create infrastructure required for building
./configure --prefix=$PGROOT --enable-depend --enable-cassert --enable-debug

# Setup data directory
mkdir -p $PGROOT/data
chown -R docker:docker $PGROOT/data
