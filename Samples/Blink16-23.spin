CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

PUB Main
  DIRA[23..16]~~
  repeat
    !OUTA[16]
    waitcnt(clkfreq / 12 + cnt)
    !OUTA[17]
    waitcnt(clkfreq / 12 + cnt)
    !OUTA[18]
    waitcnt(clkfreq / 12 + cnt)
    !OUTA[19]
    waitcnt(clkfreq / 12 + cnt)
    !OUTA[20]
    waitcnt(clkfreq / 12 + cnt)
    !OUTA[21]
    waitcnt(clkfreq / 12 + cnt)
    !OUTA[22]
    waitcnt(clkfreq / 12 + cnt)
    !OUTA[23]
    waitcnt(clkfreq / 12 + cnt)

        