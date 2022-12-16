";" @punctuation
"[" @punctuation.bracket
"]" @punctuation.bracket
"{" @punctuation.bracket
"}" @punctuation.bracket
"=" @operator

(package_identifier) @module

(builtin_field_type) @type.builtin
(user_field_type) @type
(number) @number

(enum_statement name: (declaration_identifier) @type)
(component_statement name: (declaration_identifier) @type)
(transient_statement name: (declaration_identifier) @type)
(system_statement name: (declaration_identifier) @type)
(action_statement name: (declaration_identifier) @type)
(system_capability_statement component_name: (declaration_identifier) @type)
(with_statement field_name: (declaration_identifier) @property)

(enum_value_statement name: (declaration_identifier) @property)
(field_statement field_name: (declaration_identifier) @property)

(system_capability) @function

"with" @function
"package" @keyword
"import" @keyword
"enum" @keyword
"component" @keyword
"transient" @keyword
"action" @keyword
"system" @keyword


