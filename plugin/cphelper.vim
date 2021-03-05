command CPHReceive lua require 'receive'.pass()
command -nargs=* CPHTest lua require 'test'.wrapper(<f-args>)
