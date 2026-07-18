# My Personal Emacs Config

After getting frustrated with my previous from-scratch emacs config, I had
switched to doom emacs, but that had its own problems, so after using helix for
a while I decided to create a new from-scratch config inspired by it.

# Departures from [Emaxx](https://github.com/jawadcode/emaxx.git)

## [Meow](https://github.com/meow-edit/meow) vs. [Helix-Mode](https://github.com/mgmarlow/helix-mode)

I realised that [Meow](https://github.com/meow-edit/meow) (and its doom emacs
wrapper [Doom-Meow](https://github.com/meow-edit/doom-meow)) was too divergent
from the helix model of editing for my tastes, and required far too much
configuration boilerplate.

After some searching I happened across [Helix-Mode](https://github.com/mgmarlow/helix-mode)
which I found to be a little barebones but provided the editing experience that
I was familiar with. I augmented it with some custom keybinds: `J`, `SPC c`,
`SPC w ...` etc., and it serves its purpose quite well for the time being. It
has built-in integrations with a couple of widely-used emacs packages like
package.el, eglot, treesit.el, xref (recently upstreamed packages),
multiple-cursors, avy. Given that this package is only a year old, hopefully
this list of integrations can expand and make the experience even more
comprehensive.

I do miss the automatic leader-key mappings, e.g. `SPC a ...` to `C-c a ...`
however I suspect it wouldn't be too hard to implement these for Helix-Mode.

## [LSP-Mode](https://github.com/emacs-lsp/lsp-mode) vs. [Eglot](https://github.com/joaotavora/eglot)

In general I have preferred LSP-Mode in both my from-scratch and my Doom Emacs
configuration, due to how visually pleasing LSP-UI can be, however, in every
single scenario in which I have tried it, it has been simply too laggy,
seemingly even a significant hardware upgrade was not enough. From my time with
helix I've realised that all that I really need are keyboard-triggered hover
docs, completions, and inlay hints in order to be productive, so I decided to
give up the bells and whistles of lsp-ui for eglot. I suspect I may have some
issues in the future with wanting multiple LSPs for certain major modes, but I
can just use helix for those particular scenarios.

## Elpaca

I have chosen to stick with elpaca as it is fast, however, this time I am making
a conscious effort to lazy-load as many packages as possible to keep
initialisation times low.
