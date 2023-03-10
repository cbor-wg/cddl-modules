require 'open3'

data = ARGF.read
result = ''
err = ''
puts data.gsub(/^::: (.+)\n((?:.*?\n)*?):::$/) {
  command = $1
  data = $2
  case command
  in /\Acddlc /
     result, err, _s = Open3.capture3(command, stdin_data: data)
     warn err
     "$ #{command}\n" << data
  in /\Acheck\z/
     if result != data
       warn "*** result != check"
       warn "** result = #{result.inspect}"
       warn "** check = #{data.inspect}"
     end
  in /\Aoutput\z/
     result
  in /\Awarnings\z/
     err
  end
}
