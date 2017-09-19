# vim-xtract

> Extract the selection into a new file

vim-xtract helps you split up large files into smaller files. Great for refactoring.

![](docs/screencast.gif)

## Installation

Add `rstacruz/vim-xtract` using your favorite Vim plugin manager. For [vim-plug](https://github.com/junegunn/vim-plug), that's:

```vim
Plug 'rstacruz/vim-xtract'
```

## Usage

Select a few lines. You can use a visual selection (<kbd>V</kbd>) or using text objects (<kbd>v</kbd><kbd>ap</kbd><kbd>ap</kbd>...). Then press:

```
:Xtract newfilename⏎
```

This extracts from the current file into a new file `newfilename.js` in the same directory, keeping the extension of the current file.

## Updating placeholders

Edit `g:xtract_placeholders` to update the string it leaves behind:

```js
let g:xtract_placeholders = {
\ "javascript": "import %s from './%s'",
\ "jsx": "import %s from './%s'",
\ "scss": "@import './%s';",
\ "sass": "@import './%s'",
\ }
```

## Thanks

**vim-xtract** © 2016-2017, Rico Sta. Cruz. Released under the [MIT] License.<br>
Authored and maintained by Rico Sta. Cruz with help from contributors ([list][contributors]).

> [ricostacruz.com](http://ricostacruz.com) &nbsp;&middot;&nbsp;
> GitHub [@rstacruz](https://github.com/rstacruz) &nbsp;&middot;&nbsp;
> Twitter [@rstacruz](https://twitter.com/rstacruz)

[![](https://img.shields.io/github/followers/rstacruz.svg?style=social&label=@rstacruz)](https://github.com/rstacruz) &nbsp;
[![](https://img.shields.io/twitter/follow/rstacruz.svg?style=social&label=@rstacruz)](https://twitter.com/rstacruz)

[MIT]: http://mit-license.org/
[contributors]: http://github.com/rstacruz/vim-xtract/contributors
