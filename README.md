# fastlane_flows 

## Lanes

####:beta


####:prod


####:beta_and_prod


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
