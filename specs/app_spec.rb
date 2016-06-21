require_relative 'spec_helper'

RSpec.describe Graphs::Parser do
  context "with the test graph" do
    subject { described_class.new("AB5 BC4 CD8 DC8 DE6 AD5 CE2 EB3 AE7") }

    describe '#to_h' do
      it "has a route from A to B of 5" do
        expect(subject.to_h['A']['B']).to eq 5
      end
      it "has a route from D to C of 8" do
        expect(subject.to_h['C']['E']).to eq 2
      end
    end
  end
end

RSpec.describe Graphs::Distance do
  context "with the test graph" do
    let(:graph_distances) { Graphs::Parser.new("AB5 BC4 CD8 DC8 DE6 AD5 CE2 EB3 AE7").to_h }
    subject { described_class.new(graph_distances) }

    describe '#call' do
      context "1. The route A-B-C" do
        it { expect(subject.call(%w(A B C))).to eq 9 }
      end

      context "2. The route A-D" do
        it { expect(subject.call(%w(A D))).to eq 5 }
      end

      context "3. The route A-D-C" do
        it { expect(subject.call(%w(A D C))).to eq 13 }
      end

      context "4. The route A-E-B-C-D" do
        it { expect(subject.call(%w(A E B C D))).to eq 22 }
      end

      context "5. The route A-E-D" do
        it { expect(subject.call(%w(A E D))).to eq "NO SUCH ROUTE" }
      end

    end
  end
end

# TODO:
# supply via file






