require_relative '../lib/app'

RSpec.describe Console do
  subject do
    described_class.new('fixtures/example_graph.txt', read_strategy: read_strategy,
                                                      write_strategy: write_strategy)
  end
  let(:buffer) { [] }
  let(:write_strategy) { ->(*args) { buffer.concat args } }

  describe '#call' do
    context "when I enter 'shortest a c'" do
      let :read_strategy do
        double(:read_strategy).tap do |strategy|
          allow(strategy)
            .to receive(:call)
            .and_return("shortest a c", '') # last '' to exit
        end
      end

      it "prints the answer" do
        subject.call
        expect(buffer).to include("The shortest path has a distance of 9.")
      end
    end

    context "when I enter 'shortest B B'" do
      let :read_strategy do
        double(:read_strategy).tap do |strategy|
          allow(strategy)
            .to receive(:call)
            .and_return("shortest B B", '') # last '' to exit
        end
      end

      it "prints the answer" do
        subject.call
        expect(buffer).to include("The shortest path has a distance of 9.")
      end
    end
  end
end

RSpec.describe RailwayQuery do
  context "with the test vertexes" do
    subject { described_class.new(Graphs::Parser.new("AB5 BC4 CD8 DC8 DE6 AD5 CE2 EB3 AE7").vertexes) }

    describe '#call' do
      {
        [
          "1. The distance of the route A-B-C.",
          :distance, *%w(A B C)
        ] => "The distance is 9.",
        [
          "2. The distance of the route A-D.",
          :distance, *%w(A D)
        ] => "The distance is 5.",
        [
          "3. The distance of the route A-D-C.",
          :distance, *%w(A D C)
        ] => "The distance is 13.",
        [
          "4. The distance of the route A-E-B-C-D.",
          :distance, *%w(A E B C D)
        ] => "The distance is 22.",
        [
          "5. The distance of the route A-E-D.",
          :distance, *%w(A E D)
        ] => "NO SUCH ROUTE"
      }.each do |(description, action, *params), result|
        it description do
          expect(subject.call(action, *params)).to eq result
        end
      end
    end
  end
end

RSpec.describe Graphs::Parser do
  context "with the test vertexes" do
    subject { described_class.new("AB5 BC4 CD8 DC8 DE6 AD5 CE2 EB3 AE7") }

    describe '#vertexes' do
      it "has a route from A to B of 5" do
        expect(subject.vertexes['A']['B']).to eq 5
      end
      it "has a route from D to C of 8" do
        expect(subject.vertexes['C']['E']).to eq 2
      end
    end
  end

  context "with a different format" do
    subject { described_class.new("ab5, bc4, cd8") }

    describe '#vertexes' do
      it "has a route from A to B of 5" do
        expect(subject.vertexes['A']['B']).to eq 5
      end
      it "has a route from D to C of 8" do
        expect(subject.vertexes['C']['D']).to eq 8
      end
    end
  end
end

RSpec.describe Graphs::HardPath do
  context "with the test vertexes" do
    let(:graph_weights) { Graphs::Parser.new("AB5 BC4 CD8 DC8 DE6 AD5 CE2 EB3 AE7").vertexes }
    subject { described_class.new(graph_weights, nodes: nodes) }

    describe '#weight' do
      context "1. The route A-B-C" do
        let(:nodes) { %w(A B C) }
        it { expect(subject.weight).to eq 9 }
      end

      context "2. The route A-D" do
        let(:nodes) { %w(A D) }
        it { expect(subject.weight).to eq 5 }
      end

      context "3. The route A-D-C" do
        let(:nodes) { %w(A D C) }
        it { expect(subject.weight).to eq 13 }
      end

      context "4. The route A-E-B-C-D" do
        let(:nodes) { %w(A E B C D) }
        it { expect(subject.weight).to eq 22 }
      end

      context "5. The route A-E-D" do
        let(:nodes) { %w(A E D) }
        it { expect(subject.weight).to eq false }
      end
    end
  end
end

RSpec.describe Graphs::Path do
  context "with the test vertexes" do
    let(:graph_weights) { Graphs::Parser.new("AB5 BC4 CD8 DC8 DE6 AD5 CE2 EB3 AE7").vertexes }
    subject { described_class.new(graph_weights, start: start, destination: destination) }

    describe '#count' do
      context "6. Starting and ending at C with a maximum of 3 stops" do
        let(:start)       { 'C' }
        let(:destination) { 'C' }
        it "finds 2 paths" do
          actual = subject.count(max_traverses: 3)
          expect(actual).to eq 2
        end
      end

      context "7. Starting at A and ending at C with exactly 4 stops" do
        let(:start)       { 'A' }
        let(:destination) { 'C' }
        it "finds 3 paths" do
          actual = subject.count(min_traverses: 4, max_traverses: 4)
          expect(actual).to eq 3
        end
      end

      context "10. From C to C with a weight of less than 30" do
        let(:start)       { 'C' }
        let(:destination) { 'C' }
        it "finds 7 paths" do
          expect(subject.count(max_weight: 29)).to eq 7
        end
      end
    end

    describe '#lightest' do
      context "8. The lightest route from A to C" do
        let(:start)       { 'A' }
        let(:destination) { 'C' }
        it { expect(subject.lightest).to eq 9 }
      end

      context "9. The lightest route from B to B" do
        let(:start)       { 'B' }
        let(:destination) { 'B' }
        it { expect(subject.lightest).to eq 9 }
      end
    end
  end
end
