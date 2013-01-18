module DataFactory
  module Random

    CHARS = ['A'..'Z', 'a'..'z', '0'..'9'].map{|r|r.to_a}.flatten

    # Generates a random string of letters and numbers of length
    def random_string_of_length(length)
      str = ''
      1.upto(length) do
        str << CHARS[rand(CHARS.size)]
      end
      str
    end

    # Generates a random string of random length, which has a maximum
    # length of max_length
    def random_string_upto_length(max_length)
      length = random_integer(max_length)
      random_string_of_length(length)
    end

    # Generates a random integer that is at most max_size
    def random_integer(max_size)
      1 + rand(max_size)
    end

  end
end
