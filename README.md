# vim-xtract

> Extract the selection into a new file

vim-xtract helps you split up large files into smaller files. Great for refactoring.

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

## Thanks

**vim-xtract** © 2016+, Rico Sta. Cruz. Released under the [MIT] License.<br>
Authored and maintained by Rico Sta. Cruz with help from contributors ([list][contributors]).

> [ricostacruz.com](http://ricostacruz.com) &nbsp;&middot;&nbsp;
> GitHub [@rstacruz](https://github.com/rstacruz) &nbsp;&middot;&nbsp;
> Twitter [@rstacruz](https://twitter.com/rstacruz)

[MIT]: http://mit-license.org/
[contributors]: http://github.com/rstacruz/vim-xtract/contributors
