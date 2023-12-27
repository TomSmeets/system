#!/bin/bash
find /etc /home /root /usr /var -type l -lname '*/tree/*' -printf "%p -> %l\n" | sort | column -t
