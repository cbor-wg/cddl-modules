~~~
$ cddlc -2tcddl -
mydata = {* label => values}
;# include cose.label, cose.values from rfc9052 as cose

~~~


Again, only exactly the rules mentioned are included:

~~~ cddl
mydata = {* label => values}
cose.label = int / tstr
cose.values = any

~~~
