# PDK Verification: gf180mcuD

This repo justs adds some validation scripts over the gf180mcuD flavor of io cells.

## Clone command

This repo uses git submodules, so the clone command should be:

~~~bash
$ git clone --recursive https://github.com/akiles-esta-usado/gf180-io-verification.git
~~~

If you cloned but forgot the `--recursive` flag, dependencies can be pulled with this

~~~bash
$ git submodule update --init --recursive
~~~
