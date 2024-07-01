" Author: Hanley Lee
" Website: https://www.hanleylee.com
" GitHub: https://github.com/hanleylee
" License:  MIT License

function! s:SetCharAtLineCol(line, col, char)
    let l:line_content = getline(a:line)
    let l:line_length = strlen(l:line_content)

    " 确保列存在, 否则就用空格填充
    if a:col > l:line_length
        let l:line_content .= repeat(' ', a:col - l:line_length - 1)
    endif

    " 确保行存在
    while line('$') < a:line
        call append(line('$'), '')
    endwhile

    let l:before = strcharpart(l:line_content, 0, a:col - 1)
    let l:after = strcharpart(l:line_content, a:col)
    call setline(a:line, l:before . a:char . l:after)
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
    let l:cur_col = virtcol('.')   
    let l:cur_line = line('.')
    let l:cur_char = getline('.')[l:cur_col - 1]
    " echom l:cur_char
    " echom l:arrow_char
    " echom l:cur_char == l:arrow_char

    " 设置当前位置的符号 {{{
    " echom s:isCross(l:cur_char, a:direct)

    if l:cur_char == '+'
        let l:cur_fill_char = '+'
    elseif s:isCross(l:cur_char, a:direct)
        " echom 111
        let l:cur_fill_char = '+'
    else
        let l:cur_fill_char = (a:direct == 'up' || a:direct == 'down') ? '|' : '-'
    endif
    call s:SetCharAtLineCol(l:cur_line, l:cur_col, l:cur_fill_char)
    " }}}

    " 设置下一个位置的符号 {{{
    if a:direct == 'up'
        let l:next_line = l:cur_line - 1
        let l:next_col = l:cur_col
    elseif a:direct == 'down'
        let l:next_line = l:cur_line + 1
        let l:next_col = l:cur_col
    elseif a:direct == 'left'
        let l:next_line = l:cur_line
        let l:next_col = l:cur_col - 1
    elseif a:direct == 'right'
        let l:next_line = l:cur_line
        let l:next_col = l:cur_col + 1
    else
        echoerr 'direct error: ' . a:direct
    endif
    let next_char = getline(l:next_line)[l:next_col - 1]
    if l:next_char == '+'
        let l:next_fill_char = '+'
    elseif s:isCross(l:next_char, a:direct)
        let l:next_fill_char = '+'
    else
        let l:next_fill_char = s:arrowChar(a:direct)
    endif

    call s:SetCharAtLineCol(l:next_line, l:next_col, l:next_fill_char)
    " }}}

    " 设置光标位置
    " call setpos('.', [bufnr('%'), l:next_line, l:next_col])
    call cursor(l:next_line, l:next_col)
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
        let l:line_length = strlen(l:line_content)

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
    let corners = g:Ascii_Pyeval('asciiart.loopupContainerBox')
    return corners
endfunction

" h_direct: `left`, `right`
" v_direct: `top`, `bottom`
" 返回值是行数与列数
function! asciiart#findcorner(h_direct, v_direct)
    " 获取当前行和列号
    let current_line = line('.')
    " 顶和底不能重叠, 因此区分 top 还是 bottom
    let current_col = col('.')
    let current_col_index = col('.') - 1
    let target_line = a:v_direct == 'top' ? current_line : current_line + 1
    " 这个是idx, 从0开始计数
    let target_col_idx = -1

    " let matches = matchlist(search_content, '+', search_start_col)
    " let matches = asciiart#utils#matchall(l:line_content, '+')
    let target_col_idx = asciiart#utils#FindNearestChar(getline('.'), current_col_index, '|', a:h_direct)
    " echom 'target_col_idx: ' . target_col_idx
    while target_line > 0 && target_line <= line('$')
        let l:line_content = getline(target_line)
        if l:line_content[target_col_idx] == '+'
            break
        endif

        let target_line = a:v_direct == 'top' ? target_line - 1 : target_line + 1
    endwhile

    if target_col_idx == -1
        return []
    else
        return [target_line, target_col_idx + 1]
    endif

endfunction

function! asciiart#boxObject(type) abort
    " normal! $
    " let start_row = searchpos('\s*```', 'bn')[0]
    " let end_row = searchpos('\s*```', 'n')[0]
    let topleft = asciiart#findcorner('left', 'top')
    let bottomright = asciiart#findcorner('right', 'bottom')
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
    let topleft = asciiart#findcorner('left', 'top')
    let bottomright = asciiart#findcorner('right', 'bottom')
    if len(topleft) == 0 || len(bottomright) == 0
        echoerr "Corner not found!"
        return
    endif

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
