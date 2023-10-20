";" @punctuation
":" @punctuation
"," @punctuation
"[" @punctuation.bracket
"]" @punctuation.bracket
"{" @punctuation.bracket
"}" @punctuation.bracket
"(" @punctuation.bracket
")" @punctuation.bracket
"=" @operator

(package_statement
  "main" @keyword
  "package" @keyword
)

(import_statement
  "import" @keyword
)

(package_identifier) @string

(builtin_field_type) @type.builtin
(user_field_type) @type
(number) @number

(enum_statement name: (declaration_identifier) @type)
(component_statement name: (declaration_identifier) @type)
(transient_statement name: (declaration_identifier) @type)
(system_statement name: (declaration_identifier) @type)
(action_statement name: (declaration_identifier) @type)
(system_capability_statement component_lookup: (declaration_lookup) @type)
(with_statement
  "with" @function
  field_name: (declaration_identifier) @property
)

(enum_value_statement name: (declaration_identifier) @property)
(field_statement field_name: (declaration_identifier) @property)

(system_capability) @function

(notify_option) @function

(notify_statement
  "notify" @keyword
  (declaration_identifier) @type
)

(boolean) @constant
(integer) @constant

(parameter_name) @variable.parameter

; "with" @function
"enum" @keyword
"component" @keyword
"transient" @keyword
"action" @keyword
"system" @keyword


