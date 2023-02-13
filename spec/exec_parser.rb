# frozen_string_literal: true

class ExecSpecParser
  def self.parse(data)
    result = { env: {} }
    parsing_env = false
    data.split("\n").map(&:strip).each do |l|
      if parsing_env
        if l == "--- ENV END ---"
          parsing_env = false
        else
          k, v = l.split("=", 2)
          result[:env][k] = v
        end
        next
      end

      if l.start_with?("EXEC: ")
        result[:exec] = l[6..]
      elsif l.start_with?("SHELL: ")
        result[:shell] = l[7..]
      elsif l.start_with?("ARGS: ")
        result[:args] = l[6..].split(",")
      elsif l.start_with?("PWD: ")
        result[:pwd] = l[5..]
      elsif l.start_with?("STDIN:")
        hex_data = l[7..]
        next if hex_data.nil? || hex_data.empty?

        result[:stdin] = [hex_data].pack("H*")
      elsif l == "--- ENV BEGIN ---"
        parsing_env = true
      end
    end

    raise EOFError if parsing_env

    result
  end
end
