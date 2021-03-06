command CphReceive lua require 'receive'.pass()
command -nargs=* CphTest lua require 'test'.wrapper(<f-args>)
command -nargs=* CphRetest lua require 'test'.retest_wrapper(<f-args>)
