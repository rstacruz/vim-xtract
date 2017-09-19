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
command -range -bang -nargs=1 Xtract :<line1>,<line2>call s:Xtract(<bang>0,<f-args>)

function! s:Xtract(bang,target) range abort
  let first = a:firstline
  let last = a:lastline
  let range = first.",".last

  let ext = expand("%:e")        " js
  let path = expand("%:h")       " /path/to
  let fname = a:target.".".ext   " target.js
  let fullpath = path."/".fname  " /path/to/target.js
  let spaces = matchstr(getline(first),"^ *")

  " Raise an error if invoked without a bang
  if filereadable(fullpath) && !a:bang
    return s:error('E13: File exists (add ! to override): '.fullpath)
  endif

  " Copy it
  silent exe range."yank"

  " Replace it
  let placeholder = substitute(s:get_placeholder(), "%s", a:target, "g")
  silent exe "norm! :".first.",".last."change\<CR>".spaces.placeholder."\<CR>.\<CR>"

  " Open a new window and paste it in
  silent execute "split ".fullpath
  silent put
  silent 1
  silent normal '"_dd'

  " mkdir -p
  if !isdirectory(fnamemodify(fullpath, ':h'))
    call mkdir(fnamemodify(fullpath, ':h'), 'p')
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
