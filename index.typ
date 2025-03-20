#import "@local/catppuccin:1.0.0": catppuccin, flavors
#import "@preview/touying:0.6.1": *
#import "@preview/cetz:0.3.4"
#import "@preview/fletcher:0.5.7"
#import themes.simple: *

#let info = config-info(
  title: "Git From Scratch",
  subtitle: "A bottom-up approach to learning Git",
  author: "Ben C",
  institution: "West Chester University Computer Science Club",
)

#let cetz-canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)
#let fletcher-diagram = touying-reducer.with(
  reduce: fletcher.diagram,
  cover: fletcher.hide,
)

#let catp = flavors.mocha
#let colors = catp.colors
#show: simple-theme.with(
  info,
  header: self => [*#self.info.title*],
  footer: self => self.info.author,
  aspect-ratio: "16-9",
  primary: colors.blue.rgb,
)
#show: catppuccin.with(catp, code-block: true, code-syntax: true)
#show quote.where(block: true): block.with(
  stroke: (left: 4pt + colors.mauve.rgb, rest: none),
)
#show raw.where(block: false): box.with(
  fill: colors.crust.rgb,
  inset: (x: 3pt, y: 0pt),
  outset: (y: 3pt),
  radius: 2pt,
)
#show raw.where(block: true): block.with(
  fill: colors.crust.rgb,
  inset: 10pt,
  radius: 4pt,
)

#let secondary(c) = {
  text(rgb("#F75C2F"), box[ #c ])
}

#let mono(c) = {
  text(box[ #c ], font: "DejaVu Sans Mono", size: 20pt)
}

#let acc1(c) = {
  text(colors.mauve.rgb, mono[ #c ])
}

#let acc2(c) = {
  text(colors.green.rgb, mono[ #c ])
}

#let acc3(c) = {
  text(colors.yellow.rgb, mono[ #c ])
}

#let acc4(c) = {
  text(colors.red.rgb, mono[ #c ])
}

#let acgrey(c) = {
  text(colors.subtext0.rgb, mono[ #c ])
}

= #image("git-logo.svg", width: 25%, alt: "The Git Logo")\ *Git From Scratch*\ #acc1[--]#acc2[--]#acc3[--]#acc4[--]

#emph[#secondary[A bottom-up approach to learning Git]]

== What is Git?
<what-is-git>

Git is a distributed version control system that allows multiple
developers to collaborate on a project without needing a central server
to do so.

It’s the de facto standard in both open source and enterprise contexts.
No matter what field of CS you choose to pursue you’ll likely
encounter Git.

== How does it Work?
<how-does-it-work>

At a very high level:

- Git allows you to take "snapshots" of your current project \(*commits*)
- Commits are chained together to create a history \(*branches*)
- Developers can create multiple branches to work on the project
  simultaneously
- After work is done, developers *merge* changes back to a common branch

== Okay, But How does it #emph[actually] work?
<okay-but-how-does-it-actually-work>

You came to the right place!

The Git CLI is split up into two types of commands.

- "Porcelain" commands, the ones you’re likely to have used \(`commit`,
  `add`, `checkout`, etc)
- #strong["Plumbing"] commands, low-level commands that porcelain
  commands call under-the-hood \(we’ll see these later)

== Why Should We Care About Plumbing?

#quote(block: true)[
  Magic isn't real \
  -- Preston Thorpe
]

To truly understand something, we need to forego all notions of "magic". Don't
be scared to jump into the details, understand things for what they truly
are and you'll grow an intuition instead of surface-level knowledge. Many times
it's a lot simpler than you think!

== Git Repository Structure
<git-repository-structure>

A Git repository is any directory with a well-formed `.git/` folder.
This presentation is stored in a repository!

`.git` stores all of your repository’s history, including commits,
branches, tags, etc. The folder containing `.git/` will read and
information from `.git/` when you run various Git commands.

== `.git` Layout
<-git-layout>

`.git/` is comprised of many items, we’ll focus on a smaller subset of
them.

- `objects/`: The object store, the most important part of `.git`
- `refs/`: A list of references to objects in the object store
- `HEAD`: A symbolic ref that points to the current working branch
- `config`: A configuration file for this repository

We’ll start out with the object store and explain `refs` later.

== The Object Store
<the-object-store>

#strong[Objects] are the building blocks of Git, they’re the storage
mechanism for many Git concepts.

- Files \(Blobs)
- Directories \(Trees)
- Commits
- … and more!

== Object Hahing And Storage

Objects are *content-addressed* within the `objects/` directory. To
get the "name" of an object we get the SHA-1 hash of that object’s contents.
This hash serves as a unique identifier for that object, any references
to it will use this hash.

To store an object, Git will take the #strong[first two] characters of
the hash and create a folder with them, and then place the object data
in a file names with the rest of the hash.

== Object Hashing Example
<object-hashing-storage>

The silly cat is hashed into:\
#acc1[9a]#acc2[143d55e1bf0e61c61def985dade29d8ed53d85].

That hash is split up.

- #acc1[9a] becomes the name of a folder in `.git/objects/`
- #acc2[143d55e...] becomes a file in that
  folder, storing the cat inside
- So our full path to the object will be
  .git/objects/#acc1[9a]/#acc2[143d55e...]

== Anatomy of an Object
<anatomy-of-an-object>

#slide[
  Each Git object will start with important pieces of metadata.

  + #acc1[type] of the object, followed by an ASCII space
  + #acc2[size] of the object, encoded as a string \(#emph[not] just the number
    in binary), followed by #acgrey[\\0 ] \(the null terminator)
  + #acc3[data] the object contains

  #pause

][
  Let’s consider an object with the contents #acc3[Hello World!]

  #mono[#acc1[blob] #acc2[12]#acgrey[\\0]#acc3[Hello World!]]
]

== Important Notes About Object Storage

- An object's hash _includes_ the metadata header, it's critical we add this or all
  the hashes will be wrong!

#pause

- Git stores objects by zlib compressing them to save space, so you can't simply read this
  data with `cat`

== Types of Objects
<types-of-objects>

There are four major types of objects that Git stores.

+ Blobs - Normal files, like that silly cat picture from before
+ Trees - Directories containing blobs or other trees
+ Commits - Hold a reference to a tree and metadata
+ Tags - Static pointers to commits that can be signed cryptographically

We’ve already seen blobs before, with the "Hello World!" example.

== Blob Objects

*Blobs* are the simplest type of objects and simply store data
verbatim within them.

#acc1[blob] #acc2[12]#acgrey[\\0]#acc3[Hello World!]

Most often blobs are used to store file data directly, any text files, pictures,
etc. will be serialized and stored as a blob object.

Other types of objects get a bit more complicated.

== Tree Objects
<tree-objects>

*Trees* are the next level up from blobs, they store a directory of files
and other trees. A tree is to a blob as a folder is to a file.

A tree starts with the same metadata all git objects have, and is then
followed with a structured list of #emph[leaves];.

== Tree Leaves

A *leaf* stores three pieces of information.

+ #acc1[mode] of the leaf \(permissions) followed by an ASCII space
+ #acc2[name] of the leaf \(file name or sub-folder name), followed by #acgrey[\\0]
+ #acc3[hash] of the object containing this leaf’s contents

== Tree Object Example

Let’s consider a tree of a few of this repo's files.

(remember: #acc1[mode] #acc2[name]#acgrey[\\0]#acc3[hash])

- #acc1[100644] #acc2[flake.lock]#acgrey[
    \\0
  ]#acc3[824729cbedb829dea0442ab10905e32c57eee92d"]
- #acc1[100644] #acc2[flake.nix]#acgrey[
    \\0
  ]#acc3[9280a82b299c535128ff06098d8e5b68a64032e2]
- #acc1[040000] #acc2[nix]#acgrey[
    \\0
  ]#acc3[1426b63b66a8de0e2769ae7573c2918e60d84187]

Here we can see two files and one subdirectory stored. Git can also store symlinks
and submodules in trees.

== Side Tangent - Self-referential Tree
<side-tangent---self-referential-tree>

Tree objects can reference other trees. What would happen if a tree referenced _itself_?".

Making a cycle in Git like this is an interesting feat. Think
about what that tree would look like, we’d need a leaf that
looks something like this:

- #acc1[100644] #acc2[myself]#acgrey[\\0]#acc3[\<the tree’s hash\>]

---

But we don’t know the hash of our tree, how can we reference it? The correct hash
depends on us knowing the hash!

If we edited the Git source code in some way that allowed us to
reference a tree within itself \(someone did this by using a weaker
hashing algorithm and brute-forcing the hash), Git will segfault (crash).

However, because Git uses SHA-1 which is good enough™, we can be sure
that tree objects will never contain cycles.

== The Git Index - How `git add` works
<the-git-index---how-git-add-works>

When staging changes in Git via `git add` your files are added to a
special file, `.git/index`. This file keeps track of staged changes in
your working tree and is used by Git to create a tree object when
committing.

You can manually add files to the index via `git update-index --add`.
This command acts as a backend to the `git add` and `git rm` commands.

== Another Side Tangent - Content Addressed Storage is Awesome
<another-side-tangent---content-addressed-storage-is-awesome>

We address objects based on that object’s contents.
A tree’s contents contains references to other objects,
meaning we by extension address a tree by the contents of all of its leaves.

Subtrees cascade this effect upwards. We can uniquely identify the
contents of a directory #emph[and all sub-directories] based on its
hash.

This #emph[does] mean whenever we update even one part of our project,
we’ll likely have to recompute hashes for many different objects.

== Commit Objects
<commit-objects>

A *commit* marks a tree object with a message, author, time,
and even cryptographic signatures. Commits can store any arbitrary data but we'll
stick to common fields.

The format starts out with a series of newline-delimited
*headers*. Each header consists of a #acc1[name], a space, and then a
#acc2[value]. Following these headers are #emph[two] newlines and then the
commit’s #acc3[message].

== Example Commit

Let’s look at an example commit.

#acc1[tree] #acc2[a4177e2da6416bb490b75e9538f80251e81d820a] \
#acc1[parent] #acc2[f8d431b5019ec9b6800e2591f3df11adcdffa734] \
#acc1[author] #acc2[Ben C \<bwc9876\@gmail.com\> 1742067179 -0400] \
#acc1[committer] #acc2[Ben C \<bwc9876\@gmail.com\> 1742067179 -0400] \
#acc1[gpgsig] #acc2[—–BEGIN SSH SIGNATURE—– U1NIU0l...] \
\
#acc3[Update README]

== Commit Object Headers
<commit-object-headers>

Here’s what each header means in this commit object.

- `tree`: The tree object this commit points to
- `parent` \(optional): The parent\(s) of this commit \(previous commit)
- `author`: Who authored the changes this commit does \(can have
  multiple)
- `committer`: The person who created the commit object
- `gpgsig` \(optional): A cryptographic signature to verify the
  committer

Commits can contain more data as well, but these are the most common.

== Loose vs.~Packed Objects
<loose-vs.-packed-objects>

When you change a file and commit it, Git will create a new, separate object
for the new state of the file. For large files, this can waste a lot of
space if you just change a few lines of a giant file.

Git will occasionally \(usually when pushing) #emph[pack] objects,
storing diffs between two file states instead of duplicating the contents. This
presentation won’t get into the technical part of this as Git handles it
transparently. You can also have Git manually pack all objects by running
`git gc`.

== Refs
<refs>

Refs are references to objects within the object store. Many
higher-level Git concepts such as branches and tags are stored as refs.

Refs are primarily stored in `.git/refs`, each ref file is simply a text
file containing the object hash that the ref points to.

Primarily refs point to commit objects, both branches and tags work this
way. However, tags can technically point to any object, this isn't
usually used however.

== Branches vs.~Tags
<branches-vs.-tags>

- #strong[Tags] represent static points in time for a project, this is
  used for marking certain versions or releases
- #strong[Branches] represent sliding pointers to different states of a
  project, showing in-progress changes

Tags can also be a bit fancier than branches, they can point to
#strong[tag objects]. Tag objects are similar to commits, but a little different
in format.

== Tag Objects

Tag objects add additional metadata to a tag, kind of like a simpler commit.
Notice how the #acc4[GPG signature] is appended after the message.

#acc1[object] #acc2[2572bbd459e4972ba4a4e0f4f4fd5d7e286b84d0] \
#acc1[type] #acc2[commit] \
#acc1[tag] #acc2[v0.5.3] \
#acc1[tagger] #acc2[Ben C \<bwc9876\@gmail.com\> 1742067179 -0400] \
\
#acc3[v0.5.3 - Fix a bunch of bugs!] \
#acc4[—–BEGIN SSH SIGNATURE—– U1NIU0...]

== Symbolic Refs and `HEAD`
<symbolic-refs-and-head>

Another type of ref is a #emph[symbolic] ref, these refs can only ever
point to other refs. The most common example of this is `HEAD`, stored
in `.git/HEAD`.

`HEAD` points to the #emph[head] \(latest commit object) of the current
branch you have checked out. You can run `git symbolic-ref .git/HEAD` to view this,
if you were on branch `main` it would output `refs/heads/main`.

---

While symbolic refs may not point to non-refs. `HEAD` can instead be normal ref instead of symbolic,
poining to a commit object.

This creates a "Detached `HEAD`" state, which means commits we make won’t affect any specific branch.
You may find yourself on this state when switching branches and making a mistake. Not to worry! You
can always go back to your main branch with `git checkout main`.

== Rev Parse
<rev-parse>

Often times when working with Git porcelain commands you’ll be told to
enter a commit-ish or a tree-ish value.

- #emph[tree];-ish: A reference to a tree object, this includes a named
  ref, a tag object, or a commit object
- #emph[commit];-ish: Reference to a commit object, this can be a ref or
  a tag object as well

If you’re ever curious how Git will resolve a given value, you can use
the `rev-parse` command to see what Git evaluates it as. `rev-parse`
will output the object hash that the given string points to.

---

Here are some useful tips for referring to objects.

+ You can refer to the tree of a commit directly by appending `^{tree}`,
  so `HEAD^{tree}` would be the tree object of the current branch’s
  head.
+ You can refer to a given commit’s parent by using `~`, doing multiple
  `~`’s will go back further. You can even put numbers after the `~` to
  specify how many parents to jump back. For example
  `git checkout HEAD~` will checkout commit #emph[before] the current
  one.

== How `git commit` Works

+ Add files for staging \(`git update-index --add`)
+ Create a new `tree` from the index \(`git write-tree`)
+ Grab the previous commit \(if it exists) from `HEAD`
  \(`git rev-parse HEAD`)
+ Create a new commit, pointing to the new tree object, and with the
  `parent` set to the previous commit (if it exists).
  \(`git commit-tree [tree] -p [parent]`)
+ Update the branch that `HEAD` references to point to our new commit
  object \(only if `HEAD` actually points to a branch)
  \(`git update-ref HEAD [new commit]`)

== Combining Branches - Merging

Often times we'll want to take changes from one or more branches and apply
them to the current one.

One way of doing this is a *merge* commit. This is a commit that will have
two parents, the head of the current branch and the head of the other branch.

If two branches share a common history and one is simply behind the other,
a *fast-forward* occurs. This doesn't create a new commit and simply sets
the "behind" branch to point to the head of the source branch.

== Combining Branches - Rebasing

An alternative way to combine branches is a *rebase*. Rebasing simply applies commits
from one branch to another, without making a merge commit. This is effectively just copying
and pasting changes from one branch to another.

Rebasing can do a lot more than just combine branches however. Another common use case
is to squash a set of commits into one, cleaning up your history. A very user-friendly way
to do complex rebasing is `git rebase -i [some commit]`. This will open up an editor that lets
you interactively rebase the commits specified.

== Restore vs.~Reset vs.~Revert
<restore-vs.-reset-vs.-revert>

These three commands are often confused with eachother and it can be a
bit difficult to tell exactly what they do without knowing Git’s
underlying system.

Some important terms:

- `HEAD`: the current head of the branch your working on
- index: the staging area that files get added to with `git add`
- working tree: the current structure of your project, unstaged changes

---

With this in mind let’s break down each command.

- `git restore`: This command will update files in your working tree
  with data from your index
- `git restore --staged`: This command updates your index from the
  `HEAD` or any given commit

---

- `git reset [path]`: This command also updates your index from a
  commit, `restore --staged` is the newer interface
- `git reset [commit]`: This command will set `HEAD` to a given commit,
  along with the index
  - `git reset --soft`: Don’t update the index, only update `HEAD`
  - `git reset --mixed`: Update the index and `HEAD` \(default)
  - `git reset --hard`: Also update the working tree, meaning a
    #strong[FULL] reset to `[commit]`
- `git revert`: Create a new commit that undoes the changes a previous
  commit made

== Remote Refs
<remote-refs>

A set of branches kept in sync from a different machine is called a remote.
Remotes are listed in `.git/refs/remotes`, and will be synced according
to the #emph[refspec] present in `.git/config`.

Refspecs follow the format +#acc1[\<SRC\>]:#acc2[\<DEST\>].

- #acc1[\<SRC\>] denotes the relative path on the remote server to grab a ref
  from
- #acc2[\<DEST\>] denotes where to save the ref locally

---

Let’s see an example of how this looks in a config file. You’ll also
notice the #acc4[name] of the remote and the #acc3[url] of the remote.

#mono[
  \[remote "#acc4[origin]"\] \
  url \= #acc3[git\@github.com:Bwc9876/nixos-config.git] \
  fetch \= +#acc1[refs/heads/\*]:#acc2[refs/remotes/#acc4[origin]/\*]

  Here we see that all refs under #acc1[refs/heads/\*] on
  #acc3[git\@github.com:Bwc9876/nixos-config.git] will be placed in
  #acc2[refs/remotes/#acc4[origin]/\*] locally.
]

---

Note that remote refs are _read-only_, we never move them locally. Remote refs are
a way of seeing what the refs were set to the last time we *fetched*.

To update remote refs from their respective remote, we run the `git fetch` command.
This will download any needed objects automatically and update the remote ref to
point to the latest commit.

== Tracking Branches
<tracking-branches>

Tracking branches are a config option that let you indicate that a #acc2[local
branch] should be kept in sync with a #acc1[remote one] on a specified #acc3[remote].

#mono[
  [branch "#acc1[main]"] \
  remote = #acc3[origin] \
  merge = #acc2[refs/heads/main] \
]

Here we see a rule to make #acc2[refs/heads/main] track #acc3[origin]/#acc1[main] by
_merging_ changes from the remote to the local.

== How `git pull` and `git push` work

Tracking branches allow us to use `git pull` and `git push`.

When pulling:

- Update the remote ref that our local branch tracks (`git fetch`)
- Merge the newly updated remote ref into our local one (`git merge`)

Depending on configuration, `pull` can also rebase the branch instead if desired.
It will also fast-forward automatically (if possible).

---

When pushing:

- Connect to the remote and upload any objects and update the ref on the server's side
- Update the remote ref on our side to reflect this change

== Conclusion

This presentation went over the main parts of Git inside and out. We learned about...

+ The object store
+ The types of objects (blob, tree, commit, tag)
+ The Git index
+ Refs and `HEAD`
+ Combining branches with `merge` and `rebase`
+ `restore`, `reset`, and `revert`
+ Remote refs and tracking branches

== References and Resources

Thank you for listening!

- Pro Git: #link("https://git-scm.com/book/en/v2")
- Write Yourself a Git!: #link("https://wyag.thb.lt/")
- Magic Isn't Real: #link("https://pthorpe92.dev/magic/")
