
module Objectively
  Edge = Struct.new(:source, :target, :calls, keyword_init: true) do
    def label
      calls.join("\n")
    end
  end
end
