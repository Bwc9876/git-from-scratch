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
You’ll encounter Git no matter what field of CS you choose to pursue.

== How does it Work?
<how-does-it-work>

Git has a very high-level interface that you may have used already.

- Git allows you to take "snapshots" of your current project \(*commits*)
- Commits are chained together to create a history \(*branches*)
- Developers can create multiple branches to work on the project
  simultaneously
- After work is done, developers *merge* changes back to a common branch

Don't worry if you don't recognize these concepts, we'll come back to them
later.

== Okay, But How does it #emph[actually] work?
<okay-but-how-does-it-actually-work>

You came to the right place!

The Git command line interface (CLI) is split up into two types of commands.

- *Porcelain* commands are high-level user-friendly commands. These are ones you’re likely to have used \(`commit`,
  `add`, `checkout`, etc)
- *Plumbing* commands are low-level commands that porcelain
  commands call under-the-hood.

== Why Should We Care About Plumbing?

Git is a complicated system. Complicated systems can often be explained well with high-level abstractions and analogies.

// TODO: Articulating how high-level guides can fall short in this paragraph

However, the abstractions provided by many teaching materials with Git can often fall short. Misunderstandings
of how Git works at a fundamental level results in a few pitfalls, which can lead to mistakes.

To make a mistake is to potentially lose extremely important work or project history. To avoid these mistakes, this presentation will try to teach you the underlying concepts in Git and build up from there.

== Git Repositories
<git-repository-structure>

Any directory with a well-formed `.git/` folder is a *git repository*. You'll work on the current
content of the directory when programming.

`.git` is a special folder however, it stores all of your repository’s history. `.git ` is written to and read
from when you use various Git commands.

== `.git` Layout
<-git-layout>

`.git/` is comprised of many items, we’ll focus on a smaller subset of
them.

- `objects/`: A database of objects that acts as a single source of truth
- `refs/`: A list of references to objects in the object store
- `HEAD`: A symbolic ref that points to the current working branch
- `config`: A configuration file for this repository

We’ll start out with the object store.

== Git Objects
<the-object-store>

#strong[Objects] are the building blocks of Git, they’re the storage
mechanism for many Git concepts.

- Files \(Blobs)
- Directories \(Trees)
- Commits
- … and more!

Objects are stored within `.git/objects`. They use a *content-addressed* storage
structure.

== Content Addressed Storage

Objects are *content-addressed* within the `.git/objects/` directory. "Content-addressed"
means we reference things using a value that's somehow derived from that thing's contents.
Content-addressed storage is implemented in Git using a SHA-1 hasging algorithm.

SHA-1 is a bit technical but all we need to know is it takes content of any size and turns
it into a 40-character long string of letters and numbers. Each generated string is unique
to that piece of content.

== Object Storage in Git

To store an object, Git will first compute the SHA-1 has of that object.

The *first two*
characters of that hash are then cut off and used to create a folder inside of `.git/objects`.

The rest of the characters are used to name a file _within_ that folder. The file will then hold
the object's data.

Git does this splitting because it makes it a bit faster for a file system to look up files if they're
nested in a directory instead of one flat directory with many files.

== Object Hashing Example
<object-hashing-storage>

Let's consider an object that's hashed into:\
#acc1[9a]#acc2[143d55e1bf0e61c61def985dade29d8ed53d85]

That hash is split up...

- #acc1[9a] becomes the name of a folder in `.git/objects/`
- #acc2[143d55e...] becomes a file in that
  folder, storing the cat inside
- So our full path to the object will be
  .git/objects/#acc1[9a]/#acc2[143d55e...]

== Anatomy of an Object
<anatomy-of-an-object>


Every object in Git is structured like so:

+ #acc1[type] of the object, followed by an ASCII space
+ #acc2[size] of the object, encoded as a string \(#emph[not] just the number
  in binary), followed by #acgrey[\\0 ] \(the null terminator)
+ #acc3[data] the object contains

---

Let’s consider an object with the contents #acc3[Hello World!].

(remember: #acc1[type] #acc2[size]#acgrey[\\0]#acc3[data])

#mono[#acc1[blob] #acc2[12]#acgrey[\\0]#acc3[Hello World!]]

- #acc1[blob] is our type, we'll get into the signifigance of "blob" in a sec
- #acc2[12] is the length of "Hello World!"
- #acc3[Hello World!] is our object data

== Other Notes About Object Storage

- When hashing an object, we _include_ the metadata header. It's critical we add this or all
  the hashes will be wrong!
- Git stores objects by zlib compressing them to save space, so you can't simply read object
  data with a text editor or `cat`. You can instead use the `git cat-file` command to print the contents of an object, we'll get into using this command later.

// TODO: Example with git cat-file?

== Types of Objects
<types-of-objects>

Git has four types of objects it deals with.

+ Blobs - Raw data, like our "Hello World!" example from before
+ Trees - Directories that link to blobs or other trees
+ Commits - Markers that reference a tree and hold metadata
+ Tags - Static pointers to commits that have additional metadata

We’ve already seen blobs before, with the "Hello World!" example.

== Blob Objects

*Blobs* are the simplest type of objects and store data
verbatim within them.

#acc1[blob] #acc2[12]#acgrey[\\0]#acc3[Hello World!]

Blobs are most often used to store file data directly; any text files, pictures,
etc. will be serialized and stored as blob objects.

Other types of objects get a bit more complicated.

== Tree Objects
<tree-objects>

*Trees* are the next level up from blobs, they store references to blobs
and other trees. A tree is to a blob as a folder is to a file.

A tree is structured with a series of *leaves*. Each leaf is an entry within the tree
and corresponds to a file or subfolder. A leaf stores three pieces of information:

+ #acc1[mode] of the leaf \(permissions) followed by an ASCII space
+ #acc2[name] of the leaf \(file name or sub-folder name), followed by #acgrey[\\0]
+ #acc3[hash] of the object that contains this leaf’s contents

== Tree Object Example

Let’s consider a tree of this repo's files.

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

Here we can see two files and one subdirectory stored. Trees can store additional types
of leaves depending on the #acc1[mode].

== Side Tangent - Self-referential Tree
<side-tangent---self-referential-tree>

Tree objects can reference other trees. What would happen if a tree referenced itself?

Making a cycle in Git like this is an interesting feat. Think
about what that tree would look like, we’d need a leaf that
looks something like this:

- #acc1[100644] #acc2[myself]#acgrey[\\0]#acc3[\<the tree’s hash\>]

But we don’t know the hash of our tree, how can we reference it? The correct hash
depends on us already knowing the hash!

---

If we edited the Git source code in some way that allowed us to
reference a tree within itself \(someone did this by using a weaker
hashing algorithm and brute-forcing the hash), Git will segfault (crash).

This crash isn't an issue normally as Git uses SHA-1 (by default).
Since SHA-1 is good enough™, we can be sure that tree objects will never contain cycles.

Git also supports SHA-256 hashing for objects, lessening the chances of a cycle/collision.

== The Git Index - How `git add` works
<the-git-index---how-git-add-works>

Git keeps track of what changes you've made while working with an *index*.
In order to add items to the index (and therefore make Git aware of changes),
you need to *stage* them with `git add`.

Git keeps track of your index with `.git/index`.
This file is used to create a tree object when committing later.

This file's format isn't too important, it's effectively just a list of files that have changed,
and how they've changed.

Eventually, our index will be serialized into a tree object.

== Another Side Tangent - Content Addressed Storage is Awesome
<another-side-tangent---content-addressed-storage-is-awesome>

We address objects based on that object’s contents.
A tree object contains references to other objects.
We address a tree by the contents of all the things it references by extension.

Nesting trees cascades this effect upwards. We can uniquely identify the
contents of an entire directory #emph[and all sub-directories] based on just one
hash.

This #emph[does] mean whenever we update even one part of our project,
we’ll likely have to recompute hashes for many different objects.

== Commit Objects
<commit-objects>

A *commit* object marks a tree object with a message, author, time,
and even cryptographic signature.

Commits start out with a series of newline-delimited
*headers*. Each header consists of a #acc1[name], a space, and then a
#acc2[value]. There's a common set of header names and values we'll explore in the example.

Following these headers are #emph[two] newlines and then the
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

Here’s what each header means in this commit object:

- `tree`: The tree object this commit is marking
- `parent` \(optional): The parent\(s) of this commit \(previous commit)
- `author`: Who authored the changes this commit performs \(can have
  multiple)
- `committer`: The person who created the commit object
- `gpgsig` \(optional): A cryptographic signature to verify the
  committer

== Commit Parents

`parent` is an important field. Using `parent`, we can create chains of commits with each
on pointing to it's previous one (a linked list). This chain of commits represent the "history"
of our project.

Commits can also have _multiple_ parents which represent a merging of two
different histories. We'll explore merging a bit later.

A commit with no parent usually means it's the first one in a history. For
example you'll always have one initial commit in your repository without a parent.

== Loose vs.~Packed Objects
<loose-vs.-packed-objects>

When you change a file and commit it, Git will create a new, separate object
for the new state of that file. This behavior can waste a lot of
space in large files, especially if you just change a few lines.

To reduce wasted space, Git will *pack* objects.
Packed objects are stored as *deltas* (differences) from another object.

Object packing saves space by eliminating duplication of data.
Additionally, it makes copying objects over the network faster.

== Refs
<refs>

For humans, referring to objects by their hash can be difficult.
To make referring to objects easier, *refs* exist.

Refs are human-named references to objects within the object store.

Refs are primarily stored in `.git/refs`, each ref is a text
file containing the object hash that the ref points to.

Refs primarily point to commit objects, but we'll see some special uses
of refs later on.

== Tags and Branches
<branches-vs.-tags>

*Tags* and *branches* are both types of refs, and have different use-cases.

- #strong[Tags] statically point to commits for a project. Tags don't change target commits.
  Tags areused for marking certain versions or releases (`.git/refs/heads`).
- #strong[Branches] point to many different commits in a
  project, showing in-progress changes or history (`.git/refs/tags`).

Tags can also be a bit fancier than branches, they can point to _tag objects_.

== Tag Objects

*Tag objects* add additional metadata to a tag such as a message, timestamp, author (tagger), and cryptographic signature.

We usually create a tag that signifies a specific release/version
of our project, like `v1.2.3`.

We can use tag objects to add the change notes of this release
to the tag. This way we know what features were added between that tag
and the last.

== Tag Object Example

Tag objects follow a similar format to commits, with some small differences. Let's
look at an example.

#acc1[object] #acc2[2572bbd459e4972ba4a4e0f4f4fd5d7e286b84d0] \
#acc1[type] #acc2[commit] \
#acc1[tag] #acc2[v0.5.3] \
#acc1[tagger] #acc2[Ben C \<bwc9876\@gmail.com\> 1742067179 -0400] \
\
#acc3[Fix a bunch of bugs!] \
#acc4[—–BEGIN SSH SIGNATURE—– U1NIU0...]

---

This tag marks version `0.5.3` of our project, and tells anyone
reading that since `0.5.2` we've "fixed a bunch of bugs!"

You may also notice the `type` field. Tag objects don't have to
reference just commits, they can also reference _any_ other object.
Most people never use tags for anything other than commits, however.

== Branches (Heads)

*Branches* represent an in-progress history of our project. You most likely
have worked on a branch called `main` or `master` in the past. The *head* is
the commit object the branch currently points to.

Branches allow multiple people to work on a project at once.
*Feature branches* refer to branches made to add a feature to a project.
For example you may have a branch called `fix-accessibility` that
a developer will work on to add accessibility features to a website.

== Combining Branches - Merging

Often times we'll want to take changes from one or more other branches and apply
them to the current one.

One way of doing this is a *merge* commit. This is a commit that will has two parents: the head of
the current branch and the head of the other branch.
By giving the commit two parents, we're saying it's a result of both histories.

If two branches share a common history and one is just behind the other,
a *fast-forward* occurs. This doesn't create a new commit and sets
the "behind" branch to point to the head of the source branch.

== Combining Branches - Rebasing

An alternative to merging is a *rebase*. Rebasing applies commits
from one branch to another, without making a merge commit. This is effectively just copying
and pasting changes from one branch to another.

Rebasing can do a lot more than just combine branches, however. Another common use case
is to squash a set of commits into one, cleaning up your history. A very user-friendly way
to do complex rebasing is `git rebase -i [commit-ish]`. This will open up an editor that lets
you interactively rebase the commits specified.

== Symbolic Refs and `HEAD`
<symbolic-refs-and-head>

Another type of ref is a *symbolic ref*. These refs can only
point to other refs. The most common example of this is `HEAD`, stored
in `.git/HEAD`.

`HEAD` points to the current working branch. The working branch is updated whenever we run `git commit` to point
to the new commit object.

When we change `HEAD` to point to something else, we're performing a *switch*.

== Checking Out Trees

The act of replacing the current project with one from a tree object is called a
*checkout*. You can checkout any refs, trees, commits, and tags.

- Checking out an object with `git checkout` will also switch `HEAD` to that object by default.
- Additionally, switching to a branch with `git switch` will also checkout that branch by default.

== Attached and Detached `HEAD`

`HEAD` can have different state depending on what you have checked out.

- Upon checking out a *branch*, `HEAD` is made *symbolic* and updated to point to it. Any commits made while `HEAD` has
  a branch checked out will update that ref to point to the new commit.
- Upon checking out a *tag* or *commit* directly, `HEAD` is made to *directly* point to the object hash.
  This results in a "Detached `HEAD`" state, which means commits we make won’t affect any specific branch.

== Rev Parse
<rev-parse>

Often times when working with Git porcelain commands you’ll be told to
enter a commit-ish or a tree-ish value.

- #emph[tree];-ish: A reference to a tree object, this includes a
  ref, a tag object, or a commit object
- #emph[commit];-ish: Reference to a commit object, this can be a ref or
  a tag object

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
  `git checkout HEAD~` will checkout the commit #emph[before] the current
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


== Restore vs.~Reset vs.~Revert
<restore-vs.-reset-vs.-revert>

These three commands are often confused with eachother and it can be a
bit difficult to tell exactly what they do without knowing Git’s
underlying system.

Some important terms:

- `HEAD`: the current head of the branch you're working on
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

A set of branches kept in sync from a different machine is called a *remote* ref.
Remotes are listed in `.git/refs/remotes`, and will be synced according
to the #emph[refspec] present in `.git/config`.

Refspecs follow the format +#acc1[\<SRC\>]:#acc2[\<DEST\>].

- #acc1[\<SRC\>] denotes the relative path on the remote server to grab a ref
  from
- #acc2[\<DEST\>] denotes where to save the ref locally

---

Let’s see an example of this in a config file. You’ll also
notice the #acc4[name] of the remote and the #acc3[url] of the remote.

#mono[
  \[remote "#acc4[origin]"\] \
  url \= #acc3[git\@github.com:Bwc9876/nixos-config.git] \
  fetch \= +#acc1[refs/heads/\*]:#acc2[refs/remotes/#acc4[origin]/\*]
]

Here we see that all refs under #acc1[refs/heads/\*] on
#acc3[git\@github.com:Bwc9876/nixos-config.git] will be placed in
#acc2[refs/remotes/#acc4[origin]/\*] locally.

---

Note that remote refs are _read-only_, we never update them locally. Remote refs are
a way of seeing what the refs were set to the last time we *fetched*.

To update remote refs from their respective remote, we run the `git fetch` command.
`git fetch` will download any needed objects automatically and update the remote ref to
point to the latest commit on the server.

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
