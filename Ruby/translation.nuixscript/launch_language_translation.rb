# Menu Title: Language Translation
# Needs Case: true
# Needs Selected Items: true

require 'java'
java_import "javax.swing.JOptionPane"
require File.join(File.dirname(__FILE__), 'language_translation.rb')
# Get NuixTranslator classes.
translators = NuixTranslator.translators
# Select a NuixTranslator using JOptionPane.
msg = 'Select option'
title = 'Nuix Translation'
type = JOptionPane::PLAIN_MESSAGE
opts = translators.keys.to_java
choice = JOptionPane.showInputDialog(nil, msg, title, type, nil, opts, nil)
# Get chosen NuixTranslator subclass and run with current selected items.
translators[choice].new.run($current_selected_items) unless choice.nil?
