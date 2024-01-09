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


## Commands

Los comandos tienen una sintáxis simple

~~~
$ make TOP=<filename> command
~~~

En donde

- filename: Es el nombre del archivo, pero sin extensión. Make debe identificar todos los archivos que puedan ser relevantes relacionados por el nombre.
- command: Es una regla de Make. Se declaran con la directiva `.PHONY`.

### Evaluate DRC with Klayout

~~~
# Evaluate and show drc results
$ make TOP=<filename> klayout-drc

# Only evaluate DRC and generate .lyrdb files
$ make TOP=<filename> klayout-drc-only

# Open klayout with .lyrdb files
$ make TOP<filename> klayout-drc-view
~~~

Ejemplos relevantes

~~~
# Evaluate analogue pads
$ make TOP=asig_5p0 klayout-drc

# Evaluate default padring
$ make TOP= klayout-drc
~~~


