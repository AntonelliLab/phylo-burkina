#!/bin/bash
# SUPERSMART workflow for Burkina inference

NAMES=$PWD/data/names.txt
OUTGROUP=Moniliformopses

export WORKDIR=$PWD/results/2016-03-16 #`date +%Y-%m-%d`

if [ ! -d $WORKDIR ]; then
    mkdir $WORKDIR
fi

# copy this script in the working directory so 
# parameter settings are stored
cp $BASH_SOURCE $WORKDIR

# Start the SUPERSMART pipeline
smrt taxize -i $NAMES -w $WORKDIR

smrt align -w $WORKDIR

smrt orthologize -w $WORKDIR

export SUPERSMART_BACKBONE_MAX_DISTANCE="0.1"
export SUPERSMART_BACKBONE_MIN_COVERAGE="4"
export SUPERSMART_BACKBONE_MAX_COVERAGE="6"

smrt bbmerge -w $WORKDIR

#export SUPERSMART_EXABAYES_NUMGENS="100000"
#export SUPERSMART_EXABAYES_NUMRUNS="8"

smrt bbinfer --inferencetool=exabayes -t species.tsv -o backbone.dnd -w $WORKDIR
exit 0


smrt bbreroot -g $OUTGROUP --smooth --ultrametricize -w $WORKDIR

smrt consense -i backbone-rerooted.dnd -b 0.2 --prob -w $WORKDIR

export SUPERSMART_CLADE_MAX_DISTANCE="0.2"
export SUPERSMART_CLADE_MIN_DENSITY="0.5"

smrt bbdecompose -w $WORKDIR

smrt clademerge --enrich -w $WORKDIR

smrt cladeinfer --ngens=30_000_000 --sfreq=1000 --lfreq=1000 -w $WORKDIR

smrt cladegraft -w $WORKDIR
