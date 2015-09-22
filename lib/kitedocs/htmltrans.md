# htmltrans(n) Paragraphing Notes

With regard to tracking context for the purpose of automatic paragraph
detection.<p>

## Element Contexts

Each element establishes a context that determines what we can expect,
and what we do with it.

### OPAQUE Context

Tags that seldom or never contain paragraphable prose define the 
OPAQUE context.  The `head` tag has the OPAQUE context.  Such elements
are copied to the output in their entirety unchanged.  The following 
tags define an OPAQUE context.

* applet/
* audio/
* area
* base
* basefont
* button/
* canvas
* col
* colgroup/
* datalist/
* embed
* head/
* hr/
* iframe/
* img
* input
* keygen
* link
* map/
* menu/
* menuitem/
* meta
* object/
* optgroup/
* option/
* output/
* param
* progress/
* rp/
* rt/
* ruby/
* script/
* select/
* source
* style/
* textarea/
* title/
* track
* video/

### STRUCTURAL Context

The STRUCTURAL context is set by tags that should only contain other
element, e.g., `table`.  All prose should be within child elements.  In
the STRUCTURAL context, text blocks are copied to the output unchanged.

The following tags introduce STRUCTURAL context:

* dir/
* dl/
* fieldset/
* frameset/
* html/
* nav/
* ol/
* table/
* tbody/
* tfoot/
* thead/
* tr/
* ul/

### TEXTONLY Context

In the TEXTONLY context, the input can contain text blocks and prose
tags; the enclosing element implicitly encloses a single paragraph.
No other tags are allowed, and blank lines have no special
meaning.  The following tags introduce TEXTONLY context:

* caption/
* dt/
* figcaption/
* h1/
* h2/
* h3/
* h4/
* h5/
* h6/
* label/
* legend/
* pre/
* summary/


### PARAGRAPH Context

In PARAGRAPH context we are in a paragraph and need to close the paragraph
at the next blank line or non-prose tag.  On blank line, we immediately
open a new paragraph.

We enter PARAGRAPH context at the first non-whitespace text block 
or explicit `p` tag in BLOCK or TEXTBLOCK context.

### BLOCK Context

The BLOCK context is set at the beginning of the input, by the `body` tag,
and by any other tag that can contain any mixture of paragraphs 
and structural elements (e.g., `section`).

In BLOCK context we accept any tag, and text blocks.  The tags
introduce the contexts they introduce.  Non-whitespace text blocks 
cause the insertion of a `p` tag and a transition to PARAGRAPH context.

The following tags introduce the BLOCK context

* Beginning of input
* article/
* aside/
* body/
* details/
* dialog/
* div/
* figure/
* footer/
* form/
* frame/
* main/
* noframes/
* noscript/
* section/

### TEXTBLOCK Context

The TEXTBLOCK context is set by tags that can contain any context but
usually consist of one paragraph's worth of text.  If the input proves
to contain non-prose tags or more than one paragraph of text, context
switches to BLOCK context instead, and we enter the context for the 
thing we found.

The following tags introduce the TEXTBLOCK context:

* blockquote/
* center/
* dd/
* li/
* td/
* th/

## Prose Tags

The following tags can be used in TEXTONLY and PARAGRAPH context
without terminating the context, and can also start a new paragraph
in BLOCK context.  They have no context of their own.

* a/
* abbr/
* acronym/
* address/
* b/
* bdi/
* bdo/
* big/
* br
* cite/
* code/
* del/
* dfn/
* em/
* font/
* i/
* ins/
* kbd/
* mark/
* meter/
* q/
* s/
* samp/
* small/
* span/
* strike/
* strong/
* sub/
* sup/
* time/
* tt/
* u/
* var/
* wbr
