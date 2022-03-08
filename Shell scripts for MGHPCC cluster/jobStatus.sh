#!/bin/bash

read -p "Enter your username: " usrname
bjobs -u $usrname
