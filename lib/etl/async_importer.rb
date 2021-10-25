# frozen_string_literal: true

module ETL
  class AsyncImporter
    include ETL::Errors

    def self.import!(import_job)
      new(import_job).import!
    end

    attr_reader :errors

    def initialize(import_job)
      @import_job = import_job
      @errors = []
    end

    def import!
      import_job.start!
      set_etl_strategies
      extract_data if errors.empty?
      transform_data if errors.empty?
      load_records if errors.empty?
      set_finish_attributes
    end

    private

    attr_reader :import_job
    attr_writer :errors
    attr_accessor :extract_strategy, :transform_strategy, :load_strategy, :extracted_structs, :transformed_protos
    delegate :file, :format, :parent_type, :parent_id, to: :import_job

    def set_etl_strategies
      case format.to_sym
      when :lottery_entrants
        self.extract_strategy = Extractors::CsvFileStrategy
        self.transform_strategy = Transformers::LotteryEntrantsStrategy
        self.load_strategy = Loaders::AsyncInsertStrategy
      else
        errors << format_not_recognized_error(format)
      end
    end

    def extract_data
      import_job.extracting!
      extractor = ::ETL::Extractor.new(file, extract_strategy)
      self.extracted_structs = extractor.extract
      self.errors += extractor.errors
      import_job.update(row_count: extracted_structs.size)
    end

    def transform_data
      import_job.transforming!
      transformer = ::ETL::Transformer.new(extracted_structs, transform_strategy, parent: parent)
      self.transformed_protos = transformer.transform
      self.errors += transformer.errors
    end

    def load_records
      import_job.loading!
      loader = ::ETL::Loader.new(transformed_protos, load_strategy, import_job: import_job)
      loader.load_records
      self.errors += loader.errors
    end

    def set_finish_attributes
      import_job.finish!

      if errors.empty?
        import_job.update(:status => :finished)
      else
        import_job.update(:status => :failed, :error_message => errors.to_json)
      end
    end

    def parent
      parent_class.find_by(id: parent_id)
    end

    def parent_class
      @parent_class ||= parent_type.constantize
    end
  end
end
