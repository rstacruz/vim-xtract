if exists('g:loaded_xtract') || &cp || v:version < 700
  finish
endif
let g:loaded_xtract = 1

" Placeholders
let g:xtract_placeholders = {
\ "javascript": "import %s from './%s'",
\ "jsx": "import %s from './%s'",
\ "scss": "@import './%s';",
\ "sass": "@import './%s'",
\ }

" Extracts the current selection into a new file.
"
"     :6,8Xtract newfile
"
command -range -bang -nargs=* Xtract :<line1>,<line2>call s:Xtract(<bang>0,<f-args>)

function! s:Xtract(bang, target, ...) range abort
  let first = a:firstline
  let last = a:lastline
  let head = get(a:, '1')
  let range = first.",".last
  let target = a:target
  let extension = expand("%:e")

  " If current file has an extension, append it
  if !empty(extension)
    let target .= '.'.extension
  endif

  " Build the full target path
  if target[0] == '~' && target[1] == '/'
    let target = expand(target)
  elseif target[0] != '/'
    let target = expand("%:h").'/'.target
  endif

  " Raise an error if invoked without a bang
  if filereadable(target) && !a:bang
    return s:error('E13: File exists (add ! to override): '.target)
  endif

  " Copy header (register 'x')
  if head
    silent exe "1," . head . "yank x"
  endif

  " Remove block (register default)
  silent exe range."del"

  " Remove extra lines at the end of the file (not working?)
  silent! '%s#\($\n\s*\)\+\%$##'

  " Insert the placeholder
  if head
    let spaces = matchstr(getline(head - 1),"^ *")
    let placeholder = substitute(s:get_placeholder(), "%s", a:target, "g")

    " Go to where the head is and insert the placeholder
    silent exe "norm! :".head."insert\<CR>".spaces.placeholder."\<CR>.\<CR>"
  else
    let spaces = matchstr(getline(first),"^ *")
    let placeholder = substitute(&commentstring, "%s", " ".target, "")

    " Insert the placeholder where the text was extracted
    silent exe "norm! :".first."insert\<CR>".spaces.placeholder."\<CR>.\<CR>"
  endif

  " Open a new window and paste the block in
  silent execute "split ".target
  silent put
  silent 1
  silent normal '"_dd'

  " Paste the head in, if it's available
  if head
    silent put! x
  endif

  " mkdir -p
  if !isdirectory(fnamemodify(target, ':h'))
    call mkdir(fnamemodify(target, ':h'), 'p')
  endif

  " Remove extra lines at the end of the file
  silent! '%s#\($\n\s*\)\+\%$##'
  silent 1
endfunction

function! s:get_placeholder()
  if has_key(g:xtract_placeholders, &filetype)
    return get(g:xtract_placeholders, &filetype)
  else
    return &commentstring
  endif
endfunction

"
" Shows an error message.
"
function! s:error(str)
  echohl ErrorMsg
  echomsg a:str
  echohl None
  let v:errmsg = a:str
  return ''
endfunction
