module Objectively
  Message = Struct.new(:source, :target, :method, :args, keyword_init: true) do
    def to_s
      "#{method}(#{args.map(&:inspect).join(', ')})"
    end
  end
end
