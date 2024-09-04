"-" @operator
"+" @operator
"!" @operator
"++" @operator
"--" @operator
"*" @operator
"&" @operator
"&&" @operator
"~" @operator
"$" @operator
"..." @operator
"*" @operator
"/" @operator
"%" @operator
"+" @operator
"-" @operator
"<<" @operator
">>" @operator
"<=>" @operator
"<" @operator
">" @operator
"<=" @operator
">=" @operator
"==" @operator
"!=" @operator
"&" @operator
"^" @operator
"|" @operator
"&&" @operator
"||" @operator

"..<" @operator
"..=" @operator

; assignment operator @operator
"=" @operator
"*=" @operator
"/=" @operator
"%=" @operator
"+=" @operator
"-=" @operator
">>=" @operator
"<<=" @operator
"&=" @operator
"^=" @operator
"|=" @operator


"::" @operator


"." @punctuation.delimiter
";" @punctuation.delimiter
":" @punctuation.delimiter


"is" @keyword
"as" @keyword

"@" @keyword

"virtual" @keyword
"override" @keyword
"final" @keyword
"implicit" @keyword

"->" @function

"template <" @punctuation.bracket
"> template" @punctuation.bracket
"(" @punctuation.bracket
")" @punctuation.bracket
"[" @punctuation.bracket
"]" @punctuation.bracket
"{" @punctuation.bracket
"}" @punctuation.bracket

(cpp2_primitive_type) @type

(cpp2_number_literal) @number

(macro_comment) @property

(cpp2_block_declaration
    name: (cpp2_non_template_identifier) @emphasis.strong )

(cpp2_expression_declaration
    name: (cpp2_non_template_identifier) @emphasis.strong )

(cpp2_no_definition_declaration
    name: (cpp2_non_template_identifier)  @emphasis.strong)

(cpp2_function_declaration_argument
  (cpp2_any_identifier
    last: (cpp2_no_namespace_identifier
        (cpp2_non_template_identifier) @emphasis)))

(cpp2_function_declaration_argument
    (cpp2_expression_declaration
        name: (cpp2_non_template_identifier) @emphasis))

(cpp2_function_declaration_argument
    (cpp2_block_declaration
        name: (cpp2_non_template_identifier) @emphasis))

(cpp2_function_declaration_argument
    (cpp2_no_definition_declaration
        name: (cpp2_non_template_identifier) @emphasis))

(cpp2_no_definition_declaration
    type: (cpp2_expression
        (cpp2_any_identifier
            last: (cpp2_no_namespace_identifier
                (cpp2_template_identifier
                    (cpp2_non_template_identifier) @type)))))

(cpp2_no_definition_declaration
    type: (cpp2_expression
        (cpp2_any_identifier
            last: (cpp2_no_namespace_identifier) @type)))

(cpp2_left_side_of_definition
    type: (cpp2_expression
        (cpp2_any_identifier
            last: (cpp2_no_namespace_identifier
                (cpp2_template_identifier
                    (cpp2_non_template_identifier) @type)))))

(cpp2_left_side_of_definition
    type: (cpp2_expression
        (cpp2_any_identifier
            last: (cpp2_no_namespace_identifier
                (cpp2_non_template_identifier) @type))))

(cpp2_function_type
    return: (cpp2_expression
        (cpp2_any_identifier
            last: (cpp2_no_namespace_identifier
                (cpp2_template_identifier
                    (cpp2_non_template_identifier) @type)))))

(cpp2_next) @keyword

(cpp2_type_type) @keyword

(cpp2_passing_style) @keyword

(cpp2_throws) @keyword

(cpp2_inspect) @keyword

(string_literal) @string
(cpp2_raw_string_literal) @string

(comment) @comment

(cpp2_function_call
    function: (cpp2_expression
        (cpp2_any_identifier
            last: (cpp2_no_namespace_identifier
                (cpp2_non_template_identifier) @function))))

(cpp2_function_call
    function: (cpp2_expression
        (cpp2_any_identifier
            last: (cpp2_no_namespace_identifier
                (cpp2_template_identifier
                    (cpp2_non_template_identifier) @function)))))

(cpp2_dot_access
    field: (cpp2_any_identifier
        last: (cpp2_no_namespace_identifier) @property))

(cpp2_command_statement "return" @keyword)
(cpp2_if_else_statement "if" @keyword)

(cpp2_block_declaration
    name: (cpp2_non_template_identifier
        (cpp2_ordinary_identifier
            (identifier) @function)))

(cpp2_function_declaration_argument
	(cpp2_no_definition_declaration
		(cpp2_non_template_identifier
			(cpp2_ordinary_identifier
				(identifier) @variable.parameter))))

  (cpp2_function_declaration_argument
	(cpp2_any_identifier
	  last: (cpp2_no_namespace_identifier
		(cpp2_non_template_identifier
		  (cpp2_ordinary_identifier
			(identifier) @variable.parameter)))))

(cpp2_operator_keyword) @function

(cpp2_no_definition_declaration "private" @keyword)
(cpp2_no_definition_declaration "public" @keyword)
(cpp2_no_definition_declaration "protected" @keyword)

(cpp2_block_declaration "private" @keyword)
(cpp2_block_declaration "public" @keyword)
(cpp2_block_declaration "protected" @keyword)

(cpp2_statement
  (cpp2_expression_declaration
	name: (cpp2_non_template_identifier
	  (cpp2_ordinary_identifier
		(identifier) @variable))))

(cpp2_expression_declaration
    name: (cpp2_non_template_identifier
      (cpp2_ordinary_identifier
        (identifier) @namespace))
    (cpp2_expression_definition
      (cpp2_left_side_of_definition
        type: (cpp2_namespace_type) @keyword)
      (cpp2_expression
        (cpp2_any_identifier
          namespaces: (cpp2_no_namespace_identifier
            (cpp2_non_template_identifier
              (cpp2_ordinary_identifier
                (identifier))))
          last: (cpp2_no_namespace_identifier
            (cpp2_non_template_identifier
              (cpp2_ordinary_identifier
                (identifier))))))))

  (cpp2_expression_declaration
    name: (cpp2_non_template_identifier
      (cpp2_ordinary_identifier
        (identifier) @function))
    (cpp2_expression_definition
      (cpp2_left_side_of_definition
        type: (cpp2_function_type_without_return_type))))

(cpp2_while_statement "while" @keyword)
(cpp2_for_statement_left_side "for" @keyword)
(cpp2_for_statement_left_side "do" @keyword)

(cpp2_left_side_of_definition
metafunctions: (cpp2_metafunction_arguments
  (cpp2_any_identifier
	last: (cpp2_no_namespace_identifier
	  (cpp2_non_template_identifier
		(cpp2_ordinary_identifier
		  (identifier)))))) @function.macro
type: (cpp2_type_type))
