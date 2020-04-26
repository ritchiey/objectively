require 'objectively/message'
require 'objectively/edge'

module Objectively
  class Diagram
    def self.draw(output:, &block)
      new
        .trace(&block)
        .draw(output: output)
    end

    def trace(&_block)
      require 'binding_of_caller'
      cwd = Dir.pwd
      trace = TracePoint.trace(:call) do |tp|

        if tp.path.start_with?(cwd)
          messages << Message.new(
            source: object_name(tp.binding.of_caller(2).eval('self')),
            target: object_name(tp.binding.eval('self')),
            method: tp.callee_id.to_s,
            args: tp.parameters.map do |(_, arg_name)|
              tp.binding.eval(arg_name.to_s)
            end
          )
        end
      rescue StandardError => error
        puts "Backtrace:\n\t#{error.backtrace.join("\n\t")}"
      end
      yield
      self
    ensure
      trace.disable
    end

    def draw(output:)
      require 'graphviz'
      GraphViz.new(:G, type: :digraph) do |g|
        added_nodes = {}
        objects.each do |object_name|
          added_nodes[object_name] = g.add_nodes(object_name)
        end
        edges.values.each do |edge|
          g.add_edges(
            added_nodes[edge.source],
            added_nodes[edge.target],
            label: edge.label
          )
        end
      end.output(output)
    end

    private

    def object_name(obj)
      object_names[object_key obj] ||= if obj.respond_to? :__name_in_diagram__
                                         obj.__name_in_diagram__
                                       else
                                         default_object_name(obj)
                                       end
    end

    def default_object_name(obj)
      class_name = obj.class.name
      object_name = object_names[object_key obj]
      return object_name if object_name

      id = (classes[class_name] || 0) + 1
      classes[class_name] = id

      "#{class_name}:#{id}"
    end

    def object_key(obj)
      "#{obj.class.name}:#{obj.object_id}"
    end

    def classes
      @classes ||= {}
    end

    def object_names
      @object_names ||= {}
    end

    def edges
      @edges ||= begin
                   edges = {}
                   messages.each_with_index do |message, index|
                     key = [message.source, message.target].freeze
                     existing_edge = edges[key]
                     message_line = "#{index + 1}. #{message}"
                     if existing_edge
                       existing_edge.calls << message_line
                     else
                       edges[key] = Edge.new(
                         source: message.source,
                         target: message.target,
                         calls: [message_line]
                       )
                     end
                   end
                   edges
                 end
    end

    def messages
      @messages ||= []
    end

    def objects
      object_names.values
    end
  end
end

