;; Performance Data Contract
;; Collects and stores athlete performance data

(define-data-var admin principal tx-sender)

;; Map of registered athletes
(define-map athletes principal
  {
    name: (string-utf8 64),
    sport: (string-utf8 32),
    registered: bool
  }
)

;; Map of performance data entries
(define-map performance-data
  {
    athlete: principal,
    session-id: (string-utf8 36)
  }
  {
    timestamp: uint,
    equipment-manufacturer: principal,
    equipment-id: (string-utf8 36),
    metrics: (list 10 {
      name: (string-utf8 32),
      value: int,
      unit: (string-utf8 8)
    })
  }
)

;; Public function to register an athlete
(define-public (register-athlete (name (string-utf8 64)) (sport (string-utf8 32)))
  (ok (map-set athletes tx-sender
    {
      name: name,
      sport: sport,
      registered: true
    }
  ))
)

;; Public function to record performance data
(define-public (record-performance
    (session-id (string-utf8 36))
    (equipment-manufacturer principal)
    (equipment-id (string-utf8 36))
    (metrics (list 10 {
      name: (string-utf8 32),
      value: int,
      unit: (string-utf8 8)
    })))
  (begin
    (asserts! (default-to false (get registered (map-get? athletes tx-sender))) (err u200))
    (ok (map-set performance-data
      { athlete: tx-sender, session-id: session-id }
      {
        timestamp: block-height,
        equipment-manufacturer: equipment-manufacturer,
        equipment-id: equipment-id,
        metrics: metrics
      }
    ))
  )
)

;; Read-only function to get athlete details
(define-read-only (get-athlete-details (athlete principal))
  (map-get? athletes athlete)
)

;; Read-only function to get performance data
(define-read-only (get-performance-data (athlete principal) (session-id (string-utf8 36)))
  (map-get? performance-data { athlete: athlete, session-id: session-id })
)
