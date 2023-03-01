# My Public Dotfiles

This repository contains public dotfiles including various configuration files, shell utilies, plugins, etc (i.e. dotfiles). There is also a private repository containing private dotfiles like ssh info. 

I'm using [Dotbot](https://github.com/anishathalye/dotbot) to manage dotfiles. [Tutorial](https://www.anishathalye.com/2014/08/03/managing-your-dotfiles/) on Dotbot by [Anish](https://www.anishathalye.com/) (the author, also one of the lecturers of [MIT-Missing-Semester](https://missing.csail.mit.edu/)).

There are many different approaches other than Dotbot, see https://dotfiles.github.io/

## Note

- zsh plugins are not placed in default folder (`$ZSH/custom`), but in `ZSH_CUSTOM="$HOME/.zsh/custom"`. The default position is inside oh-my-zsh repo, causing repos (omz vs plugins) nesting with each other and hard to maintain in dotbot (clone order, dirty repo and other problems). If there is a better way, please let me know.
- `conda init` shoud be placed in `~/.shell_local_after`. This is now automated by assuming `conda init zsh` append 15 lines to `~/.zshrc`.
- vscode settings are not maintain by dotfiles, vscode has its own way to sync its [settings](https://code.visualstudio.com/docs/editor/settings-sync).
  - If you are working with vscode remote, basically you don't need to sync your settings because you settings is used on remote [by default](https://code.visualstudio.com/docs/remote/ssh#_ssh-hostspecific-settings), but you should [specify what extensions to install on remote](https://code.visualstudio.com/docs/remote/ssh#_always-installed-extensions) for that extensions are not automatically installed on remote.

## Cheat Sheet

### Sync all dotfiles to a new machine

First, [generate new ssh key](https://docs.github.com/cn/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) and [add it to github](https://docs.github.com/cn/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) (more instructions [here](https://github.com/calvinbui/dotfiles)). Then, clone and install dotfiles.

```bash
git clone git@github.com:RmZeta2718/dotfiles_pub.git
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

<!-- 
You can create a symlink inside a git submodule. See `~/.oh-my-zsh/custom/` . Note:
- The symlink path should be ignored in the submodule.
- The symlink should be created after clone (submodule update) , order specified in `install.conf.yaml` . If clone failed during install, uninstall all symlinks (`./uninstall`), then clone/install again. 
-->

## TODO

Extra initialization steps after `./install` . They are not yet covered by Dotbot, still working on it to automate.

- clash binary (It seems improper to include executable in git repo.)
- tldr
- conda/python env
