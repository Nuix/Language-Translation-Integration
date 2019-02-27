require 'uri'
require 'net/http'

# Class for translating items using Microsoft Cognitive Services.
class MicrosoftCognitiveServices < NuixTranslator
  NAME = 'Microsoft Cognitive Services'.freeze

  def self.name
    NAME
  end

  LANGUAGES = { 'af' =>	'Afrikaans',
                'ar' =>	'Arabic',
                'bn' =>	'Bangla',
                'bs' =>	'Bosnian (Latin)',
                'bg' =>	'Bulgarian',
                'yue' =>	'Cantonese (Traditional)',
                'ca' =>	'Catalan',
                'zh-Hans' =>	'Chinese Simplified',
                'zh-Hant' =>	'Chinese Traditional',
                'hr' =>	'Croatian',
                'cs' =>	'Czech',
                'da' =>	'Danish',
                'nl' =>	'Dutch',
                'en' =>	'English',
                'et' =>	'Estonian',
                'fj' =>	'Fijian',
                'fil' =>	'Filipino',
                'fi' =>	'Finnish',
                'fr' =>	'French',
                'de' =>	'German',
                'el' =>	'Greek',
                'ht' =>	'Haitian Creole',
                'he' =>	'Hebrew',
                'hi' =>	'Hindi',
                'mww' =>	'Hmong Daw',
                'hu' =>	'Hungarian',
                'is' =>	'Icelandic',
                'id' =>	'Indonesian',
                'it' =>	'Italian',
                'ja' =>	'Japanese',
                'sw' =>	'Kiswahili',
                'tlh' =>	'Klingon',
                'tlh-Qaak' =>	'Klingon (plqaD)',
                'ko' =>	'Korean',
                'lv' =>	'Latvian',
                'lt' =>	'Lithuanian',
                'mg' =>	'Malagasy',
                'ms' =>	'Malay',
                'mt' =>	'Maltese',
                'nb' =>	'Norwegian',
                'fa' =>	'Persian',
                'pl' =>	'Polish',
                'pt' =>	'Portuguese',
                'otq' =>	'Queretaro Otomi',
                'ro' =>	'Romanian',
                'ru' =>	'Russian',
                'sm' =>	'Samoan',
                'sr-Cyrl' =>	'Serbian (Cyrillic)',
                'sr-Latn' =>	'Serbian (Latin)',
                'sk' =>	'Slovak',
                'sl' =>	'Slovenian',
                'es' =>	'Spanish',
                'sv' =>	'Swedish',
                'ty' =>	'Tahitian',
                'ta' =>	'Tamil',
                'te' =>	'Telugu',
                'th' =>	'Thai',
                'to' =>	'Tongan',
                'tr' =>	'Turkish',
                'uk' =>	'Ukrainian',
                'ur' =>	'Urdu',
                'vi' =>	'Vietnamese',
                'cy' =>	'Welsh',
                'yua' =>	'Yucatec Maya' }.freeze

  # Creates a new NuixTranslator using Microsoft Cognitive Services API.
  def initialize
    super(NAME, LANGUAGES)
    @main_tab.appendTextField('api_key', 'API Key', '')
    # load langs from CSV?
    add_translation
    @input.validateBeforeClosing { |v| validate_input(v) }
  end

  # Runs Translator on the items.
  #
  # @param items [Set<Item>]
  def run(items)
    return nil if super(items).nil?

    url = 'https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to='
    @uri = URI.parse(url + @langs.key(@settings['translation_language']))
    @headers = { 'Ocp-Apim-Subscription-Key' => @settings['api_key'] }
    ['Content-Type', 'Accept'].each { |k| @headers[k] = 'application/json' }
    progress_dialog
  end

  private

  # Translates text using Microsoft Cognitive Services.
  #
  # @param text [String] original text
  # @return [String, nil] translated text, or nil if there was an error
  def ms_translate(text)
    https = Net::HTTP.new(@uri.host, @uri.port)
    https.use_ssl = true
    begin
      req = Net::HTTP::Post.new(@uri.request_uri, @headers)
      req.body = [{ 'Text' => text }].to_json
      response = https.request(req)
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
  # @param response [Net::HTTPResponse] from Microsoft Cognitive Services
  # @return [String, nil] translated text, or nil if an error occured
  def response_body(response)
    case response
    when Net::HTTPSuccess
      return JSON.parse(response.body)[0]['translations'][0]['text']
    when Net::HTTPUnauthorized
      msg = 'invalid API key?'
    when Net::HTTPServerError
      msg = 'try again later?'
    end
    @progress.logMessage("ERROR: #{response.message}")
    @progress.logMessage(msg) unless msg.nil?
  end

  # Translates item using Microsoft Cognitive Services.
  #
  # @param item [Item] a Nuix item
  def translate(item)
    @progress.setMainStatusAndLogIt('Translating')
    text = get_original_text(item)
    return nil if text.empty?

    translated = ms_translate(text)
    super(item, translated) unless translated.nil? || translated.empty?
  end

  # Validation function for input.
  #  Checks for API key.
  #
  # @param values [Hash] input values
  # @return [true, false] if in validate state
  def validate_input(values)
    return true unless values['api_key'].strip.empty?

    CommonDialogs.showWarning("Please provide a #{NAME} API Key.")
    false
  end
end
