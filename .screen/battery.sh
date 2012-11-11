#!/bin/sh
ioreg -n AppleSmartBattery | \
awk '/MaxCapacity/ {MAX = $5}
    /CurrentCapacity/ {CURRENT = $5}
    /InstantTimeToEmpty/ {REMAIN = $5}
    END {
        printf("B %6.2f%% ", CURRENT / MAX*100)
        if (REMAIN > 1000)
            if (CURRENT == MAX) printf("(MAX)    ")
            else                printf("(Charge) ")
        else                    printf("(%02d:%02d)  ", REMAIN / 60, REMAIN % 60)
    }'
