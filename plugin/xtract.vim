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
"     :<range>Xtract <newfile> <headersize: optional>
"
" For example:
"
"     :6,8Xtract newfile
"
command -range -bang -nargs=* Xtract :<line1>,<line2>call s:Xtract(<bang>0,<f-args>)

function! s:Xtract(bang, target, ...) range abort
  let headersize = get(a:, '1')
  let target = s:add_default_extension(a:target, expand('%:e'))

  " Expand the full target path
  if target[:1] == '~/'
    let target = expand(target)
  elseif target[0] != '/'
    let target = expand('%:h').'/'.target
  endif

  " Raise an error if target file exists and this was invoked without a bang
  if filereadable(target) && !a:bang
    return s:error('E13: File exists (add ! to override): '.target)
  endif

  " Copy header (register 'x')
  if headersize
    silent exe '1,'.headersize.'yank x'
  endif

  " Capture the indent of the first selected line before the selected lines are removed
  let indent = s:get_indent_at(a:firstline)

  " Remove block (use default register)
  silent exe a:firstline.','.a:lastline.'del'

  " Keep track of the original line where the content was extracted from
  let origline = a:firstline

  " Insert import statement at the end of the header (if headersize was specified
  " and we have an appropriate import template)
  if headersize
    let import = s:get_importstring()

    if import != -1
      let import = substitute(import, '%s', a:target, 'g')

      " Insert the import statement
      call append(headersize - 1, s:get_indent_at(headersize - 1).import)

      " Advance the original line reference due to the paste
      let origline += 1
    endif
  endif

  " Build a placeholder comment that refers to the new file that was created
  let placeholder = s:comment(&commentstring, target)

  " Insert a placeholder comment where the text was removed
  call append(origline - 1, indent.placeholder)

  " Place the cursor on the line with the placeholder comment
  silent exe origline.'|'

  " Open target buffer and paste the extracted block at the end
  call s:open_buffer(target)
  call s:paste_append()

  " Insert the header (if headersize specified) at the top
  if headersize
    silent put! x
  endif

  " Create the target directory if it doesn't already exist
  if !isdirectory(fnamemodify(target, ':h'))
    call mkdir(fnamemodify(target, ':h'), 'p')
  endif

  " Put the cursor at the top of the new buffer
  silent 1

  " Briefly switch to the original window to center the view
  noautocmd wincmd p
  silent exe 'norm! z.'
  noautocmd wincmd p

  " Output message
  let numlines = a:lastline - a:firstline + 1
  redraw
  echomsg numlines.' line'.(numlines == 1 ? '' : 's').' extracted to file: '.target
endfunction

" Open buffer in a split window or focus it if it's already open
function! s:open_buffer(name)
  let bufinfo = getbufinfo(a:name)

  if len(bufinfo) > 0
    let bufinfo = bufinfo[0]

    if len(bufinfo.windows) > 0
      call win_gotoid(bufinfo.windows[0])
      return
    endif
  endif

  silent exe 'split '.a:name
endfunction

function! s:paste_append()
  let bufwasempty = line('$') == 1 && getline(1) == ''

  " Paste at the end of the buffer
  silent $put

  " If the buffer was empty, delete the residual empty line at the top of the buffer (without taking a register)
  if bufwasempty
    silent 1delete _
  endif
endfunction

function! s:add_default_extension(path, ext)
  return a:ext != '' && fnamemodify(a:path, ':e') == '' ? a:path.'.'.a:ext : a:path
endfunction

function! s:get_indent_at(line)
  return matchstr(getline(a:line), '^\s*')
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
