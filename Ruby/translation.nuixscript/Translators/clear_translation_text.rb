# Class for clearing translations from text.
class ClearTranslations < NuixTranslator
  NAME = 'Clear Translations'.freeze

  def self.name
    NAME
  end

  def initialize; end

  # Clears translations from the items' text.
  #
  # @param items [Set<Item>]
  def run(items)
    return nil unless confirm

    super(items)
    progress_dialog
  end

  private

  # Clears translation from an item's text.
  #
  # @param item [Item] a Nuix item
  def clear_translation(item)
    newtxt = get_original_text(item)
    item.modify { |m| m.replace_text(newtxt) } unless newtxt.empty?
  end

  # Confirms the user wants to clear translations.
  #
  # @return [true, false] if YES_OPTION was chosen, false otherwise
  def confirm
    msg = 'Are you sure?'
    title = 'Clear Translations from Text'
    type = JOptionPane::YES_NO_OPTION
    response = JOptionPane.showConfirmDialog(nil, msg, title, type)
    response == JOptionPane::YES_OPTION
  end

  # Progress dialog loop for processing items.
  def progress_dialog
    ProgressDialog.forBlock do |pd|
      super(pd, 'Clearing Translations')
      $current_case.with_write_access do
        @items.each_with_index do |item, index|
          break if advance(index, "Item GUID: #{item.getGuid}").nil?

          clear_translation(item)
        end
      end
      pd.setCompleted
    end
  end
end
