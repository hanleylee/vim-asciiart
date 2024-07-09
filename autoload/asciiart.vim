" Author: Hanley Lee
" Website: https://www.hanleylee.com
" GitHub: https://github.com/hanleylee
" License:  MIT License

function! s:SetCharAtLineCol(line, char_col, char)
    let l:line_content = getline(a:line)
    let l:line_length = strchars(l:line_content)

    " 确保列存在, 否则就用空格填充
    if a:char_col > l:line_length
        let l:line_content .= repeat(' ', a:char_col - l:line_length - 1)
    endif

    " 确保行存在
    while line('$') < a:line
        call append(line('$'), '')
    endwhile

    let l:before = strcharpart(l:line_content, 0, a:char_col - 1)
    let l:after = strcharpart(l:line_content, a:char_col)
    call setline(a:line, l:before . a:char . l:after)
endfunction

function! s:GetCharAtLineCol(line, char_col)
    let line_content = getline(a:line)
    let cur_char = strcharpart(line_content, a:char_col - 1, 1, 0)
    return cur_char
endfunction

function! s:VirtcolToCharcol(win_id, line, virtcol)
    let line_content = getline(a:line)
    " convert virtcol to byte based col
    let byte_col = virtcol2col(a:win_id, a:line, a:virtcol)
    " convert byte based col to character index col
    let char_col = charidx(line_content, byte_col) + 1
    return char_col
endfunction

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

function! s:isCross(cur_char, direct)

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
    let cur_char_col = charcol('.')   
    let cur_virt_col = virtcol('.')   
    let cur_line = line('.')
    let cur_char = strcharpart(getline('.'), charcol('.') - 1, 1, 0)

    " 设置当前位置的符号 {{{
    " echom s:isCross(l:cur_char, a:direct)

    if cur_char == '+'
        let cur_fill_char = '+'
    elseif s:isCross(cur_char, a:direct)
        " echom 111
        let cur_fill_char = '+'
    else
        let cur_fill_char = (a:direct == 'up' || a:direct == 'down') ? '|' : '-'
    endif
    call s:SetCharAtLineCol(cur_line, cur_char_col, cur_fill_char)
    " }}}

    " 设置下一个位置的符号 {{{
    if a:direct == 'up'
        let next_line = cur_line - 1
        let next_virt_col = cur_virt_col
    elseif a:direct == 'down'
        let next_line = cur_line + 1
        let next_virt_col = cur_virt_col
    elseif a:direct == 'left'
        let next_line = cur_line
        let next_virt_col = cur_virt_col - 1
    elseif a:direct == 'right'
        let next_line = cur_line
        let next_virt_col = cur_virt_col + 1
    else
        echoerr 'direct error: ' . a:direct
    endif
    let next_char_col = s:VirtcolToCharcol(winnr(), next_line, next_virt_col)
    let next_char = s:GetCharAtLineCol(next_line, next_char_col)
    if next_char == '+'
        let next_fill_char = '+'
    elseif s:isCross(next_char, a:direct)
        let next_fill_char = '+'
    else
        let next_fill_char = s:arrowChar(a:direct)
    endif

    call s:SetCharAtLineCol(next_line, next_char_col, next_fill_char)
    " }}}

    " 设置光标位置
    " call setpos('.', [bufnr('%'), l:next_line, l:next_col])
    call cursor(next_line, next_virt_col)
    " redraw
endfunction

function! asciiart#WrapBlockWithASCII()
    " 提取起始和结束位置的行和列
    let l:start_line = min([line("'<"), line("'>")])
    let l:end_line = max([line("'<"), line("'>")])
    let l:start_col = min([virtcol("'<"), virtcol("'>")])
    let l:end_col = max([virtcol("'<"), virtcol("'>")])

    " 确保行存在
    while line('$') < l:end_line
        call append(line('$'), '')
    endwhile

    " 遍历每一行，包裹边缘
    for lnum in range(l:start_line, l:end_line)
        " 获取当前行的内容和长度
        let l:line_content = getline(lnum)
        let l:line_length = strchars(l:line_content)

        " 确保列数足够，并填充空格
        if l:start_col > l:line_length
            let l:line_content .= repeat(' ', l:start_col - l:line_length - 1)
        endif
        if l:end_col > l:line_length
            let l:line_content .= repeat(' ', l:end_col - l:line_length - 1)
        endif

        " 在起始和结束列插入 |
        let l:before = strpart(l:line_content, 0, l:start_col - 1)
        let l:after = strpart(l:line_content, l:end_col)

        if lnum == l:start_line || lnum == l:end_line
            let l:middle = repeat('-', l:end_col - l:start_col - 1)
            let l:new_line = l:before . '+' . l:middle . '+' . l:after
        else
            let l:middle = strpart(l:line_content, l:start_col, l:end_col - l:start_col - 1)
            let l:new_line = l:before . '|' . l:middle . '|' . l:after
        endif

        " 设置新行内容
        call setline(lnum, l:new_line)
    endfor

    call cursor(l:end_line, l:end_col)
    " call setpos('.', [bufnr('%'), l:end_line, l:end_col, 0])
    " redraw
endfunction

function! asciiart#lookupContainerBox()
    let box = g:Asciiart_Pyeval('asciiart.lookupContainerBox()')
    return box
endfunction

" corner_type: `topleft`, `topright`, `bottomleft`, `bottomright`
" return: [line, column]
function! asciiart#findcorner(corner_type)
    let box = asciiart#lookupContainerBox()
    if len(box) != 4
        echoerr "can't find any match box"
        return []
    endif
    " let box_origin = [box[0], box[1]]
    let box_line_start = box[0]
    let box_col_start = box[1]
    let box_width = box[2]
    let box_height = box[3]

    if a:corner_type == 'topleft'
        return [box_line_start, box_col_start]
    elseif a:corner_type == 'bottomleft'
        return [box_line_start + box_height - 1, box_col_start]
    elseif a:corner_type == 'topright'
        return [box_line_start, box_col_start + box_width - 1]
    elseif a:corner_type == 'bottomright'
        return [box_line_start + box_height - 1, box_col_start + box_width - 1]
    else
        echoerr 'wrong cornertype' . a:corner_type
        return []
    endif

endfunction

function! asciiart#boxObject(type) abort
    " normal! $
    " let start_row = searchpos('\s*```', 'bn')[0]
    " let end_row = searchpos('\s*```', 'n')[0]
    let topleft = asciiart#findcorner('topleft')
    let bottomright = asciiart#findcorner('bottomright')
    " echom topleft
    " echom bottomright
    if len(topleft) == 0 || len(bottomright) == 0
        echoerr "Corner not found!"
        return
    endif

    let start_line = topleft[0]
    let start_col = topleft[1]
    let end_line = bottomright[0]
    let end_col = bottomright[1]

    " if bottomright[1] == -1

    let buf_num = bufnr()
    if a:type ==# 'i'
        let start_line += 1
        let start_col += 1
        let end_line -= 1
        let end_col -= 1
    endif
    " echo a:type start_row end_row

    call setpos("'<", [buf_num, start_line, start_col, 0])
    call setpos("'>", [buf_num, end_line, end_col, 0])
    execute "normal! `<\<C-v>`>"
endfunction

function! asciiart#boxclear(type)
    let topleft = asciiart#findcorner('topleft')
    let bottomright = asciiart#findcorner('bottomright')

    let start_line = topleft[0]
    let start_col = topleft[1]
    let end_line = bottomright[0]
    let end_col = bottomright[1]

    " should extend box area
    if a:type == 'a'
        let start_line -= 1
        let start_col -= 1
        let end_line += 1
        let end_col += 1
    endif

    for line in range(start_line+1, end_line-1)
        let line_content = getline(line)
        let l:before = strcharpart(line_content, 0, start_col)
        let l:between = repeat(' ', end_col - start_col - 1)
        let l:after = strcharpart(line_content, end_col - 1)
        call setline(line, l:before . l:between . l:after)
    endfor
endfunction
