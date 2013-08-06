module GhostWriter
  module Format
    module Markdown
      private
      def headword(text, level = 1)
        "#{'#'*level} #{text}"
      end

      def paragraph(text)
        text + "\n"
      end

      def separator(length)
        "-" * length
      end

      def quote(text, quote_format = nil)
        "```#{quote_format}\n#{text}\n```"
      end

      def list(text, level = 1)
        "#{"  " * (level - 1)}- #{text}"
      end

      def link(text, url)
        "[#{text}](#{url})"
      end
    end
  end
end
