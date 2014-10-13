#!/bin/bash

MRUBY_LIB=${HOME}/devel/mruby/build/host/lib
gcc -shared -fPIC -all_load -o ${MRUBY_LIB}/libmruby.dylib ${MRUBY_LIB}/libmruby.a -L/Library/Frameworks/R.framework/Resources/lib -lR -lm -ltermcap -lreadline -lonig -luv
