# ehtml(n) Design Notes

ehtml(n) is a macroset(i) for macro(n) that supports writing rich text
in an HTML-like language.  Macro(n), in turn, is based on the Tcllib 
texutil::expander package.  This file discusses solutions to ehtml(n)
design problems.

## Problems

### deflist/def* and empty dd tags

The `def*` family of tags inserts a `<dt>...</dt>` pair followed by a
`<dd>` tag, which is never closed.  In the current manpage(n) processor,
htmltrans(n) is used to close the tag after macro expansion is complete.

We will sometimes stack several `<defitem>` tags with a single description.
Now that the `<dd>` tag is closed, we get a blank line displayed between
the `<dt>...</dt>`'s, which looks bad.  The question is how to fix it.

#### Option 1: Add def*- macros

One option is a parallel set of macros, e.g., `<defitem->`, that insert
the `<dt>...</dt>` content but no `<dd>` tag.  You'd get code that looks
like this:

```
<deflist foo>
<defitem- this {<i obj> this}>
<defitem that {<i obj> that}>
These subcommands are delegated to the object's <xref whatsit(n)>
component.

</deflist foo>
```

The "-" in "defitem-" was chosen because of the use of the "-" in the Tcl
switch statement for dropping through cases.

I don't much like this; it seems like a bandaid.

#### Option 2: Modify the def* syntax

That is, allow one `<defitem>` or `<defopt>` or `<def>` to define multiple
items.  The `<dd>` is emitted after the last item in the set.

```
<deflist foo>
<defitem {
    this {<i obj> this}
    that {<i obj> that}
}>
</deflist foo>
```

This is better; it's more obvious what's going on, and there's no 
need to define new macros.

#### Option 3: Fix the @&!$%# Problem!

The `<def*>` family of macros really ought to be managing the `<dd>` tag
such it is closed properly: it should detect when a new definition begins,
and close the previous definition if any.  And if it's closing the previous
definition, it can do it in such a way that empty `<dd>...</dd>`'s are 
removed.  This will require some serious expander-fu, using the expander's
context stack in a sophisticated way.

Note that Option 3 could be used in conjunction with Option 2.