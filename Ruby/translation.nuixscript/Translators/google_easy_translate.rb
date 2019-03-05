begin
  require 'easy_translate'
rescue Exception
  CommonDialogs.showError("Error resolving dependency 'easy_translate'.  Did you install the Ruby gem?")
  exit 1
end

# Class using EasyTranslate gem for Google.
class GoogleEasyTranslate < NuixTranslator
  NAME = 'Google Cloud Translation'.freeze

  def self.name
    NAME
  end

  # Creates a new NuixTranslator using EasyTranslate gem.
  def initialize
    super(NAME, languages)
    @main_tab.appendTextField('api_key', 'API Key', '')
    add_detection
    add_translation
    @input.validateBeforeClosing { |v| validate_input(v) }
  end

  # Runs Translator on the items.
  #
  # @param items [Set<Item>]
  def run(items)
    return nil if super(items).nil?

    EasyTranslate.api_key = @settings['api_key']
    @settings['detecting'] = @settings['apply_custom_metadata'] || @settings['tag_items']
    progress_dialog
  end

  private

  # Adds detection options to main tab of dialog.
  def add_detection
    @main_tab.appendSeparator('Detection Options')
    @main_tab.appendCheckBox('apply_custom_metadata', 'Apply detected language as custom metadata?', false)
    @main_tab.appendTextField('custom_metadata_field_name', 'Custom Metadata Field Name', 'Detected Language')
    @main_tab.enabledOnlyWhenChecked('custom_metadata_field_name', 'apply_custom_metadata')
    @main_tab.appendCheckBox('tag_items', 'Tag items with detected language?', false)
    @main_tab.appendTextField('top_level_tag', 'Tag Name', 'Detected Languages')
    @main_tab.enabledOnlyWhenChecked('top_level_tag', 'tag_items')
  end

  # Adds optional translation options to main tab of dialog.
  def add_translation
    @main_tab.appendSeparator('Translation Options')
    @main_tab.appendCheckBox('translate', 'Translate items?', true)
    super
    @main_tab.enabledOnlyWhenChecked('translation_language', 'translate')
    @main_tab.enabledOnlyWhenChecked('translation_annotate', 'translate')
  end

  # Detects language of an item and annotates.
  #
  # @param item [Item] a Nuix item
  def detect(item)
    @progress.setMainStatusAndLogIt('Detecting Language')
    lang = detect_language(get_original_text(item))
    return nil if lang.nil

    language = "#{@langs[lang]} (#{lang})"
    item.getCustomMetadata.putText(@settings['custom_metadata_field_name'], language) if @settings['apply_custom_metadata']
    item.addTag("#{@settings['top_level_tag']}|#{language}") if @settings['tag_items']
  end

  # Detects language of text using EasyTranslate gem.
  #
  # @param text [String] text
  # @return [String, nil] of language, or nil if no text/langauge detected.
  def detect_language(text)
    return nil if text.empty?

    langs = easy_detect(text)
    # Google returns "und" (undefined) if the language has not been detected
    return nil if langs.nil? || langs.eql?('und')

    langs.to_s
  end

  # Detects language of text using EasyTranslate gem.
  #
  # @param text [String] text
  def easy_detect(text)
    EasyTranslate.detect(text)
  rescue EasyTranslate::EasyTranslateException => ex
    @progress.logMessage("ERROR: #{ex.message}")
  end

  # Translates text using EasyTranslate gem.
  #
  # @param text [String] text
  def easy_translate(text)
    EasyTranslate.translate(text, format: 'text', to: @langs.key(@settings['translation_language']))
  rescue EasyTranslate::EasyTranslateException => ex
    @progress.logMessage("ERROR: #{ex.message}")
  end

  # Langague options available.
  #
  # @return [Hash] { 'en' => 'English', ... }
  def languages
    langs = EasyTranslate::LANGUAGES
    langs.each_value(&:capitalize!)
    langs
  end

  # The enabled options.
  #
  # @return [String] of the operations enabled
  def option_title
    options = []
    options << 'Detecting Languages' if @settings['detecting']
    options << 'Translating Text' if @settings['translate']
    options.join(' and ')
  end

  # Detects and/or translates items, depending on the enabled options.
  #
  # @param item [Item] a Nuix item
  def process(item)
    detect(item) if @settings['detecting']
    translate(item) if @settings['translate']
  end

  # Progress dialog loop for processing items.
  def progress_dialog
    ProgressDialog.forBlock do |pd|
      super(pd, option_title)
      $current_case.with_write_access do
        @items.each_with_index do |item, index|
          break if advance(index, "Item GUID: #{item.getGuid}").nil?

          process(item)
        end
      end
      pd.setCompleted
    end
  end

  # Translates item using EasyTranslate gem.
  #
  # @param item [Item] a Nuix item
  def translate(item)
    @progress.setMainStatusAndLogIt('Translating')
    text = get_original_text(item)
    return nil if text.empty?

    translated = easy_translate(text)
    super(item, translated) unless translated.nil? || translated.empty?
  end

  # Validation function for input.
  #  Checks for API key.
  #  Checks an option was checked.
  #  Checks tag or field name was entered, if required.
  #
  # @param values [Hash] input values
  # @return [true, false] if in validate state
  def validate_input(values)
    if values['api_key'].strip.empty?
      CommonDialogs.showWarning("Please provide a #{NAME} API Key.")
      return false
    end

    unless values['tag_items'] || values['apply_custom_metadata'] || values['translate']
      CommonDialogs.showWarning('Please select an option.')
      return false
    end

    if values['apply_custom_metadata'] && values['custom_metadata_field_name'].strip.empty?
      CommonDialogs.showWarning('Please provide a Custom Metadata Field Name.')
      return false
    end

    if values['tag_items'] && values['top_level_tag'].strip.empty?
      CommonDialogs.showWarning('Please provide a Top-level tag.')
      return false
    end

    true
  end
end
