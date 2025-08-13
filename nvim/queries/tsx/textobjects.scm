;; JSX Attributes/Props (e.g., prop={"something"})
(jsx_attribute
  (_) @prop.inner) @prop.outer

;; Optional: Capture trailing comma for clean deletion
(jsx_self_closing_element
  attribute: (_) @prop.outer
  . ["," @prop.outer._end]?)

(jsx_opening_element
  attribute: (_) @prop.outer
  . ["," @prop.outer._end]?)

;; Object Properties (e.g., foo: "something" in { foo: "something" })
(pair
  key: (_) @property.inner
  value: (_) @property.inner) @property.outer

;; Optional: Capture trailing comma for clean deletion
(object
  (pair) @property.outer
  . ["," @property.outer._end]?)

;; Function Parameter Destructuring (e.g., {emailBodyHtml, className} in function params)
(object_pattern
  (shorthand_property_identifier_pattern) @property.inner) @property.outer

;; Optional: Capture trailing comma for destructured parameters
(object_pattern
  (shorthand_property_identifier_pattern) @property.outer
  . ["," @property.outer._end]?)

;; Import Destructuring (e.g., {initAttioNexus, foo} in import statements)
(named_imports
  (import_specifier
    name: (identifier) @property.inner) @property.outer)

;; Optional: Capture trailing comma for destructured imports
(named_imports
  (import_specifier) @property.outer
  . ["," @property.outer._end]?)

;; Array Elements
(array
  (_) @element.inner) @element.outer

;; With comma handling for clean deletion  
(array
  (_) @element.outer
  . ["," @element.outer._end]?)
