# asm2bf-utility-functions
Why write asm2bf boilerplate when someone else can do it for you?

All of these are compiled using `bfmake` from the (current) latest `asm2bf` with no extra options, and run using `tritium -b32 -u [filename]`. Quick and dirty, may contain bugs and a dearth of comments.

All of these functions use a calling convention where all arguments are passed on the stack and returned using the stack, callee-cleanup, and all registers treated as non-volatile; they can probably be easily rewritten to use a more mainstream convention, but I found this one easy to debug and control side-effects with.
