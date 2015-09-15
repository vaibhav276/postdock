#!/bin/bash
pg_ctl -D $PGROOT/data stop
pkill 4_startdb.sh
