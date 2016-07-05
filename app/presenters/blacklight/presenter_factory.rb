module Blacklight
  class PresenterFactory
    attr_reader :config, :action

    def initialize(config, action=nil)
      @config = config
      @action = action
    end

    def build
      case action
      when nil
        default_presenter_class	
      when 'show', 'citation'
        show_presenter_class
      when 'index'
        index_presenter_class
      else
        raise RuntimeError, "Unable to determine presenter type for #{action}"
      end
    end

    private

      def default_presenter_class
        Blacklight::DocumentPresenter
      end

      def show_presenter_class
        config.show.document_presenter_class
      end

      def index_presenter_class
        config.index.document_presenter_class
      end      
  end
end
