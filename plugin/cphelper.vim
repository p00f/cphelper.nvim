command CphReceive lua require 'cphelper.receive'.receive()
command CphStop lua require 'cphelper.receive'.stop()
command -nargs=* CphTest silent lcd %:p:h | lua require 'cphelper.process_tests'.process(<f-args>)
command -nargs=* CphRetest silent lcd %:p:h | lua require 'cphelper.process_tests'.process_retests(<f-args>)
command -nargs=+ CphDelete silent lcd %:p:h | lua require 'cphelper.modify_tc'.deletetc(<f-args>)
command -nargs=1 CphEdit silent lcd %:p:h | lua require 'cphelper.modify_tc'.edittc(<f-args>)
highlight Underline gui=underline cterm=underline
