command CphReceive lua require 'receive'.pass()
command -nargs=* CphTest lua require 'process_tests'.process(<f-args>)
command -nargs=* CphRetest lua require 'process_tests'.process_retests(<f-args>)
command -nargs=+ CphDelete lua require 'modify_tc'.deletetc(<f-args>)
command -nargs=1 CphEdit lua require 'modify_tc'.edittc(<f-args>)
highlight Underline gui=underline cterm=underline
