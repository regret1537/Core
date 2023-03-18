#!/bin/bash

if [ -f nand.gz ]; then
    gunzip nand.gz
fi

OUTPUT=nand

IFS='
'
for I in `cat partmap.txt`; do
    FILE=`echo $I | awk '{print $1;}'`
    PART=`echo $I | awk '{print $3;}'`
    MODE=`echo $I | awk '{print $4;}'`
    if [ x$PART == x ]; then
        continue
    fi
    if [ x$MODE == x ]; then
        echo $FILE '->' $PART
        continue
    fi
    PDATA=`grep "  $PART"'$' parts.txt`
    PSTART=`echo $PDATA | awk '{print $2;}'`
    PEND=`echo $PDATA | awk '{print $3;}'`
    echo $FILE '->' $PART as $MODE at $PSTART-$PEND

    if [ $MODE == locl ]; then
        SIZE=`stat -c '%s' $FILE`
        if [ $SIZE -gt $((($PEND-$PSTART+1)*4096)) ]; then
            echo 'Oversized local flat file!'
        else
            dd if=$FILE bs=4096 seek=$PSTART conv=notrunc of=$OUTPUT status=none
        fi
    fi
done
