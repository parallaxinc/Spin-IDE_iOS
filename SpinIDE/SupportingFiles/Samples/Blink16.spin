CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

PUB Main
  DIRA[16]~~
  repeat
    !OUTA[16]
    waitcnt(clkfreq / 2 + cnt)

        