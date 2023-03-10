~~~
$ cddlc -2tcddl -
start = cose.COSE_Key
;# import rfc9052 as cose

~~~


This results in the following CDDL 1.0 specification:

~~~ cddl
start = cose.COSE_Key
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
