#!/bin/bash
echo "destroying sockets"
ssh -S ~/.ssh/yum.sock -O exit root@localhost;
ssh -S ~/.ssh/jump.sock -O exit root@172.20.132.3
