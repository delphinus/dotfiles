#!/bin/sh
for i in $@; do
    perl -MClass::Inspector -e"print Class::Inspector->resolved_filename('$i') . qq!\\n!"
done
