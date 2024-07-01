" Author: Hanley Lee
" Website: https://www.hanleylee.com
" GitHub: https://github.com/hanleylee
" License:  MIT License


if has("python3")
    let g:Asciiart_Py = "py3 "
    let g:Asciiart_Pyeval = function("py3eval")
    echom g:Asciiart_Pyeval
else
    echoe 'Error: has("python3") == 0'
    finish
endif

if exists('g:asciiart#loaded')
    finish
else
    let g:asciiart#loaded = 1
endif

silent! exec g:Asciiart_Py "pass"
exec g:Asciiart_Py "import vim, sys, os, re, os.path"
exec g:Asciiart_Py "import asciiart"
" exec g:Asciiart_Py "cwd = vim.eval('expand(\"<sfile>:p:h\")')"
" exec g:Asciiart_Py "cwd = re.sub(r'(?<=^.)', ':', os.sep.join(cwd.split('/')[1:])) if os.name == 'nt' and cwd.startswith('/') else cwd"
" exec g:Asciiart_Py "sys.path.insert(0, os.path.join(cwd, 'xxx', 'python'))"
