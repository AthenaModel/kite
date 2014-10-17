# Managing External Documents

The problem is this: there are many important Athena documents that are in
binary formats and so don't belong in a Git repository.  On the other hand,
they ARE tied to particular versions of the software.  They need to be
included in distributions and in the Windows installer.

* Boxkite provides a way to tie binary documents to a specific project's X.Y
  version and a date, and to make them available on the web.

* Distribution sets can "%get" files from the web; this makes it easy to
  include the correct version of the document into a distribution set.

* If you just want to edit the file, you can use Boxkite to pull it into
  {root}/docs, edit it there, and push it back to the server.
  * The .gitignore can be set to ignore these binary files, so we don't
    check them in accidentally.

* However, the InnoSetup installer builder doesn't use our distribution sets,
  and can't pull files from the web. (Or can it?)

In short, building the Windows installer, already a manual process, becomes
a pain.  What can we do about this?  

# Conclusion

See the discussion, below, under "Options".

We want to use Option 3:

* It specifies the required documents precisely.
* It allows them to be pulled into the tree on demand.
* It allows them to be pulled into the tree automatically as part of a 
  build.
* It simplifies the distribution sets.
* It makes the documents available to the installer.

# Options

I see these options.  One thing to remember: during development we usually
want the latest version of the document, but not necessarily; and if we're
replicating an older build we want the specific version we had before.
The dist set "%get" method allows this.

## Option 1: Full Manual

The build procedure directs the user to use boxkite explicitly to pull in the
required binary documents, so that they are in {root}/docs and can be seen
by the InnoSetup installer builder.  It's up to the user be sure he gets
the right versions, as indicated in the distribution sets.

## Option 2: Semi-Automatic

We write a script in {root}/bin that grabs the needed binary docs into 
{root}/docs.  The build procedure directs the user to use this script
to pull in the documents.  Otherwise, this is the same as Option 1.

The script would need to reference the specific date-stamped versions;
which means that project.kite doesn't have all of the relevant metadata.

## Option 3: Automatic Docs

We add a statement to project.kite, xdoc, that tells Kite to pull in the
document from a URL.  Difficulty: when does it get pulled?  If on command,
what command pulls it?  'kite docs xdocs'?  'kite build all' for sure.

This option makes sure that we get the right date.  And then, the distribution
sets can simply include "*.docx", "*.pptx", etc., and get the version that
was pulled in.  That way, the URL doesn't get repeated in multiple 
distribution sets.

## Option 3b: Automatic Docs w/Boxkite

We add a statement to project.kite, xdoc, that tells Kite to pull in the
document using a command; we set the command to 'boxkite docget'.

This is bad; it creates an unnecessary build-time dependency on the 
'boxkite" executable.

## Option 4: Automatic Docs and Automatic Installer

Use Option 3; and then automate the installer creation in src/installer.
The InnoSetup building has a command line tool.  Use templating to create
the installer script from a template, filling in the necessary data,
and then simply build it.

The problem here is that the installer needs to be built at the END, and
src directories are compiled at the BEGINNING.  We would need to generalize
the compile mechanism.

## Option 5: Installer Builder Web Access

If InnoSetup can pull files from the web, automate building the installer,
and put the relevant URLs into the installer script using a template.

This is an awful idea.  We'd need metadata telling us what the URLs are,
just as for Option 3; but if we have Option 3, there's no need for InnoSetup
to use the URLs.

# Questions:

**Q: Can InnoSetup pull files from the web and include them in an installer?**