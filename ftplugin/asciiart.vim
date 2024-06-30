" Author: Hanley Lee
" Website: https://www.hanleylee.com
" GitHub: https://github.com/hanleylee
" License:  MIT License

" setlocal foldmethod=syntax
" setlocal iskeyword+=+
" setlocal commentstring=//\ %s
setlocal textwidth=78
setlocal virtualedit=all
" let g:ycm_global_ycm_extra_conf = '~/.config/ycm/cpp.ycm_extra_conf.py' " 默认配置文件路径
" " execute 'setlocal dict+=~/.vim/words/' . &filetype. '.dict'
nnoremap <buffer> << <Nop>
nnoremap <buffer> >> <Nop>

nnoremap <silent><Up>       :call asciiart#arrowmove('up')<CR>
nnoremap <silent><Down>     :call asciiart#arrowmove('down')<CR>
nnoremap <silent><Left>     :call asciiart#arrowmove('left')<CR>
nnoremap <silent><Right>    :call asciiart#arrowmove('right')<CR>
vnoremap <silent><leader>b  :call asciiart#WrapBlockWithASCII()<CR>
    " nnoremap <silent>K          :call hl#ui#show_documentation()<CR>

" text object for asciiart box
vnoremap <buffer> <silent> ib :<C-U>call asciiart#boxObject('i')<CR>
onoremap <buffer> <silent> ib :<C-U>call asciiart#boxObject('i')<CR>
vnoremap <buffer> <silent> ab :<C-U>call asciiart#boxObject('a')<CR>
onoremap <buffer> <silent> ab :<C-U>call asciiart#boxObject('a')<CR>

" clear box content(or with border)
nnoremap <buffer> <silent> <leader>dib :<C-U>call asciiart#boxclear('i')<CR>
nnoremap <buffer> <silent> <leader>dab :<C-U>call asciiart#boxclear('a')<CR>
