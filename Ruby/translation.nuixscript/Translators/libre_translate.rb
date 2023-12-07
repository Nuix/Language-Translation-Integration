require 'uri'
require 'net/http'
require 'json'

# Class for translating items using Libre Translate API
class LibreTranslate < NuixTranslator
  NAME = 'Libre Translate'.freeze

  def self.name
    NAME
  end

  
  LANGUAGES = { 
    'auto' => 'Auto',
    'en' => 'English',
    'sq' => 'Albanian',
    'ar' => 'Arabic',
    'az' => 'Azerbaijani',
    'zh' => 'Chinese',
    'cs' => 'Czech',
    'da' => 'Danish',
    'nl' => 'Dutch',
    'eo' => 'Esperanto',
    'fi' => 'Finnish',
    'fr' => 'French',
    'gl' => 'Galician',
    'de' => 'German',
    'el' => 'Greek',
    'he' => 'Hebrew',
    'hi' => 'Hindi',
    'hu' => 'Hungarian',
    'id' => 'Indonesian',
    'ga' => 'Irish',
    'it' => 'Italian',
    'ja' => 'Japanese',
    'kab' => 'Kabyle',
    'ko' => 'Korean',
    'nb' => 'Norwegian Bokmål',
    'oc' => 'Occitan',
    'fa' => 'Persian',
    'pl' => 'Polish',
    'pt' => 'Portuguese',
    'ru' => 'Russian',
    'sk' => 'Slovak',
    'es' => 'Spanish',
    'sv' => 'Swedish',
    'zgh' => 'Tamazight-Standard Moroccan',
    'tr' => 'Turkish',
    'uk' => 'Ukrainian',
    'vi' => 'Vietnamese'
  }.freeze

  # Creates a new NuixTranslator using Libre Translate API.
  def initialize
    super(NAME, LANGUAGES)
	@input.setSize(500,400)
    @main_tab.appendTextField('api_url', 'API URL', '')
    add_translation_options
    add_translation
    add_translation_tagging
    @input.validateBeforeClosing { |v| validate_input(v) }
  end

  def add_translation_tagging
    @main_tab.appendCheckBox('tag_items_success', 'Tag items which are successfully translated?', false)
    @main_tab.appendTextField('tag_name_success', 'Tag Name', 'Translations|success')
    @main_tab.enabledOnlyWhenChecked('tag_name_success', 'tag_items_success')

    @main_tab.appendCheckBox('tag_items_failure', 'Tag items which couldn\'t be translated?', false)
    @main_tab.appendTextField('tag_name_failure', 'Tag Name', 'Translations|failure')
    @main_tab.enabledOnlyWhenChecked('tag_name_failure', 'tag_items_failure')
  end

  def add_translation_options
    @main_tab.appendTextField('http_timeout', 'HTTP Timeout (sec.)', 30.to_s)
    @main_tab.appendComboBox('translation_language_from', 'Source Language', @langs.values)
  end

  # Runs Translator on the items.
  #
  # @param items [Set<Item>]
  def run(items)
    return nil if super(items).nil?

    @uri = URI.parse(@settings['api_url'])
    @headers = { 'Content-Type' => 'application/json' }
    progress_dialog
  end

  private

  # Translates text using Libre Translate API.
  #
  # @param text [String] original text
  # @return [String, nil] translated text, or nil if there was an error
  def libre_translate(text)
    http = Net::HTTP.new(@uri.host, @uri.port)
    http.use_ssl = true if @uri.instance_of? URI::HTTPS
    http.read_timeout = @settings['http_timeout'].to_i
    begin
      req = Net::HTTP::Post.new(@uri.request_uri, @headers)
      req.body = {  'q' => text,
                    'source' =>  @langs.key(@settings['translation_language_from']),
                    'target' =>  @langs.key(@settings['translation_language'])
        }.to_json
      response = http.request(req)
      puts response.code
      return response_body(response)
    rescue StandardError => ex
      puts "ERROR: #{ex.message}"
    end
  end

  # Progress dialog loop for processing items.
  def progress_dialog
    ProgressDialog.forBlock do |pd|
      super(pd, 'Translating')
      $current_case.with_write_access do
        @items.each_with_index do |item, index|
          break if advance(index, "Item GUID: #{item.getGuid}").nil?

          translate(item)
        end
      end
      pd.setCompleted
    end
  end

  # Handles response from Net::HTTPSuccess
  #
  # @param response [Net::HTTPResponse] from Libre Translate API
  # @return [String, nil] translated text, or nil if an error occured
  def response_body(response)
    case response
    when Net::HTTPSuccess
      puts response.body
      return JSON.parse(response.body)['translatedText']
    when Net::HTTPServerError
      msg = 'try again later?'
    end
    @progress.logMessage("ERROR: #{response.message}")
    @progress.logMessage(msg) unless msg.nil?
  end

  # Translates item using Libre Translate API.
  #
  # @param item [Item] a Nuix item
  def translate(item)
    @progress.setMainStatusAndLogIt('Translating')
    text = get_original_text(item)
    return nil if text.empty?

    if @settings['tag_items_success'] 
      item.removeTag("#{@settings['tag_name_success']}")
    end
    if @settings['tag_items_failure'] 
      item.removeTag("#{@settings['tag_name_failure']}")
    end

    translated = libre_translate(text)
    if translated.nil?
      item.addTag("#{@settings['tag_name_failure']}") if @settings['tag_items_failure']
      @progress.logMessage("No response received! Please try again later")
      return nil 
    end

    item.addTag("#{@settings['tag_name_success']}") if @settings['tag_items_success']

    super(item, translated) unless translated.nil? || translated.empty?
  end

  # Validation function for input.
  #  Checks for API URL.
  #
  # @param values [Hash] input values
  # @return [true, false] if in validate state
  def validate_input(values)
    return true unless values['api_url'].strip.empty?

    CommonDialogs.showWarning("Please provide a #{NAME} API URL.")
    false
  end

  # The translation message.
  #
  # @return [String]
  def translation_message
    "Translation with libretranslate to #{@settings['translation_language']}"
  end
end
