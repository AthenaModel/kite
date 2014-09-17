# test_new.tcl

package require kitedocs
namespace import kiteutils::* kitedocs::*

macro mp

mp register ::kitedocs::ehtml
::kitedocs::ehtml manroots {:n ./man%s/%n.html}
mp reset

puts [mp expand [outdent {
    Change Log:

    <changelog>
    <change 1/01/14 Update WHD>
    This is the first change.
    </change>

    <change 2/02/14 Change WHD>
    This is the second change.
    </change>
    </changelog>

    HRule:    <hrule>
    Brackets: <lb>tag<rb>
    Link 1:   <link http://my.example.com>
    Link 2:   <link http://my.example.com "My Link Text">
    NBSP:     <nbsp "Some text with spaces.">
    Quote:    <quote "<this> & <that>">
    Bold 1:   <b This is bolded>
    Bold 2:   <b>And this is bolded</b>
    Image:    <img src="foo/bar/baz.png">

    Xref 1:   <xref myref>
    Xref 2:   <xref myref "Another Ref">
    XrefSet:  <xrefset myref "My Ref" http://myref.example.com>
    XrefMan:  <xref myman(n)>
}]]