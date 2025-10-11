; inherits: typescript

;; JSX Attributes/Props (e.g., prop={"something"})
(jsx_attribute
  (property_identifier) @prop.inner
  (jsx_expression "{"?(_) @prop.inner "}"?)) @prop.outer

