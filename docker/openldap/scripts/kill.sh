#!/bin/bash
ps -ef | grep slapd | awk '{print $2}' | xargs kill -9