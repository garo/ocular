#!/bin/bash
while [ true ] ; do
   read -n 1
   if [ $? = 0 ] ; then
      clear
      rspec -fd spec/ocular/inputs/http_input_spec.rb
   else
      echo waiting...
   fi
done
