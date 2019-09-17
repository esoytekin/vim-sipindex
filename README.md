# vim-sipindex plugin

shows index of a sipp file.
SIPp is a free Open Source test tool / traffic generator for the SIP protocol. 

[information about sipp.](http://sipp.sourceforge.net/)

Needs [ Tabular ]( https://github.com/godlygeek/tabular ) vim plugin to work properly

## Installation
I recommend installing [ pathogen.vim ]( https://github.com/tpope/vim-pathogen ), then copy and paste:

```
mkdir -p ~/.vim/bundle
cd ~/.vim/bundle
git clone https://github.com/esoytekin/vim-sipindex.git
```

## Usage
* execute :SipIndex in a sipp xml buffer to start

## Keyboard shortcuts
* Enter -- goto sip message
*    R  -- manually refresh sip_index
*    D  -- delete sip message
*    C  -- comment out sip message
*    U  -- undo changes
*    q  -- quit

![screen_shot](http://s3.postimg.org/rlhqbc583/imgvimsipindex.png)
