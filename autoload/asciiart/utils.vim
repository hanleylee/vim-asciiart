" Author: Hanley Lee
" Website: https://www.hanleylee.com
" GitHub: https://github.com/hanleylee
" License:  MIT License

function! asciiart#utils#matchall(expr, pat, ...)
    let start = a:0 ? a:1 : 0
    let lst = []
    let cnt = 1
    let found = match(a:expr, a:pat, start, cnt)
    while found != -1
        call add(lst, match(a:expr, a:pat, start, cnt))
        let cnt += 1
        let found = match(a:expr, a:pat, start, cnt)
    endwhile
    return lst
endfunction

function! asciiart#utils#FindNearestChar(str, index, target, direction)
    " echom 'str: ' . a:str . 'index: ' . a:index . 'target: ' . a:target . 'direction: ' . a:direction
    let l:str_len = len(a:str)
    if a:direction == 'left'
        for i in range(a:index, 0, -1)
            if a:str[i] == a:target
                return i
            endif
        endfor
    elseif a:direction == 'right'
        for i in range(a:index + 1, l:str_len - 1)
            if a:str[i] == a:target
                return i
            endif
        endfor
    else
        echo "Invalid direction: use 'left' or 'right'"
        return -1
    endif
    return -1
endfunction

" 确保列存在, 否则就用空格填充
function! asciiart#utils#EnsureColEnough(line_num, virt_col)
    let end_col = virtcol([a:line_num, '$'])

    if a:virt_col >= end_col
        let line_content = getline(a:line_num) . repeat(' ', a:virt_col - end_col + 10)
        call setline(a:line_num, line_content)
    endif
endfunction

function! asciiart#utils#EnsureLineEnough(line_num)
    while line('$') < a:line_num
        call append(line('$'), '')
    endwhile
endfunction

function! asciiart#utils#SetCharAtLineCol(line_num, target_virt_col, char)
    let l:line_content = getline(a:line_num)
    let l:line_length = strchars(l:line_content)

    call asciiart#utils#EnsureColEnough(a:line_num, a:target_virt_col)

    " 确保行存在
    while line('$') < a:line_num
        call append(line('$'), '')
    endwhile

    let l:char_col = hlvimlib#text#VirtcolToCharcol(winnr(), a:line_num, a:target_virt_col)

    let l:before = strcharpart(l:line_content, 0, l:char_col - 1)
    let l:after = strcharpart(l:line_content, l:char_col)
    call setline(a:line_num, l:before . a:char . l:after)
endfunction

