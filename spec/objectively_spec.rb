# frozen_string_literal: true

require 'pry'

RSpec.describe Objectively do
  it 'has a version number' do
    expect(Objectively::VERSION).not_to be nil
  end

  it 'draws a graph' do
    require 'ruby-graphviz'

    GraphViz.new(:G, type: :digraph) do |g|
      # Create two nodes
      hello = g.add_nodes('A:123')
      world = g.add_nodes('B:456')

      # Create an edge between the two nodes
      g.add_edges(hello, world, label: %Q[1. say("hello")\n2. say("world")])
    end.output(png: 'hello_world.png')
  end
end
