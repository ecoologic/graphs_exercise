require_relative 'spec_helper'

RSpec.describe Graphs::Parser do
  context "with the test graph" do
    subject { described_class.new("AB5 BC4 CD8 DC8 DE6 AD5 CE2 EB3 AE7") }

    describe '#to_h' do
      it "has a route from A to B of 5" do
        expect(subject.to_h['A']['B']).to eq 5
      end
      it "has a route from D to C of 8" do
        expect(subject.to_h['A']['B']).to eq 5
      end
    end
  end
end

# RSpec.describe Graphs::Distance do
#   context "with the test graph" do
#     let(:graph_distances) { Graphs::Parser.new(%w(AB5 BC4 CD8 DC8 DE6 AD5 CE2 EB3 AE7)).to_a }
#     subject { described_class.new(graph_distances) }

#     describe '#call' do
#       context "1. The route A-B-C" do
#         it { expect(subject.call(:a, :b, :c)).to eq 9 }
#       end

#       context "2. The route A-D" do
#         it { expect(subject.call(:a, :d)).to eq 5 }
#       end
#     end
#   end
# end

# TODO:
# supply via file

