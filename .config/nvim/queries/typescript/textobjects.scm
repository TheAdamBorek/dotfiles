;; Object Properties (e.g., foo: "something" in { foo: "something" })
(pair
  key: (_) @property.inner
  value: (_) @property.inner)

;; Optional: Capture trailing comma for clean deletion
(object
  ((pair) 
  . [","]? ) @property.outer)

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
  (import_specifier) @property.inner
  . ["," @property.outer]?)

;; Array Elements
(array
  (_) @element.inner)

;; Array Elements with comma handling
(array
  (_) @element.outer
  ["," @element.outer]?)

