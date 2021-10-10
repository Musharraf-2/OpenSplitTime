# frozen_string_literal: true

require "rails_helper"

RSpec.describe LotteryDivision, type: :model do
  subject { described_class.find_by(name: division_name) }
  let(:division_name) { "Slow People" }
  let(:lottery) { subject.lottery }

  it { is_expected.to strip_attribute(:name) }
  it { is_expected.to capitalize_attribute(:name) }

  describe "#draw_ticket!" do
    let(:result) { subject.draw_ticket! }

    context "when no tickets have been created" do
      before { expect(lottery.tickets.count).to eq(0) }
      it "does not create a draw" do
        expect { result }.not_to change { LotteryDraw.count }
      end

      it "returns nil" do
        expect(result).to be_nil
      end
    end

    context "when there are tickets available" do
      before { lottery.delete_and_insert_tickets! }
      it "creates a draw" do
        expect { result }.to change { LotteryDraw.count }.by(1)
      end

      it "returns the created draw with expected attributes" do
        expect(result).to be_a(LotteryDraw)
        expect(result.lottery).to eq(lottery)
        expect(result.ticket.entrant.division).to eq(subject)
      end
    end

    context "when tickets have been created but have all been drawn" do
      before do
        lottery.delete_and_insert_tickets!
        number_of_tickets = subject.tickets.count
        expect(number_of_tickets).not_to eq(0)
        number_of_tickets.times { subject.draw_ticket! }
      end

      it "does not create a draw" do
        expect { result }.not_to change { LotteryDraw.count }
      end

      it "returns nil" do
        expect(result).to be_nil
      end
    end
  end

  describe "#full?" do
    let(:result) { subject.full? }
    context "when the winners list and wait list are full" do
      let(:division_name) { "Never Ever Evers" }
      it "returns true" do
        expect(result).to eq(true)
      end
    end

    context "when the winners list is full but the wait list is not full" do
      let(:division_name) { "Elses" }
      before { 2.times { subject.draw_ticket! } }
      it "returns false" do
        expect(result).to eq(false)
      end
    end

    context "when the winners list is not full" do
      let(:division_name) { "Elses" }
      it "returns false" do
        expect(result).to eq(false)
      end
    end

    context "when no tickets have been drawn" do
      let(:division_name) { "Veterans" }
      it "returns false" do
        expect(result).to eq(false)
      end
    end
  end

  describe "#winning_entrants" do
    let(:result) { subject.winning_entrants }

    context "when the winning entrants have all been drawn" do
      let(:division_name) { "Never Ever Evers" }
      it "returns winning entries equal in number to the maximum entries for the division" do
        expect(result.count).to eq(subject.maximum_entries)
        expect(result).to all be_a(LotteryEntrant)
      end
    end

    context "when some winning entrants have been drawn" do
      let(:division_name) { "Elses" }
      it "returns winning entries equal in number to the total draws for the division" do
        expect(result.count).to eq(2)
        expect(result).to all be_a(LotteryEntrant)
      end
    end

    context "when no entrants have been drawn" do
      let(:division_name) { "Veterans" }
      it "returns an empty collection" do
        expect(result).to be_empty
      end
    end
  end

  describe "#wait_list_entrants" do
    let(:result) { subject.wait_list_entrants }

    context "when draws have spilled over into the wait list" do
      let(:division_name) { "Never Ever Evers" }
      it "returns wait listed entrants" do
        expect(result.count).to eq(2)
        expect(result).to all be_a(LotteryEntrant)
      end
    end

    context "when draws have not spilled over into the wait list" do
      let(:division_name) { "Elses" }
      it "returns an empty collection" do
        expect(result).to be_empty
      end
    end

    context "when no entrants have been drawn" do
      let(:division_name) { "Veterans" }
      it "returns an empty collection" do
        expect(result).to be_empty
      end
    end
  end
end
