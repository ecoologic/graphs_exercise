require_relative 'spec_helper'

RSpec.describe Graphs::Distance do
  context "with the test graph" do
    let(:graph_distances) { %w(AB5 BC4 CD8 DC8 DE6 AD5 CE2 EB3 AE7) }
    subject { described_class.new(graph_distances) }

    describe '#call' do
      context "1. The route A-B-C" do
        it { expect(subject.call(:a, :b, :c)).to eq 9 }
      end
    end
  end
end

# TODO:
# supply via file

