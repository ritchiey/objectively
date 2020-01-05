# frozen_string_literal: true

require 'pry'
require 'binding_of_caller'

module Objectively
  Message = Struct.new(:source, :target, :method, :args, keyword_init: true) do
    def to_s
      "#{method}(#{args.map(&:inspect).join(', ')})"
    end
  end

  Edge = Struct.new(:source, :target, :calls, keyword_init: true) do
    def label
      calls.join("\n")
    end
  end

  class Diagram
    def self.draw(output:, &block)
      new
        .trace(&block)
        .draw(output: output)
    end

    def trace(&_block)
      trace = TracePoint.trace(:call) do |tp|
        # messages <<
        # Message.new(
        #   source: tp.binding.of_caller(2).eval('self'),
        #   target: tp.binding.eval('self'),
        #   method: tp.callee_id,
        #   args: ['some_argument']
        # )
      end
      yield
      self
    ensure
      trace.disable
    end

    def draw(output:)
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
        # example = added_nodes['Example']
        # a = added_nodes['A:1']
        # b = added_nodes['B:1']
        # g.add_edges(example, a, label: '1. do_it()')
        # g.add_edges(a, b, label: %[2. say("hello")\n3. say("world")])
      end.output(output)
    end

    private

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
      @messages ||= [
        Message.new(
          source: 'Example',
          target: 'A:1',
          method: 'do_it',
          args: []
        ),
        Message.new(
          source: 'A:1',
          target: 'B:1',
          method: 'say',
          args: ['hello']
        ),
        Message.new(
          source: 'A:1',
          target: 'B:1',
          method: 'say',
          args: ['world']
        )
      ]
    end

    def objects
      [
        'Example',
        'A:1',
        'B:1'
      ]
    end
  end
end

RSpec.describe Objectively do # ~> NameError: uninitialized constant RSpec
  it 'has a version number' do
    expect(Objectively::VERSION).not_to be nil
  end

  it 'draws a graph' do
    require 'ruby-graphviz'

    GraphViz.new(:G, type: :digraph) do |g|
      example = g.add_nodes('Example')
      a = g.add_nodes('A:1')
      b = g.add_nodes('B:1')

      g.add_edges(example, a, label: '1. do_it()')
      g.add_edges(a, b, label: %[2. say("hello")\n3. say("world")])
    end.output(png: 'hello_world.png')
  end

  context 'Objectively::Diagram' do
    let(:diagram) do
      Objectively::Diagram.new
    end

    context 'when we trace a short program' do
      let(:trace) do
        stub_const 'A', Class.new
        A.class_eval do
          def initialize(output)
            @output = output
          end

          def do_it
            @output.say 'hello'
            @output.say 'world'
          end
        end
        stub_const 'B', Class.new
        B.class_eval do
          def say(text)
            puts(text)
          end
        end
        a = A.new(B.new)
        diagram.trace do
          a.do_it
        end
      end

      describe 'and draw the trace' do
        let(:draw) do
          trace.draw(output: { png: 'trace.png' })
        end

        before do
          allow(GraphViz).to receive(:new)
            .and_yield(graph_viz)
            .and_return(graph_viz)
        end
        let(:graph_viz) { instance_double('GraphViz') }

        let(:node_a1) { double(:node_a1) }
        let(:node_b1) { double(:node_b1) }
        let(:node_example) { double(:node_example) }

        it 'draws a directed graph of the calls' do
          expect(graph_viz).to receive(:add_nodes)
            .with('Example')
            .and_return(node_example)
          expect(graph_viz)
            .to receive(:add_nodes)
            .with('A:1')
            .and_return(node_a1)
          expect(graph_viz)
            .to receive(:add_nodes)
            .with('B:1')
            .and_return(node_b1)
          expect(graph_viz)
            .to receive(:add_edges)
            .with(node_example, node_a1, label: '1. do_it()')
          expect(graph_viz)
            .to receive(:add_edges)
            .with(node_a1, node_b1, label: %[2. say("hello")\n3. say("world")])
          expect(graph_viz).to receive(:output).with(png: 'trace.png')
          draw
        end
      end
    end
  end
end
