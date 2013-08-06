module GhostWriter
  module Format
    module Rst
      private
      def headword(text, level = 1)
        char = case level
               when 1
                 "*"
               when 2
                 "="
               when 3
                 "-"
               when 4
                 "^"
               end
        text + "\n" + char * text.length * 2
      end

      def paragraph(text)
        text + "\n"
      end

      def separator(length)
        ""
      end

      def quote(text, quote_format = nil)
        if quote_format
          marker = ".. code-block:: #{quote_format}" + "\n"
        else
          marker = "::" + "\n"
        end
        marker + "#{text.each_line.map{|line| line.chomp.empty? ? line : "   " + line}.join}"
      end

      def list(text, level = 1)
        "#{"  " * (level - 1)}* #{text}"
      end

      def link(text, url)
        "`#{text} #{url}`_"
      end
    end
  end
end
