require 'spec_helper'

describe Blacklight::PresenterFactory do
  let(:config) { Blacklight::Configuration.new }
  let(:custom_presenter_class) { double }
  subject { described_class.new(config, action).build }

  context "by default" do
    let(:action) { nil }
    it { is_expected.to eq(Blacklight::DocumentPresenter) }
  end

  context "with an index action" do
    let(:action) { 'index' }
    it { is_expected.to eq(Blacklight::IndexPresenter) }
    context "when using the value defined in the blacklight configuration" do
      before { config.index.document_presenter_class = custom_presenter_class }
  	  it { is_expected.to eq(custom_presenter_class) }
    end
  end

  context "with a show action" do
    let(:action) { 'show' }
    it { is_expected.to eq(Blacklight::ShowPresenter) }
    context "when using the value defined in the blacklight configuration" do
      before { config.show.document_presenter_class = custom_presenter_class }
      it { is_expected.to eq(custom_presenter_class) }
    end
  end

  context "with an unrecognized action" do
    let(:action) { 'foo' }
    it "raises an error" do
      expect{ subject }.to raise_error(RuntimeError)
    end
  end

end
