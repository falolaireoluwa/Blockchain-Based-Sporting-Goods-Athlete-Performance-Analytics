;; Equipment Verification Contract
;; Validates sporting goods manufacturers and their equipment

(define-data-var admin principal tx-sender)

;; Map of verified manufacturers
(define-map verified-manufacturers principal bool)

;; Map of verified equipment
(define-map verified-equipment
  { manufacturer: principal, equipment-id: (string-utf8 36) }
  {
    name: (string-utf8 64),
    category: (string-utf8 32),
    verified: bool,
    verification-date: uint
  }
)

;; Public function to register a manufacturer
(define-public (register-manufacturer (manufacturer principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok (map-set verified-manufacturers manufacturer true))
  )
)

;; Public function to verify equipment
(define-public (verify-equipment
    (manufacturer principal)
    (equipment-id (string-utf8 36))
    (name (string-utf8 64))
    (category (string-utf8 32)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (asserts! (default-to false (map-get? verified-manufacturers manufacturer)) (err u101))
    (ok (map-set verified-equipment
      { manufacturer: manufacturer, equipment-id: equipment-id }
      {
        name: name,
        category: category,
        verified: true,
        verification-date: block-height
      }
    ))
  )
)

;; Read-only function to check if equipment is verified
(define-read-only (is-equipment-verified (manufacturer principal) (equipment-id (string-utf8 36)))
  (default-to
    false
    (get verified (map-get? verified-equipment { manufacturer: manufacturer, equipment-id: equipment-id }))
  )
)

;; Read-only function to get equipment details
(define-read-only (get-equipment-details (manufacturer principal) (equipment-id (string-utf8 36)))
  (map-get? verified-equipment { manufacturer: manufacturer, equipment-id: equipment-id })
)
