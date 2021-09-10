command CphReceive lua require 'cphelper.receive'.receive()
command -nargs=* CphTest lua require 'cphelper.process_tests'.process(<f-args>)
command -nargs=* CphRetest lua require 'cphelper.process_tests'.process_retests(<f-args>)
command -nargs=+ CphDelete lua require 'cphelper.modify_tc'.deletetc(<f-args>)
command -nargs=1 CphEdit lua require 'cphelper.modify_tc'.edittc(<f-args>)
highlight Underline gui=underline cterm=underline
