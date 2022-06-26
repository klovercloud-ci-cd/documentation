#!/bin/bash
filename='public.txt'
while read line; do
  echo $line
  sleep 10s
done <$filename
