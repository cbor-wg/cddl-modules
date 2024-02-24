A tool may provide a way to specify a root for the module tree from the command line:

~~~
$ cddlc -2tcddl -icose=rfc9052 -scose.COSE_Key
~~~


The command line argument `-icose=rfc9052` is a shortcut for

~~~
;# import rfc9052 as cose
~~~

Together with the start (root) rule name, `cose.COSE_Key`, supplied by
`-scose.COSE_Key`, this results in the following CDDL 1.0
specification:

~~~ cddl
$.start.$ = cose.COSE_Key
cose.COSE_Key = {
  1 => tstr / int,
  ? 2 => bstr,
  ? 3 => tstr / int,
  ? 4 => [+ tstr / int],
  ? 5 => bstr,
  * cose.label => cose.values,
}
cose.label = int / tstr
cose.values = any

~~~
