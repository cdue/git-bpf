Git Branch-per-Feature workflow automation Scripts
==================================================

This project is a fork of [UriHendler/git-bpf project] adding some scripts to ease the day to day use of Git BPF workflow.


Configure a repository and add some useful [Branch-per-Feature] workflow commands.

Performs the following actions in the target repository:

 - enables ```git-rerere```
 - configures ```git-rerere``` to automatically stage successful resolutions
 - a .git/rr-cache directory will be set up to synchronize with a 'rr-cache' branch in the repository's remote.
 - installs a ```post-merge``` git hook for automatic rr-cache syncing
 - installs the bundled branch-per-feature helper commands

## Commands

### git bpf-recreate-branch

Usage: ```git bpf-recreate-branch <source-branch> [OPTIONS]...```

Recreates <source-branch> in-place or as a new branch by re-merging all of the merge commits which it is comprised of.

    OPTIONS
        -a, --base NAME                  A reference to the commit from which the source branch is based, defaults to master.
        -b, --branch NAME                Instead of deleting the source branch and replacng it with a new branch of the same name, leave the source branch and create a new branch called NAME.
        -x, --exclude NAME               Specify a list of branches to be excluded.
        -l, --list                       Process source branch for merge commits and list them. Will not make any changes to any branches.


### git bpf-share-rerere

A collection of commands to help share your rr-cache.

    OPTIONS
        -c, --cache_dir DIR              The location of your rr-cache dir, defaults to .git/rr-cache.
        -g, --git-dir DIR                The location of your rr-cache .git dir, defaults to .git/rr-cache/.git.
        -b, --branch NAME                The name of the branch your rr-cache is stored in, defaults to rr-cache.
        -r, --remote NAME                The name of the remote to use when getting the latest rr-cache, defaults to origin.

**Sub-commands - Usage:**

```git bpf-share-rerere push```

Push any new resolutions to the designated <branch> on the remote.

```git bpf-share-rerere pull```

Pull any new resolutions to the designated <branch> on the remote.


### git bpf-cycle-new

Usage: ```git bpf-cycle-new [OPTIONS]```

Used by a Release Manager to initialize a 'develop' and a 'QA' branch on the remote repository.

    OPTIONS
        -a, --base NAME                  A reference to the commit from which the 'develop' and 'QA' branches are based, defaults to master.
        -v, --verbose                    Show more logs.


### git bpf-cycle-init

Usage: ```git bpf-cycle-init [OPTIONS]```

Initialize a new development cycle for a developper. Fetch tags, and (re)creates locale develop and QA branches.


### git bpf-feature-start

Usage: ```git bpf-feature-start <feature-branch> ```

Start a new feature from latest version of master (or given branch/tag) 

    OPTIONS
        -a, --base NAME                  A reference to the commit from which the feature branch is based, defaults to master.
        -v, --verbose                    Show more logs.


## Installation

_Requires git >= 1.7.10.x_
_Requires Ruby (to be able to gem build and gem install)

You need to fetch latest master from this repo. Then execute manual gem build:
```gem build git_bpf.gemspec```

This will create gemfile git_bpf-[version]].gem . To install it, run:

```sudo gem install git_bpf-[version].gem```


(Note for windows users - prior to upgrading git-bpf, you need to remove all hooks and git-bpf directory from .git directory in your project.)


## Usage

### Initialize BPF tools for your git repository

```(…)$ git bpf-init <target-repository>```

    OPTIONS
        -r, --remote NAME                The name of the remote to use for syncing rr-cache, defaults to origin.
        -e, --remote_recreate NAME       The pattern for choosing branches for recreate-branch command, defaults to wildcard *. Can be used for filtering certain branches from remote repositories

 - If <target-repository> is not provided, <target-repository> defaults to your current directory (will fail if current directory is not a git repository).


### You are a release manager?

## Start a development cycle

```(…)$ git bpf-cycle-new```

## Let the dev team do some work

...
Seat down and drink a good coffee
...

## Prepare a release

This is not already automated but it will be someday...
But for the moment, here is what you must do to prepare a release:

```
// Make sure your local repo has a snapshot of the latest remote state.
(…)$ git fetch --all --tags
(…)$ git checkout QA
(QA)$ git pull origin QA

// If you want to exclude a feature from the release:
(QA)$ git bpf-recreate_branch QA --exclude f-<ticket_num>_<short_description>
// We have rebuilt the QA branch, it has a different history to the QA branch that exists on the remote. 
// It has to be 'force' pushed to completely replace the original QA branch. 
(QA)$ git push -u origin QA --force

// Merge into master.
(QA)$ git checkout master
(master)$ git merge QA

// This is where updating any VERSION.txt would take place, make sure to commit it.

// Create a tag on our production ready code.
(master)$ git tag -a 0.0.1 -m 'first release!'

// Push the updates to master and the tag.
(master)$ git push -u origin master --tags

// Checkout that tag on sites we need to deploy to.
```

After creating a release, starting a new development cycle will recreate branches from that release. 
Which means that the file containing the new version number will be checked out automatically (no need to merge it back anywhere).


### You are a developer?

## Start a new feature

``` 
(…)$ git bpf-feature-start f-<ticket_num>_<short_description> 

… do some work

(F.B.)$ git add [<filepattern>…]
(…)$ git commit -m 'refs #<ticket_num> - <description>'
// Push feature branch to origin
(…)$ git push -u origin f-<ticket_num>_<short_description>
```

## Merge your code on integration branch every 2-3 commits

The following is not automated yet, but it will also be oneday...
``` 
(…)$ git checkout develop
(develop)$ git merge f-<ticket_num>_<short_description> [--no-edit]

… resolve any conflicts

// Push changes for continuous integration testing.
(…)$ git push -u origin develop
/// Back to work.
(…)$ git checkout f-<ticket_num>_<short_description>
``` 

The conflicts resolutions you made will be automtically pushed to the rerere (using a git hook).


## Merge your code on QA branch when your feature is done

The QA branch can be in stable or unstable state.
If the latest merged feature breaks testing, then you need to recreate the branch before you merge your feature in:

``` 
(…)$ git fetch --all --tags
(…)$ git checkout QA
(QA)$ git pull origin QA

// Exclude the feature(s) that breaks QA:
(QA)$ git bpf-recreate_branch QA --exclude f-<ticket_num>_<short_description>
``` 

Then you can merge your feature in...
The following is not automated yet, but it will also be oneday... (did I already said that?)

``` 
(…)$ git checkout QA
(QA)$ git merge f-<ticket_num>_<short_description> --no-ff

… resolve any conflicts

// Push changes for QA testing.
(…)$ git push -u origin QA
``` 
Be carreful: the ``--no-ff`` (no fast forward) option is really important as it explicitly creates a reference to that merge in the repo history.


### After a release

## Start a new development cycle

## Check if some feature had been excluded from latest release

## Rebase unreleased features


### You have a hotfix to create

## is it a Production issue?

## is it an unreleased feature issue?



[Branch-per-Feature]: https://github.com/affinitybridge/git-bpf/wiki/Branch-per-feature-process
[RubyGems]: http://rubygems.org/
[UriHendler/git-bpf project]: https://github.com/UriHendler/git-bpf
