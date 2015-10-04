#Your workflow is your language

This readme is an attempt to document everything related to my
workflow, in installed order, from scratch on a freshly restored mac.

##Browsers

1. (If you prefer chrome) [Download Chrome](http://www.google.com/chrome/) from Safari, sign-in to resync
1. Some chrome extensions
  - [Pocket]()
  - [1password]()
  - [What the Font]()
  - [Vimium]()

##OSX Apps

1. [1password]()
1. [Dropbox]()
1. [nvault]()
  - set up to read/write plain text files from dropbox
  - [NVault workflow blog post]()
1. [Limechat]()
1. [BetterSnapTool]()
1. Xcode (from App Store)
  - Install the command line tools
1. [Evernote]()
1. [Slack]()
1. [Colorsnapper2]()

##Alfred

1. [Alfred]()
1. [Dash]()
  - Dash-Alfred integration

####Workflows

- [pkgman](https://github.com/willfarrell/alfred-pkgman-workflow) - better/faster than googling for packages
- [dash](https://github.com/Kapeli/Dash-Alfred-Workflow) - better/faster than googling for docs
- [spotifious](http://ben.stolovitz.com/Spotify-for-Alfred/) - better/faster search/control of spotify
- [workflow search](https://github.com/hzlzh/Alfred-Workflows/raw/master/Downloads/Workflow-Searcher.alfredworkflow) - for when you know there's a better/faster way
- [stackoverflow](https://github.com/xhinking/Alfred/blob/master/stackoverflow.alfredworkflow)
- [github](https://github.com/gharlan/alfred-github-workflow) - `gh [search|repo|etc]`
- [top (including kill)](http://zhaocai.github.io/alfred2-top-workflow/) - because the activity monitor is just too slow, especially when something needs to DIE
- [ip](http://dferg.us/ip-address-workflow/) - quick local/external ip lookup

##iTerm

1. Install [iTerm2 (nightlies)](https://iterm2.com/downloads/nightly/#/section/home)
  - Turn off Lion-style full screen windows

##Homebrew

1. [Homebrew]()
  - `` - 
  - `brew install coreutils`
  - `brew install caskroom/cask/brew-cask` - generic req for brew casks

##Node

- `brew install node`
- `npm install -g n`
- `n latest`
- `npm i -g bower gulp babel eslint typescript`

##Python

1. `brew install python`
  - should give you `pip` as well

##Lua

1. `brew install lua`

##Dotfiles

1. Init dotfiles folder (if it does not exist) with git history

##Zsh with Antigen

1. install [antigen]() as a submodule
  - basic antigen plugin config
  - brew, git, nvm, a theme

####Zshrc notables:

- tmux aliases, zsh aliases
- etc.

##Tmux

1. `brew install tmux`
1. Start `tmux.conf` in dotfiles

####Notables:

- `tt` command for session handling
- `option + [any number]` to quick hop to that window

###Tmux + Powerline

1. Install Powerline (pre-req: Python)
  - `pip install powerline-status`
  - `pip install psutil`
1. [Powerline fonts](https://github.com/powerline/fonts) downloaded installed to your osx
  - [Hack](https://github.com/chrissimpkins/Hack/issues/111) is nice
1. Fonts set via iTerm2 profile settings

##(N)vim

####Pre-reqs

Python, Node (for some plugins)

####Install

1. Install Neovim
  - (requires python?) (see python section?)
  - `pip install neovim`
1. `alias vim=nvim` >> zshrc
1. Start `nvimrc` in dotfiles
1. Install vim-plug, write vim-plugins.vim

####Nvimrc Notables:

- spacebar as leader
- double tap leader to toggle last file
- quick splits
- etc.

####Plugins:

  plugin-config
  :VimProcInstall
vimproc install requires naving to plugged/vimproc clone and running `make`

  install tern properly
  cd ~/.vim/plugged/tern_for_vim; npm i;

- [Airline]()
  - Pre-reqs: Powerline

####to fix neovim ctrl + h break

Only if this is still [an issue]().

`infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\177/' > $TERM.ti ; tic $TERM.ti`

##OSX-Hacks script

Based on [this]() and/or [this](), [here]() is mine.

####Notables:

- fast repeat is a game-changer 
- shut down + restart required.

##Other CLI tools

- `brew install Ag` (or maybe [sift]() - both are super fast `grep`s
- `brew cask install qlmarkdown` - QuickLook (space-bar preview) for markdown files
- `brew install reattach-to-user-namespace` - for tmux sessions, i believe
- `brew install httpie` - [HTTPie]() - colorized and easy to use cURL tool
- `pip install grip` - [Grip]() - easy offline github markdown readme server
- `brew install cloc`

##Mjolnir

####Prereqs

- Lua

####Install

mjolnir config for easy app access

still need luarocks?

- echo 'rocks_servers = { "http://rocks.moonscript.org" }' >> /usr/local/etc/luarocks52/config-5.2.lua
- `luarocks install mjolnir.hotkey`
- `luarocks install mjolnir.application`
- `brew cask install mjolnir`

####Notables:

- `option + [any letter]` to quick hop to any app by name

##Caps-lock -> Esc remapping

1. [Seil](https://pqrs.org/osx/karabiner/seil.html) for caps lock -> esc remapping
  - some implementation steps here that could get more detail

##Truecolor in iTerm2/Tmux/nvim:

1. Make sure you have the [nightly iTerm2](https://iterm2.com/downloads/nightly/#/section/home)
1. [patch tmux](https://github.com/rschmukler/dotfiles/blob/master/files/brew-patches/tmux.txt)
1. `brew reinstall --with-truecolor`
1. install a [true color theme](https://github.com/kristijanhusak/vim-hybrid-material), plus some vim related things (TODO:)

