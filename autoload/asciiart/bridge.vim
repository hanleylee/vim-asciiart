" Author: Hanley Lee
" Website: https://www.hanleylee.com
" GitHub: https://github.com/hanleylee
" License:  MIT License

" format: `[line, column, width, height]`
function! asciiart#bridge#lookupContainerBox()
    let box = g:Asciiart_Pyeval('asciiart.lookupContainerBox()')
    return box
endfunction

