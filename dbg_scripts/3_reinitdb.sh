#!/bin/bash
rm -rf $PGROOT/data
initdb -D $PGROOT/data
