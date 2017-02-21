# Overview
Collection of custom [Fastlane](https://github.com/fastlane/fastlane) lanes

## Lanes

####Before all:
build number incrementation

####`:beta`
1. produce build with beta scheme
2. upload to diawi.com
3. post to telegram message with download link and build meta info

####`:prod`
1. produce build with production scheme
2. upload to diawi.com
3. post to telegram message with download link and build meta info

####`:beta_and_prod`
1. run `:beta` lane
2. run `:prod` lane

## Custom actions

###[upload_to_diawi()](fastlane_flows/Fastlane/actions/upload_to_diawi.rb)

**Parameters:**

Parameter | Example
----------|--------
diawi_token: | Access token to [Diawi](https://www.diawi.com) API 
path_to_ipa: | Full path to .ipa file

*All paremeters are required!*

**Usage example:**
```ruby
upload_to_diawi(diawi_token: "DIAWI_TOKEN",
                path_to_ipa: "full/path/to/my-app.ipa")
```

**Output:**

...
