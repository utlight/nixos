;;extends

(
  [
    (string_literal
      (string_literal_content) @injection.content)
    (raw_string_literal
      (raw_string_content) @injection.content)
  ]
  (#lua-match? @injection.content "^%s*SELECT")
  (#set! injection.language "sql")
)
(
  [
    (string_literal
      (string_literal_content) @injection.content)
    (raw_string_literal
      (raw_string_content) @injection.content)
  ]
  (#lua-match? @injection.content "^%s*UPDATE")
  (#set! injection.language "sql")
)
(
  [
    (string_literal
      (string_literal_content) @injection.content)
    (raw_string_literal
      (raw_string_content) @injection.content)
  ]
  (#lua-match? @injection.content "^%s*INSERT")
  (#set! injection.language "sql")
)
(
  [
    (string_literal
      (string_literal_content) @injection.content)
    (raw_string_literal
      (raw_string_content) @injection.content)
  ]
  (#lua-match? @injection.content "^%s*DELETE")
  (#set! injection.language "sql")
)
(
  [
    (string_literal
      (string_literal_content) @injection.content)
    (raw_string_literal
      (raw_string_content) @injection.content)
  ]
  (#lua-match? @injection.content "^%s*DECLARE")
  (#set! injection.language "sql")
)
(
  [
    (string_literal
      (string_literal_content) @injection.content)
    (raw_string_literal
      (raw_string_content) @injection.content)
  ]
  (#lua-match? @injection.content "^%s*WITH")
  (#set! injection.language "sql")
)
(
  [
    (string_literal
      (string_literal_content) @injection.content)
    (raw_string_literal
      (raw_string_content) @injection.content)
  ]
  (#lua-match? @injection.content "^%s*ALTER")
  (#set! injection.language "sql")
)
