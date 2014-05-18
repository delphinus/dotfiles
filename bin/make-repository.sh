#!/bin/sh
ssh git@orcinus.remora.cx "cd delphinus && mkdir $1 && cd $1 && git init --bare"
