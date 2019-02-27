Language Translation Integration
==============

![This script was last tested in Nuix 7.8](https://img.shields.io/badge/Script%20Tested%20in%20Nuix-7.8-green.svg)

View the GitHub project [here](https://github.com/Nuix/Language-Translation-Integration) or download the latest release [here](https://github.com/Nuix/Language-Translation-Integration/releases).

# Overview

The Language Translation Integration project integrates with third-party translation services like Google Cloud Translation or Microsoft Cognitive Services. Translated text can be added as custom metadata, or appended to (or cleared from) an item's text.

# Getting Started

## Setup

Begin by downloading the latest release of this code.  Extract the contents of the archive into your Nuix scripts directory.  In Windows the script directory is likely going to be either of the following:

- `%appdata%\Nuix\Scripts` - User level script directory
- `%programdata%\Nuix\Scripts` - System level script directory

## Prerequisites for Google Cloud Translation
### Google Cloud Translation API Access
You will need a Google Cloud Platform account to access the Google Cloud Translation API. Use the following steps to sign up for an account:
1. Sign up for an account here, https://cloud.google.com/translate/
2. From the [Google Cloud Platform Console](https://console.cloud.google.com/home) select `APIs & Services`
3. From the [API Dashboard](https://console.cloud.google.com/apis/dashboard) select `Enable APIs and Services`
4. Search for and enable the `Google Cloud Translation API`
5. On the [Google Cloud Translation API overview](https://console.cloud.google.com/apis/api/translate.googleapis.com/overview) select `Credentials`
6. Click `Create credentials` and select `API Key`
7. Copy the API key provided

### Easy Translate Gem
The script makes use of a RubyGem which must be installed using the following command run via Command Prompt from your Nuix Workstation installation directory

`c:\Program Files\Nuix\Nuix 7.8>jre\bin\java -Xmx500M -classpath lib\* org.jruby.Main --command gem install easy_translate --user-install`

## Prerequisites for Microsoft Cognitive Services
### Microsoft Translator Text API Access
You will need a key for Microsoft's Translator Text API. This can be obtained by:
1. Signing into Microsoft Azure.
2. Navigating to Cognitive Services.
3. Adding & configuring a Text-Translation Service.
4. Once created the API key is accessible from the console.

# Running the Script
The script requires a case be opened and items are selected. Once you have selected items and started the script, an input dialog will prompt the user to select from the available `NuixTranslator` options. The selected `NuixTranslator` will prompt for settings (if required) and present a progress dialog as it runs through the current selected items.

The script uses sticky settings which are kept within the script's directory. Each `NuixTranslator` will have its own sticky settings, and settings can be saved/loaded through JSON.

## The `NuixTranslator` Class
The `NuixTranslator` class is the base class for presenting a settings dialog and progress dialog as it runs through the current selected items. Translated text can be appended to an item's original text or added to the item as custom metadata.

New options can be implemented by creating new `NuixTranslator` subclasses. Each class defines a constant `NAME` string representing the translation option (used when showing dialogs), and a public method `.run(items)` to get the input settings and iterate over the selected items. The script uses introspection to locate all the classes which derive from `NuixTranslator`, so there is no extra work that needs to be done to make script aware of your `NuixTranslator` except make sure the class file is placed in the script's sub-directory "Translators".

### Translation Options

- *Language* - The translation target language.
- *Operation* - Append Text or Add Custom Metadata.
  - Append Text will use the separator: "\n----------Translation to <Language>---------\n"
  - Add Custom Metadata will use the field name "Translation to <Language>"
  
## `NuixTranslator` Subclasses

## Google Cloud Translation
Uses Google Cloud Translation through the EasyTranslate gem.

Adds the ability to detect an item's language, annotating the item's language as a tag or custom metadata.

## Microsoft Cognitive Services
Uses the Microsoft Translator Text API.

## Clear Translations
Removes translation text from selected items, obtaining an item's original text using methods from `NuixTranslator`.

# Cloning this Repository

This script relies on code from [Nx](https://github.com/Nuix/Nx) to present a settings dialog and progress dialog.  This JAR file is not included in the repository (although it is included in release downloads).  If you clone this repository, you will also want to obtain a copy of Nx.jar by either:
1. Building it from [the source](https://github.com/Nuix/Nx)
2. Downloading an already built JAR file from the [Nx releases](https://github.com/Nuix/Nx/releases)

Once you have a copy of Nx.jar, make sure to include it in the same directory as the script.

# License

```
Copyright 2018 Nuix

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
