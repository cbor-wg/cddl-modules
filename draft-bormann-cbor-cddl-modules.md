---
v: 3

title: "CDDL Module Structure"
abbrev: "CDDL Module Structure"

docname: draft-bormann-cbor-cddl-modules-latest
stream: IETF
# updates: 8610
# date:
cat: std
consensus: true
area: "Applications and Real-Time"
workgroup: "Concise Binary Object Representation Maintenance and Extensions"
keyword:
 - Concise Data Definition Language
venue:
  group: "Concise Binary Object Representation Maintenance and Extensions"
  mail: "cbor@ietf.org"
  github: "cbor-wg/cddl-modules"
  latest: "https://cbor-wg.github.io/cddl-modules/draft-bormann-cbor-cddl-modules.html"

author:
  -
    name: Carsten Bormann
    org: Universität Bremen TZI
    street: Postfach 330440
    city: Bremen
    code: D-28359
    country: Germany
    phone: +49-421-218-63921
    email: cabo@tzi.org


normative:
  RFC8610: cddl
  RFC9165: control1

informative:
  I-D.draft-bormann-cbor-cddl-freezer: freezer
  I-D.bormann-cbor-cddl-2-draft: cddl-2-draft
  useful:
    target: https://github.com/cbor-wg/cddl/wiki/Useful-CDDL
    title: Useful CDDL
  cddlc:
    title: CDDL conversion utilities
    target: https://github.com/cabo/cddlc


--- abstract

[^abs1-]

[^abs1-]:
    At the time of writing,
    the Concise Data Definition Language (CDDL) is defined by
    RFC 8610 and RFC 9165.
    The latter has used the extension point provided in RFC 8610,
    the _control operator_.

    As CDDL is being used in larger projects, the need for corrections
    and additional features has become known that cannot be easily
    mapped into this single extension point.
    Hence, there is a need for evolution of the base CDDL
    specification itself.

    The present document defines a backward- and forward-compatible
    way to add a module structure to CDDL.

[^status]

[^status]: Previous versions of the changes in this document were part
    of draft-bormann-cbor-cddl-2-draft and previously
    draft-bormann-cbor-cddl-freezer.
    This submission extracts out the functionality that is ready
    for WG adoption and further WG work.

--- middle

# Introduction

[^abs1-]

[^status]

[^seealso]

[^seealso]: Proposals for additional functionality that needs more
    work can be found in {{-cddl-2-draft}}.  Proposals for other
    additions to the CDDL specification base are in {{-freezer}}.

The present document is intended to be the specification
base of what has colloquially been called CDDL 2.0, a term hat is now
focusing on module structure (other documents make up what is now
called CDDL 1.1).
Additional documents describe further work on CDDL.

## Conventions and Definitions

The Terminology from {{-cddl}} applies.

{::boilerplate bcp14-tagged}


Module superstructure
=====================

*Compatibility*:
: bidirectional (both backward and forward)

Originally, CDDL was used for small data models that could be
expressed in a few lines.  As the size of data models that need to be
expressed in CDDL has increased, the need to modularize and re-use
components is increasing.

CDDL 1.0 has been designed with a crude form of composition:
Concatenating a number of CDDL snippets creates a valid CDDL data
model unless there is a name collision (identical redefinition is
allowed to facilitate this approach).
With larger models, managing the name space to avoid collisions
becomes more pressing.

The knowledge which CDDL snippets need to be concatenated in order to
obtain the desired data model lives entirely outside the CDDL snippets
in CDDL 1.0.
In CDDL 2.0, rules are packaged as modules and referenced from other
modules, providing methods for control of namespace pollution.

Further work may be expended on
unambiguous referencing into evolving specifications ("versioning")
and selection of alternatives (as was emulated with snippets in
{{Section 11 of ?RFC8428}}.  Note that one approach for expressing
variants is demonstrated in {{useful}} based on {{Section 4 of RFC9165}}).
See also {{Section 4 of -cddl-2-draft}}.

Compatibility
-------------

To achieve the module structure in a way that is friendly to
existing environments that operate with CDDL 1.0 snippets and CDDL 1.0
implementations, we add a super-syntax (similar to the way pragmas
are often added to a language), by carrying them in what is
parsed as comments in CDDL 1.0.

This enables each module source file to be valid CDDL\ 1 (but
possibly needing to add some rule definitions imported from other
source files).


Namespacing
-----------

When importing rules from other modules, there is the potential for
name collisions.  This is exacerbated when the modules evolve, which
may lead to the introduction of a name into an imported module that is
also used (likely in a different way) in the importing module.

To be able to manage names in such a way that collisions can be
avoided, we introduce means to prepend a prefix to the names of rules
being imported: the "as" clause.

"Directives", the "module"
------------

This specification introduces *directives* into CDDL.
A single CDDL file becomes a *module* by processing the (zero or more)
directives in it.

The semantics of the module are independent of the module(s) using it,
however, importing a module may involve transforming its rule names
into a new namespace ({{namespacing}}).

Directives look like comments in CDDL 1, so they do not interfere
with forward compatibility.

Lines starting with the prefix `;#` are parsed as directives in CDDL 2.0.

Naming and Finding Modules
---------------

We assume that module names are filenames taken from one of several
source directories available to the CDDL 2.0 processor via the
environment.
This avoids the need to nail down brittle pathnames or (partial?) URIs
into the CDDL files.

The exact way how these source directories and possibly a precedence
between them are established is intentionally not fully defined in
this specification; it is expected that this will be specified in the
context of the models just as the way they are intended to be used
will be.  (A more formal structure may follow later.)

In the CDDL 2.0 Tool described in {{cddlc-tool}}, the set of sources is
determined from an environment variable, `CDDL_INCLUDE_PATH`, which is
modeled after usual command-line search paths.
It is a colon-separated list of pathnames to directories, with one
special feature: an empty element points to the tool's own collection.
This collection contains fragments of extracted CDDL from published
RFCs, using names such as `rfc9052`.

(Future versions might augment this with Web extractors and/or ways to
extract CDDL modules from github and from Internet-Drafts; see
{{Appendix A.2 of -cddl-2-draft}} for some design considerations.)

The default `CDDL_INCLUDE_PATH` is:

~~~
.:
~~~

That is: files are found in the current directory (`.`) and, if not
found there, cddlc’s collection.

In the examples following, a cddlc command line will be shown
(starting with an isolated `$` sign) with the CDDL 2.0 input; the
resulting CDDL 1 will be shown separately.

Basic Set of Directives {#directives}
-------------------------

Two groups of directives are defined at this point:

* `include`, which includes all the rules from a module (which
  includes the ones imported/included there, transitively), or
  specific explicitly selected rules (clause ending in "from");

* `import`, which includes only those rules from the module that are
   referenced, implicitly or explicitly (clause ending in "from"), including the
   rules that are referenced from these rules, transitively.

The `include` function is more useful for composing a single model
from parts controlled by one author, while the `import` function is
more about treating a module as a library:

{::include code/simple-import.md}

This is appropriate for using libraries that are well known to the
importing specification.
However, if it is not acceptable that the library can pollute the
namespace of the importing module, the import directive can specify a
namespace prefix ("as" clause):

{::include code/namespaced-import.md}

Note how the imported names are prefixed with `cose.` as specified in
the import directive, but CDDL prelude ({{Appendix D of -cddl}}) names
such as `tstr` and `any` are not.

Explicit selection of names
---------------------------

Both `import` and `include` directives can be augmented by an explicit
mentioning of rule names (clause ending in "from").

### `include`
{:unnumbered}

Starting with `include`:

{::include code/includefrom.md}

The module from which rules are explicitly imported can be namespaced:

{::include code/includefrom-namespaced.md}

### `import`
{:unnumbered}

Both examples would work exactly the same with `import`, as the
included rules do not reference anything else from the included
module.

An import however also draws in the transitive closure of the rules
referenced:

{::include code/importfrom-namespaced.md}

The `import` statement can also request an alias for an imported name:

{::include code/importfrom-renamed.md}

Tool Support for Command-Line Control
------------------

Tools may provide a convenient way to initiate the processing of
directives from the command line.

{::include code/zero.md}

In other words, the module synthesized from the command line had an
empty CDDL file, which therefore was not provided (no `–` on the
command line).


# Security Considerations

The module structure specified in this document is not believed to
create additional security considerations beyond the general security
considerations in {{Section 5 of -cddl}}.

Implementations that employ the module structure defined in this
document need to ascertain the provenance of the modules they combine
into the CDDL models they employ operationally.
This specification does not define how the source directories accessed
via the CDDL_INCLUDE_PATH are populated; this process needs to undergo
the same care and scrutiny as any other introduction of source code
into a build environment.


# IANA Considerations

This document has no IANA actions.


--- back

ABNF Specification
=================================

TO DO

~~~ abnf
directive = ";#" RS (%s"import" / %s"include") RS [from-clause]
                    filename [as-clause] CRLF
from-clause = 1*(id [","] RS) %s"from" RS
as-clause = RS %s"as" RS id
filename = 1*("-" / "." / %x30-39 / %x41-5a / "_" / %x61-7a)
id = ("$" / %x40-5a / "_" / %x61-7a)
     *("$" / %x30-39 / %x40-5a / "_" / %x61-7a)
RS = 1*WS
WS = SP
SP = %x20
CRLF = %x0A / %x0D.0A
~~~

A CDDL 2.0 Tool {#cddlc-tool}
===============

This appendix is for information only.

A rough CDDL 2.0 tool is available {{cddlc}}.  It can process CDDL 2.0
models into CDDL 1 models that can then be processed by the CDDL
tool described in {{Appendix F of -cddl}}.

A typical command line involving both tools might be:

~~~
cddlc -2 -tcddl mytestfile.cddl | cddl - gp 10
~~~

Install on a system with a modern Ruby (Ruby version ≥ 3.0) via:

    gem install cddlc

The present document assumes the use of `cddlc` version 0.1.6.


# Acknowledgments
{:numbered="false"}

TODO acknowledge.
