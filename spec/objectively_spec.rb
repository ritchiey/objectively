# frozen_string_literal: true

require 'pry'

module Objectively
  class Diagram
    def self.draw(output:, &block)
      new(&block).draw(output: output)
    end

    def initialize(&_block)
      yield
    end

    def draw(output:)
      GraphViz.new(:G, type: :digraph) do |g|
        example = g.add_nodes('Example')
        a = g.add_nodes('A:1')
        b = g.add_nodes('B:1')
        g.add_edges(example, a, label: '1. do_it()')
        g.add_edges(a, b, label: %[2. say("hello")\n3. say("world")])
      end.output(output)
    end
  end
end

RSpec.describe Objectively do
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

  context 'when we trace a some code' do
    subject(:draw) do
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
      Objectively::Diagram.draw(output: { png: 'trace.png' }) do
        a.do_it
      end
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
