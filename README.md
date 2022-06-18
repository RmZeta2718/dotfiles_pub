# My Public Dotfiles

I'm using [Dotbot](https://github.com/anishathalye/dotbot) to manage dotfiles.

[Tutorial](https://www.anishathalye.com/2014/08/03/managing-your-dotfiles/) on Dotbot by [Anish](https://www.anishathalye.com/) (the author, also one of the lecturers of [MIT-Missing-Semester](https://missing.csail.mit.edu/)).

There are many different approaches other than Dotbot, see https://dotfiles.github.io/

## Cheat Sheet

Sync all dotfiles to a new machine:

```bash
git clone https://github.com/RmZeta2718/dotfiles_pub.git
cd dotfiles_pub
./install
```

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
