# NX Bootstrap
begin
  require File.join(File.dirname(__FILE__), 'Nx.jar')
  java_import 'com.nuix.nx.NuixConnection'
  java_import 'com.nuix.nx.LookAndFeelHelper'
  java_import 'com.nuix.nx.dialogs.CommonDialogs'
  java_import 'com.nuix.nx.dialogs.ProgressDialog'
  java_import 'com.nuix.nx.dialogs.TabbedCustomDialog'
  LookAndFeelHelper.setWindowsIfMetal
  NuixConnection.setUtilities($utilities)
  NuixConnection.setCurrentNuixVersion(NUIX_VERSION)
end

# Base class for translating items.
class NuixTranslator
  SCRIPT_DIR = File.join(File.dirname(__FILE__), 'Translators')

  # The NuixTranslator subclasses.
  #
  # @return [Hash] {'Translator Name' => NuixTranslator subclass}
  def self.translators
    subs = Dir.glob(File.join(SCRIPT_DIR, '*.rb'))
    subs.each { |f| require f }
    translators = {}
    ObjectSpace.each_object(Class).select { |k| k < self }.each do |c|
      translators[c.name] = c
    end
    translators
  end

  # Creates a new Translator.
  #
  # @param name [String] NuixTranslator subclass name
  # @param languages [Hash] { 'en' => 'english', ... }
  def initialize(name, languages)
    settings_file = File.join(SCRIPT_DIR, "#{name}.json")
    @options = ['Append Text', 'Add Custom Metadata']
    @langs = languages
    @items = []
    @input = TabbedCustomDialog.new('Language Translation')
    @input.enableStickySettings(settings_file)
    @main_tab = @input.addTab('main_tab', name)
  end

  protected

  # Adds translation options to main tab of dialog.
  def add_translation
    @main_tab.appendComboBox('translation_language', 'Language', @langs.values)
    @main_tab.appendComboBox('translation_annotate', 'Operation', @options)
  end

  # Advances progress.
  #
  # @param index [Integer] index of item being processed
  # @param status [String] message for status/log
  # @return [nil, true] nil if abort was requested, true otherwise
  def advance(index, status)
    if @progress.abortWasRequested
      @progress.logMessage('Aborting...')
      return nil
    end

    @progress.setMainProgress(index)
    frac = "#{index}/#{@items.size}"
    @progress.setSubStatusAndLogIt("(#{frac}) #{status}")
    true
  end

  # Returns new text with translation appended.
  #
  # @param original [String] original text
  # @param translated [String] translated text
  # @return [String] of new text
  def get_new_text(original, translated)
    original + "\n----------#{translation_message}----------\n" + translated
  end

  # Returns original text if it had been translated.
  #
  # @param item [Item]
  # @return [String] of text, to the left of ---Tran if matched
  def get_original_text(item)
    text = item.getTextObject.toString
    mymatch = /(^.*?)\n---+Tran/m.match(text)
    return mymatch[1] unless mymatch.nil?

    text
  end

  # Initializes progress dialog @progress.
  #
  # @param progress [ProgressDialog]
  # @param title [String]
  def progress_dialog(progress, title)
    @progress = progress
    @progress.setTitle(title)
    @progress.setTimestampLoggedMessages(true)
    @progress.setMainStatusAndLogIt(title)
    @progress.setMainProgress(0, @items.size)
    @progress.setMainProgressVisible(true)
    @progress.setSubProgressVisible(false)
  end

  # Shows dialog and updates @settings with input results.
  #
  # @param items [Set<Item>]
  def run(items)
    @items = items
    return nil if @input.nil?

    @input.display
    return nil unless @input.getDialogResult

    @settings = @input.toMap
  end

  # Updates item with translation.
  #
  # @param item [Item] the item to update
  # @param translated [String] the translated text
  def translate(item, translated)
    case @settings['translation_annotate']
    when @options[0] # Append Text
      new_text = get_new_text(item.getTextObject.toString, translated)
      item.modify { |m| m.replace_text(new_text) }
    when @options[1] # Add Custom Metadata
      field_name = translation_message
      item.getCustomMetadata.putText(field_name, translated)
    end
  end

  private

  # The translation message.
  #
  # @return [String]
  def translation_message
    "Translation to #{@settings['translation_language']}"
  end
end
