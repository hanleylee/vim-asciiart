" Author: Hanley Lee
" Website: https://www.hanleylee.com
" GitHub: https://github.com/hanleylee
" License:  MIT License

function! s:arrowChar(direct)
    if a:direct == 'up'
        return '^'
    elseif a:direct == 'down'
        return 'V'
    elseif a:direct == 'left'
        return '<'
    elseif a:direct == 'right'
        return '>'
    else
        echoerr 'direct error: ' . a:direct
    endif
endfunction

function! s:shouldDrawCross(cur_char, direct)
    if a:direct == 'up' || a:direct == 'down'
        if a:cur_char == '-' || a:cur_char == '>' || a:cur_char == '<'
            return v:true
        else
            return v:false
        endif
    elseif a:direct == 'left' || a:direct == 'right'
        if a:cur_char == '|' || a:cur_char == '^' || a:cur_char == 'V'
            return v:true
        else
            return v:false
        endif
    else
        echoerr 'direct error: ' . a:direct
    endif
endfunction

function asciiart#arrowmove(direct)
    let l:cur_char_col = charcol('.')
    let l:cur_virt_col = virtcol('.')
    let l:cur_line_num = line('.')
    let l:end_virt_col = virtcol('$')

    " 确保列存在, 否则就用空格填充
    if l:cur_virt_col >= l:end_virt_col
        let l:cur_char = ' '
    else
        let l:cur_char = hlvimlib#text#GetCharAtLineCol(line('.'), charcol('.'))
    endif

    " 设置当前位置的符号 {{{
    if l:cur_char == '+'
        let l:cur_replace_char = '+'
    elseif s:shouldDrawCross(l:cur_char, a:direct)
        let l:cur_replace_char = '+'
    else
        let l:cur_replace_char = (a:direct == 'up' || a:direct == 'down') ? '|' : '-'
    endif
    call asciiart#utils#SetCharAtLineCol(l:cur_line_num, l:cur_virt_col, l:cur_replace_char)
    " }}}

    " 设置下一个位置的符号 {{{
    if a:direct == 'up'
        let l:next_line_num = l:cur_line_num - 1
        let l:next_virt_col = l:cur_virt_col
    elseif a:direct == 'down'
        let l:next_line_num = l:cur_line_num + 1
        let l:next_virt_col = l:cur_virt_col
    elseif a:direct == 'left'
        let l:next_line_num = l:cur_line_num
        let l:next_virt_col = l:cur_virt_col - 1
    elseif a:direct == 'right'
        let l:next_line_num = l:cur_line_num
        let l:next_virt_col = l:cur_virt_col + 1
    else
        echoerr 'direct error: ' . a:direct
    endif

    call asciiart#utils#EnsureColEnough(l:next_line_num, l:next_virt_col)

    let l:next_char_col = hlvimlib#text#VirtcolToCharcol(winnr(), l:next_line_num, l:next_virt_col)
    let l:next_char = hlvimlib#text#GetCharAtLineCol(l:next_line_num, l:next_char_col)
    if l:next_char == '+'
        let l:next_replace_char = '+'
    elseif s:shouldDrawCross(l:next_char, a:direct)
        let l:next_replace_char = '+'
    else
        let l:next_replace_char = s:arrowChar(a:direct)
    endif

    call asciiart#utils#SetCharAtLineCol(l:next_line_num, l:next_virt_col, l:next_replace_char)
    " }}}

    " 设置光标位置
    " call setpos('.', [bufnr('%'), l:next_line, l:next_col])
    let l:next_byte_col = virtcol2col(winnr(), l:next_line_num, l:next_virt_col)
    call cursor(l:next_line_num, l:next_byte_col)
    " redraw
endfunction

function! asciiart#WrapBlockWithASCII()
    " 提取起始和结束位置的行和列
    let l:start_line = min([line("'<"), line("'>")])
    let l:end_line = max([line("'<"), line("'>")])
    let l:start_col = min([virtcol("'<"), virtcol("'>")])
    let l:end_col = max([virtcol("'<"), virtcol("'>")])
    let l:wrap_width = l:end_col - l:start_col + 1

    call asciiart#utils#EnsureLineEnough(l:end_line)

    " 遍历每一行, 包裹边缘
    for line_num in range(l:start_line, l:end_line)
        " 获取当前行的内容和长度
        let l:line_content = getline(line_num)
        let l:line_length = strchars(l:line_content)

        call asciiart#utils#EnsureColEnough(line_num, l:end_col)

        " 在起始和结束列插入 |
        let l:before = strpart(l:line_content, 0, l:start_col - 1)
        let l:after = strpart(l:line_content, l:end_col)

        if line_num == l:start_line || line_num == l:end_line
            let l:middle = repeat('-', l:wrap_width - 2)
            let l:new_line = l:before . '+' . l:middle . '+' . l:after
        else
            let l:middle = strpart(l:line_content, l:start_col, l:wrap_width - 2)
            let l:new_line = l:before . '|' . l:middle . '|' . l:after
        endif

        " 设置新行内容
        call setline(line_num, l:new_line)
    endfor

    call cursor(l:end_line, l:end_col)
    " call setpos('.', [bufnr('%'), l:end_line, l:end_col, 0])
    " redraw
endfunction

" get all corners => { `cornertype`: [`line`, `char_col`]}
function! asciiart#container_box_all_corners()
    let box = asciiart#bridge#lookupContainerBox()
    if len(box) != 4
        echoerr "can't find any match box"
        return []
    endif
    let box_line_start = box[0]
    let box_col_start = box[1]
    let box_width = box[2]
    let box_height = box[3]

    return {
                \ 'topleft': [box_line_start, box_col_start],
                \ 'bottomleft': [box_line_start + box_height - 1, box_col_start],
                \ 'topright': [box_line_start, box_col_start + box_width - 1],
                \ 'bottomright': [box_line_start + box_height - 1, box_col_start + box_width - 1],
                \ }
endfunction

" get all sides => { `sidetype`: `line` or `char_col`}
function! asciiart#container_box_all_sides()
    let box = asciiart#bridge#lookupContainerBox()
    if len(box) != 4
        echoerr "can't find any match box"
        return []
    endif
    let box_line_start = box[0]
    let box_col_start = box[1]
    let box_width = box[2]
    let box_height = box[3]

    return {
                \ 'start_line': box_line_start,
                \ 'end_line': box_line_start + box_height - 1,
                \ 'start_col': box_col_start,
                \ 'end_col': box_col_start + box_width - 1,
                \ }
endfunction

function! asciiart#boxObject(type) abort
    let l:all_sides = asciiart#container_box_all_sides()
    let l:inset_space = a:type ==# 'i' ? 1 : 0
    let l:start_line = l:all_sides['start_line'] + l:inset_space
    let l:end_line = l:all_sides['end_line'] - l:inset_space
    let l:start_col = l:all_sides['start_col'] + l:inset_space
    let l:end_col = l:all_sides['end_col'] - l:inset_space

    call setpos("'<", [bufnr(), l:start_line, l:start_col, 0])
    call setpos("'>", [bufnr(), l:end_line, l:end_col, 0])
    execute "normal! `<\<C-v>`>"
endfunction

function! asciiart#boxclear(type)
    let l:all_sides = asciiart#container_box_all_sides()
    let l:inset_space = a:type ==# 'i' ? 1 : 0
    let l:start_line = l:all_sides['start_line'] + l:inset_space
    let l:end_line = l:all_sides['end_line'] - l:inset_space
    let l:start_col = l:all_sides['start_col'] + l:inset_space
    let l:end_col = l:all_sides['end_col'] - l:inset_space
    let l:box_width = l:end_col - l:start_col + 1

    for line_num in range(l:start_line, l:end_line)
        let l:line_content = getline(line_num)
        let l:before = strcharpart(l:line_content, 0, l:start_col - 1)
        let l:between = repeat(' ', l:box_width)
        let l:after = strcharpart(l:line_content, l:end_col)
        call setline(line_num, l:before . l:between . l:after)
    endfor
endfunction
