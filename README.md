Language Translation Integration
==============

![This script was last tested in Nuix 9.0](https://img.shields.io/badge/Script%20Tested%20in%20Nuix-9.0-green.svg)

View the GitHub project [here](https://github.com/Nuix/Language-Translation-Integration) or download the latest release [here](https://github.com/Nuix/Language-Translation-Integration/releases).

View the Java Docs [here](https://nuix.github.io/Language-Translation-Integration/).

# Overview

The Language Translation Integration project integrates with third-party translation services like Google Cloud Translation or Microsoft Cognitive Services. Translated text can be added as custom metadata, or appended to (or cleared from) an item's text.

# Getting Started

## Setup

Begin by downloading the latest release of this code.  Extract the contents of the archive into your Nuix scripts directory.  In Windows the script directory is likely going to be either of the following:

- `%appdata%\Nuix\Scripts` - User level script directory
- `%programdata%\Nuix\Scripts` - System level script directory

## Prerequisites for LibreTranslate

This translator makes use of the [LibreTranslate](https://github.com/uav4geo/LibreTranslate) project.  LibreTranslate provides a translation server which can be ran locally.  You will need to [install and run the LibreTranslate server](https://github.com/uav4geo/LibreTranslate#install-and-run).

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
The script requires a case be opened and items are selected.

![image](https://user-images.githubusercontent.com/22751246/54239011-5d51ea00-44f0-11e9-81e3-89c1ef79a42e.png)

Once you have selected items and started the script, an input dialog will prompt the user to select from the available `NuixTranslator` options. The selected `NuixTranslator` will prompt for settings (if required) and present a progress dialog as it runs through the current selected items.

The script uses sticky settings which are kept within the script's directory. Each `NuixTranslator` will have its own sticky settings, and settings can be saved/loaded through JSON.

## The `NuixTranslator` Class
`NuixTranslator` is the base class, for initializing settings and progress dialogs as it runs through the current selected items. It contains methods for getting an item's original text, appending translated text, or adding translations as custom metadata.

Translation options are implemented as `NuixTranslator` subclasses, each defining a constant `NAME` string for itself (mostly used when showing dialogs), and a public method `.run(items)` to get the input settings and iterate over the selected items.

New translation options can be added by creating a `NuxiTranslator` subclass .rb file in the script's "Translators" subdirectory.

### Common Translation Settings

- *Language* - The translation target language.
- *Operation* - Append Text or Add Custom Metadata.
  - Append Text will use the separator: `\n----------Translation to <Language>---------\n`
  ![image](https://user-images.githubusercontent.com/22751246/54239317-41027d00-44f1-11e9-8519-73fd5c627643.png)
  - Add Custom Metadata will use the field name `Translation to <Language>`
  ![image](https://user-images.githubusercontent.com/22751246/54239393-71e2b200-44f1-11e9-9ee5-4f0e6070e7ee.png)

## Translation Options
### Google Cloud Translation

![image](https://user-images.githubusercontent.com/22751246/54239180-d5b8ab00-44f0-11e9-9a1f-e9548cfbed07.png)

Uses Google Cloud Translation through the EasyTranslate gem.

Adds the ability to detect an item's language, annotating the item's language as a tag or custom metadata.

#### Detection Settings
- *Apply detected language as custom metadata*
  - *Custom Metadata Field Name* - Custom metadata field name to use
- *Tag items with detected language?*
  - *Tag Name* - Applied tag will be `<Tag Name>|<Detected Language>`

### Microsoft Cognitive Services

![image](https://user-images.githubusercontent.com/22751246/54239118-a4d87600-44f0-11e9-999b-7f6bcc256f3e.png)

Uses the Microsoft Translator Text API.

### LibreTranslate

Once you have installed the LibreTranslate server and have it running, open a Nuix case, select the items you would like to translate and run the script.  When prompted, select the choice **Libre Translate**.

If you have your LibreTranslate server running on `localhost` and port `5000` then for **API URL** you will provide the value `http://localhost:5000/translate`.  Then choose the source language, translation destination language and other options.

Special thanks to @Trekky12 for [contributing](https://github.com/Nuix/Language-Translation-Integration/pull/2) the LibreTranslate connector!

### Clear Translations
Removes translation text from selected items, obtaining an item's original text using methods from `NuixTranslator`.

# Cloning this Repository

This script relies on code from [Nx](https://github.com/Nuix/Nx) to present a settings dialog and progress dialog.  This JAR file is not included in the repository (although it is included in release downloads).  If you clone this repository, you will also want to obtain a copy of Nx.jar by either:
1. Building it from [the source](https://github.com/Nuix/Nx)
2. Downloading an already built JAR file from the [Nx releases](https://github.com/Nuix/Nx/releases)

Once you have a copy of Nx.jar, make sure to include it in the same directory as the script.

# License

```
Copyright 2019 Nuix

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
