
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

