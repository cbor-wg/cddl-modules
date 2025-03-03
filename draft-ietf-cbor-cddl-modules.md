---
v: 3

title: "CDDL Module Structure"
abbrev: "CDDL Module Structure"

docname: draft-ietf-cbor-cddl-modules-latest
stream: IETF
# updates: 8610
# date:
cat: std
consensus: true
area: "Applications and Real-Time"
workgroup: "CBOR Maintenance and Extensions"
keyword:
 - Concise Data Definition Language
venue:
  group: "CBOR Maintenance and Extensions"
  mail: "cbor@ietf.org"
  github: "cbor-wg/cddl-modules"
  latest: "https://cbor-wg.github.io/cddl-modules/draft-ietf-cbor-cddl-modules.html"

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
  -
    name: Brendan Moran
    organization: Arm Limited
    email: brendan.moran.ietf@gmail.com


normative:
  RFC8610: cddl
  RFC9165: control1
  STD68: abnf # RFC5234
  RFC7405: abnf-case

informative:
#  I-D.draft-bormann-cbor-cddl-freezer: freezer
  RFC9682: grammar
  I-D.ietf-cbor-cddl-more-control: control2
  I-D.bormann-cbor-cddl-2-draft: cddl-2-draft
  I-D.bormann-t2trg-deref-id: deref
  useful:
    target: https://github.com/cbor-wg/cddl/wiki/Useful-CDDL
    title: Useful CDDL
  cddlc:
    title: CDDL conversion utilities
    target: https://github.com/cabo/cddlc
  RFC9052: cose

--- abstract

[^abs1-]

[^abs1-]:
    At the time of writing,
    the Concise Data Definition Language (CDDL) is defined by
    RFC 8610 and RFC 9682 as well as RFC 9165.
    The latter has used the extension point provided in RFC 8610,
    the _control operator_.

    As CDDL is being used in larger projects, the need for
    features has become known that cannot be easily
    mapped into this single extension point.

    The present document defines a backward- and forward-compatible
    way to add a module structure to CDDL.

--- middle

# Introduction

[^abs1-]

The functionality of the present document is considered a core part of
what has colloquially been called CDDL 2.0, and is intended to be used
with (and orthogonal to) other recent specifications such as a small
set of CDDL grammar updates {{-grammar}} and an additional exercise of
the control operator extension point {{-control2}} (a follow-up to
{{-control1}}).

## Conventions and Definitions

The Terminology from {{-cddl}} applies.

Some examples use CDDL definitions from {{-cose}}.

{::boilerplate bcp14-tagged-bcp14}


Module superstructure
=====================

*Compatibility*:
: bidirectional (both backward and forward)

Originally, CDDL was used for small data models that could be
expressed in a few lines.  As the size of data models that need to be
expressed in CDDL has increased, the need to modularize and re-use
components is increasing.

CDDL as documented in {{-cddl}} (_basic CDDL_) has been designed with a crude form of composition:
Concatenating a number of CDDL snippets creates a valid CDDL data
model unless there is a name collision (_identical_ redefinition is
allowed to facilitate this approach).
With larger models, managing the overall name space to avoid collisions
becomes more pressing.

In CDDL's original composition model,
the knowledge which CDDL snippets need to be concatenated in order to
obtain the desired data model lives entirely outside the CDDL snippets.
With the module structure defined in the present document, rule sets are
packaged as modules and referenced from other
modules, providing methods for control of namespace pollution.

Further work may be expended on
unambiguous referencing into evolving specifications ("versioning")
and selection of alternatives (as was emulated with snippets in
{{Section 11 of ?RFC8428}}.  Note that one approach for expressing
variants is demonstrated in {{useful}} based on {{Section 4 of RFC9165}}).
Potential further work is outlined in {{Sections 4 and A.2 of -cddl-2-draft}}.

Compatibility
-------------

To achieve the module structure in a way that is friendly to
existing environments that operate with CDDL and basic CDDL
implementations, we add a super-syntax (similar to the way pragmas
are often added to a language), by carrying them in _directives_.
Directives are parsed as comments in basic CDDL, so that each module
source file can at the same time be basic CDDL on its own.
This enables forward compatibility: a single file can be designed to
serve both as valid basic CDDL and as a module with directives that
specify how additional rule definitions are to be imported from other
source files.

This bidirectional compatibility is useful to allow CDDL model
designers to start using directives before the bulk of the tools that
process CDDL has been updated to implement the present specification.


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

Directives are parsed as comments in basic CDDL, so they do not interfere
with forward compatibility.

In the CDDL module structure, lines that start with the prefix `;#` are
parsed as directives.

Naming and Finding Modules
---------------

We assume that module names are filenames taken from one of several
source directories available to the CDDL module structure processor via the
environment.
This avoids the need to nail down brittle pathnames or (partial?) URIs
into the CDDL files.

The exact way how these source directories and possibly a precedence
between them are established is intentionally not fully defined in
this specification; it is expected that this will be specified in the
context of the models just as the way they are intended to be used
will be.  (A more formal structure may follow later.)

In the module structure implementation that is part of the CDDL Tool
described in {{cddlc-tool}}, the set of sources is
determined from an environment variable, `CDDL_INCLUDE_PATH`, which is
modeled after usual command-line search paths.
It is a colon-separated list of pathnames to directories, with one
special feature: an empty element points to the tool's own collection.
This collection contains fragments of extracted CDDL from published
RFCs, using names such as `rfc9052`.

(Future versions might augment this with Web extractors and/or ways to
extract CDDL modules from sites such as github and from Internet-Drafts; see
{{Appendix A.2 of -cddl-2-draft}} for some design considerations.)

The default `CDDL_INCLUDE_PATH` is:

~~~
.:
~~~

That is: files are found in the current directory (`.`) and, if not
found there, cddlc’s collection.

In the examples that follow, a cddlc command line will be shown
(starting with an isolated `$` sign as in a shell command) with the
module-structured CDDL input; the
resulting basic CDDL will be shown separately.

Basic Set of Directives {#directives}
-------------------------

Two groups of directives are defined at this point:

* `include`, which includes all the rules from a module (which
  includes the ones imported/included there, transitively), or
  specific explicitly selected rules (clause ending in "from");

* `import`, which is similar to `include` but includes only those
   rules from the module that are
   referenced from the importing module, implicitly or explicitly
   (clause ending in "from"), including the
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
mentioning of rule names (clause ending in "from") or a wild-card
"`*`" for all rules.

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
empty CDDL file, which therefore was not provided (no `–` was given on
the command line).


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
into a build environment; the possibility of supply-chain attacks on
the modules imported needs to be considered.

Specifically, implementations that rely on model-based input
validation for enforcing certain properties of the data structure
ingested (which, if not validated, could lead to malfunctions such as
crashes and remote code execution) need to be particularly careful
about the data models they apply, including their provenance and
potential changes of these properties that upgrades to the referenced
modules may (inadvertently or as part of an attack) cause.
More generally speaking, implementations should strive to be robust
against limitations of the model-based input validation mechanisms and
their implementations that they employ.

In applications that dynamically acquire models and dereference module
references in these, the security considerations of dereferenceable
identifiers apply (see {{-deref}} for a more extensive discussion of
dereferenceable identifiers).

# IANA Considerations

This document has no IANA actions.


--- back

ABNF Specification
=================================

This section specifies the grammar employed by the module structure
directives using the ABNF language defined in {{-abnf}} and
{{-abnf-case}}.

~~~ abnf
directive = ";#" RS (%s"import" / %s"include") RS [from-clause]
                    filename [as-clause] CRLF
from-clause = 1*(id-or-all [","] RS) %s"from" RS
as-clause = RS %s"as" RS id
filename = 1*("-" / "." / %x30-39 / %x41-5a / "_" / %x61-7a)
id = ("$" / %x40-5a / "_" / %x61-7a)
     *("$" / %x30-39 / %x40-5a / "_" / %x61-7a)
id-or-all = id / "*"
RS = 1*WS
WS = SP
SP = %x20
CRLF = %x0A / %x0D.0A
~~~

A CDDL Tool that Implements CDDL Module Structure {#cddlc-tool}
===============

This appendix is for information only.

A CDDL conversion tool is available {{cddlc}} that can process
module-structured CDDL models into basic CDDL models; the latter can
then be processed by other CDDL tools such as the one described in
{{Appendix F of -cddl}}.

A typical command line involving both tools mentioned might be:

~~~
cddlc -2 -tcddl mytestfile.cddl | cddl - gp 10
~~~

The CDDL conversion tool can be installed on a system with a modern
Ruby (Ruby version ≥ 3.0) via:

    gem install cddlc

The present document assumes the use of `cddlc` of at least version 0.2.5.


# Acknowledgments
{:numbered="false"}

TODO acknowledge.
