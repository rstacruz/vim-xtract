if exists('g:loaded_xtract') || &cp || v:version < 700
  finish
endif
let g:loaded_xtract = 1

" Import strings
let g:xtract_importstrings = {
\ "javascript": "import %s from './%s'",
\ "jsx": "import %s from './%s'",
\ "scss": "@import './%s';",
\ "sass": "@import './%s'",
\ }

" Extracts the current selection into a new file.
"
"     :<range>Xtract <newfile> <header: optional>
"
" For example:
"
"     :6,8Xtract newfile
"
command -range -bang -nargs=* Xtract :<line1>,<line2>call s:Xtract(<bang>0,<f-args>)

function! s:Xtract(bang, target, ...) range abort
  let header = get(a:, '1')
  let target = a:target
  let extension = expand("%:e")
  let indent = s:get_indent_at(a:firstline)

  " If current file has an extension and the target doesn't already have it, append it
  if !empty(extension) && !s:path_has_extension(target, extension)
    let target .= '.'.extension
  endif

  " Expand the full target path
  if target[:1] == '~/'
    let target = expand(target)
  elseif target[0] != '/'
    let target = expand("%:h").'/'.target
  endif

  " Raise an error if target file exists and this was invoked without a bang
  if filereadable(target) && !a:bang
    return s:error('E13: File exists (add ! to override): '.target)
  endif

  " Copy header (register 'x')
  if header
    silent exe "1,".header."yank x"
  endif

  " Remove block (use default register)
  silent exe a:firstline.",".a:lastline."del"

  " Keep track of the original line where the content was extracted from
  let origline = a:firstline

  " Insert import statement right after the header (if header was specified
  " and we have an appropriate import template)
  if header
    let import = s:get_importstring()

    if import != -1
      let import = substitute(import, "%s", a:target, "g")

      " Capture the indent present on the next-to-last line of the header
      let header_indent = s:get_indent_at(header - 1)

      " Append the import statement to the header
      silent exe "norm! :".header."insert\<CR>".header_indent.import."\<CR>.\<CR>"

      " Advance the original line reference due to the paste
      let origline += 1
    endif
  endif

  " Build a placeholder comment that refers to the new file that was created
  let placeholder = s:comment(&commentstring, target)

  " Insert the placeholder where the text was removed
  silent exe "norm! :".origline."insert\<CR>\<C-u>".indent.placeholder."\<CR>.\<CR>"

  " Open a new window and paste the extracted block in
  silent exe "split ".target
  silent put

  " Delete the empty line at the top of the file (without taking a register)
  silent 1delete _

  " Insert the header (if specified) at the top
  if header
    silent put! x
  endif

  " Ensure the target directory exists
  if !isdirectory(fnamemodify(target, ':h'))
    call mkdir(fnamemodify(target, ':h'), 'p')
  endif

  " Put the cursor at the top of the new buffer
  silent 1
endfunction

function! s:path_has_extension(path, ext)
  return strcharpart(a:path, strchars(a:path) - (strchars(a:ext) + 1), strchars(a:ext) + 1) == ".".a:ext
endfunction

function! s:get_indent_at(line)
  return matchstr(getline(a:line), "^[ \t]*")
endfunction

function! s:get_importstring()
  return get(g:xtract_importstrings, &filetype, -1)
endfunction

"
" Method borrowed from tpope/commentary.vim
"
function! s:comment(commentstring, text)
  " If comment string is empty, start with an %s placeholder
  " Pad placeholder on the left (if it makes sense)
  " Pad placeholder on the right (if it makes sense)
  " Insert comment
  return
    \ substitute(
      \ substitute(
        \ substitute(
          \ substitute(
            \ a:commentstring, '^$', '%s', ''
          \ ), '\S\zs%s',' %s', ''
        \ ), '%s\ze\S', '%s ', ''
      \ ), '%s', a:text, ''
    \ )
endfunction

"
" Shows an error message
"
function! s:error(str)
  echohl ErrorMsg
  echomsg a:str
  echohl None
  let v:errmsg = a:str
  return ''
endfunction
