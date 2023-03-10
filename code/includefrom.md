~~~
$ cddlc -2tcddl -
mydata = {* label => values}
;# include label, values from rfc9052

~~~


With `include`,
only exactly the rules mentioned are included:

~~~ cddl
mydata = {* label => values}
label = int / tstr
values = any

~~~
