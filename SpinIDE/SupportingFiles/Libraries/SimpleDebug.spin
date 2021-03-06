''***************************************
''*  Simple Debug Object                *
''*  Author: Jon Williams               *
''*  Copyright (c) 2006 Parallax, Inc.  *
''*  See end of file for terms of use.  *
''***************************************


OBJ
  uart  : "FullDuplexSerial"


PUB start(baud) : okay

'' Starts uart object (at baud specified) in a cog
'' -- uses Propeller programming connection
'' -- returns false if no cog available

  okay := uart.start(31, 30, 0, baud) 


PUB startx(rxpin, txpin, baud) : okay

'' Starts uart object (at baud specified) in a cog
'' -- uses specified rx and tx pins
'' -- returns false if no cog available

  okay := uart.start(rxpin, txpin, 0, baud) 


PUB stop

'' Stops uart -- frees a cog

  uart.stop

  
PUB putc(txbyte)

'' Send a byte to the terminal

  uart.tx(txbyte)
  
  
PUB str(stringPtr) | i

'' Print a zero-terminated string

  repeat i from 0 to strsize(stringPtr) - 1
    putc(byte[stringPtr][i])


PUB dec(value) | i, z

'' Print a signed decimal number

  if value < 0
    -value
    putc("-")

  i := 1_000_000_000
  z~

  repeat 10
    if value => i
      putc(value / i + "0")
      value //= i
      z~~
    elseif z or i == 1
      putc("0")
    i /= 10


PUB hex(value, digits)

'' Print a hexadecimal number

  value <<= (8 - digits) << 2
  repeat digits
    putc(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))


PUB bin(value, digits)

'' Print a binary number

  value <<= 32 - digits
  repeat digits
    putc((value <-= 1) & 1 + "0")
    

PUB getc : rxbyte

'' Get a character
'' -- will block until something in uart buffer

  rxbyte := uart.rx
  
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}  