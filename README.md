# My Public Dotfiles

This repository contains public dotfiles including various configuration files, shell utilies, plugins, etc (i.e. dotfiles). There is also a private repository containing private dotfiles like ssh info. 

I'm using [Dotbot](https://github.com/anishathalye/dotbot) to manage dotfiles. [Tutorial](https://www.anishathalye.com/2014/08/03/managing-your-dotfiles/) on Dotbot by [Anish](https://www.anishathalye.com/) (the author, also one of the lecturers of [MIT-Missing-Semester](https://missing.csail.mit.edu/)).

There are many different approaches other than Dotbot, see https://dotfiles.github.io/

## Cheat Sheet

### Sync all dotfiles to a new machine

First, [generate new ssh key](https://docs.github.com/cn/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) and [add it to github](https://docs.github.com/cn/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) (more instructions [here](https://github.com/calvinbui/dotfiles)). Then, clone and install dotfiles.

```bash
git clone https://github.com/RmZeta2718/dotfiles_pub.git
cd dotfiles_pub
./install
```

### Modify dotfiles

Add a new dotfile `~/.foo` :

```bash
mv ~/.foo ~/.dotfiles/foo
# Add a new link for `foo` in install.conf.yaml
~/.dotfiles/install
# commit changes to git
```

Add a git submodule (eg. plugins) `~/vim/foo` :

```bash
mkdir -p ~/.dotfiles/vim  # make parent directory
git submodule add ${git_link_to_foo} ~/.dotfiles/vim/foo  # add submodule
# Add a new link for `vim` in install.conf.yaml
~/.dotfiles/install  # will update submodule
# commit changes to git
```

Delete all dotfiles installed by this repo:

```bash
./uninstall
```

## My Tricks

If a directory is managed by both public and private Dotbot repos(eg. `~/.ssh`, `~/.config` etc.), then you can't directly symlink the directory due to conflict. The solution is to link each file in these directories, explicitly or using wildcard(glob).

You can create a symlink inside a git submodule. See `~/.oh-my-zsh/custom/` . Note:
- The symlink path should be ignored in the submodule.
- The symlink should be created after clone (submodule update) , order specified in `install.conf.yaml` .

## TODO

Extra initialization steps after `./install` . They are not yet covered by Dotbot, still working on it to automate.

- clash binary (It seems improper to include executable in git repo.)
- vscode settings/extensions (keep in mind that vscode client/server use different extensions, [ref](https://code.visualstudio.com/api/advanced-topics/remote-extensions#architecture-and-extension-types))
- linux utils (eg. tree, htop, git(latest), wget, ...)
- autojump
- tldr
- conda/python env
