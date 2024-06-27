(declaration
  ((identifier) @function)
  (function_type))

(declaration
  ((identifier) @variable)
  ((type_id) @type))

(parameter
  ((identifier) @variable.parameter)
  (type_id
    ((identifier) @type)))

(declaration
  ((identifier) @type.definition)
  (alias))

((binary_operator) @operator)

((access_specifier) @keyword)
((parameter_this) @keyword)
((direction) @keyword)

(string_literal) @string
(raw_string_literal) @string

(string_substitution
  "(" @punctuation.special
  ")$" @punctuation.special) @embedded

