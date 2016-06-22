require_relative 'spec_helper'

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
end

RSpec.describe Graphs::Weight do
  context "with the test vertexes" do
    let(:graph_weights) { Graphs::Parser.new("AB5 BC4 CD8 DC8 DE6 AD5 CE2 EB3 AE7").vertexes }
    subject { described_class.new(graph_weights) }

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

RSpec.describe Graphs::Path do
  context "with the test vertexes" do
    let(:graph_weights) { Graphs::Parser.new("AB5 BC4 CD8 DC8 DE6 AD5 CE2 EB3 AE7").vertexes }
    subject { described_class.new(graph_weights) }

    describe '#count' do
      context "6. Starting and ending at C with a maximum of 3 stops" do
        it "finds 2 paths" do
          actual = subject.count('C', 'C', max_traverses: 3)
          expect(actual).to eq 2
        end
      end
    end

    describe '#count' do
      context "6. Starting and ending at C with a maximum of 3 stops" do
        it "finds 2 paths" do
          actual = subject.count('C', 'C', max_traverses: 3)
          expect(actual).to eq 2
        end
      end

      context "7. Starting at A and ending at C with exactly 4 stops" do
        it "finds 3 paths" do
          actual = subject.count('A', 'C', min_traverses: 4, max_traverses: 4)
          expect(actual).to eq 3
        end
      end

      context "10. From C to C with a weight of less than 30" do
        it "finds 7 paths" do
          expect(subject.count('C', 'C', max_weight: 29)).to eq 7
        end
      end
    end

    describe '#lightest' do
      context "8. The lightest route from A to C" do
        it { expect(subject.lightest('A', 'C')).to eq 9 }
      end

      context "9. The lightest route from A to B" do
        it { expect(subject.lightest('B', 'B')).to eq 9 }
      end
    end
  end
end
