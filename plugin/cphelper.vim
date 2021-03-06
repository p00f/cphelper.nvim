command CphReceive lua require 'receive'.pass()
command -nargs=* CphTest lua require 'test_wrapper'.wrapper(<f-args>)
command -nargs=* CphRetest lua require 'test_wrapper'.retest_wrapper(<f-args>)
