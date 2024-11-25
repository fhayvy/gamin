;; Gamin Gaming Platform Smart Contract
;; Handles in-game asset ownership and trading functionality

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-not-authorized (err u102))
(define-constant err-invalid-input (err u103))
(define-constant err-invalid-price (err u104))
(define-constant max-level u100)
(define-constant max-experience u10000)
(define-constant max-metadata-length u256)

;; Data Variables
(define-map assets 
    { asset-id: uint }
    { owner: principal, metadata-uri: (string-utf8 256), transferable: bool })

(define-map asset-prices
    { asset-id: uint }
    { price: uint })

(define-map player-stats
    { player: principal }
    { experience: uint, level: uint })

;; Asset Counter
(define-data-var asset-counter uint u0)

;; Helper Functions

;; Validate asset exists and return asset data
(define-private (get-asset-checked (asset-id uint))
    (let ((asset (map-get? assets { asset-id: asset-id })))
        (asserts! (and 
                (is-some asset)
                (<= asset-id (var-get asset-counter)))
            err-not-found)
        (ok (unwrap-panic asset))))

;; Validate metadata URI length
(define-private (validate-metadata-uri (uri (string-utf8 256)))
    (let ((uri-length (len uri)))
        (and 
            (> uri-length u0)
            (<= uri-length max-metadata-length))))

;; Public Functions

;; Mint new gaming asset
(define-public (mint-asset (metadata-uri (string-utf8 256)) (transferable bool))
    (let
        ((asset-id (+ (var-get asset-counter) u1)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (validate-metadata-uri metadata-uri) err-invalid-input)
        (map-set assets
            { asset-id: asset-id }
            { owner: tx-sender,
              metadata-uri: metadata-uri,
              transferable: transferable })
        (var-set asset-counter asset-id)
        (ok asset-id)))

;; Transfer asset ownership
(define-public (transfer-asset (asset-id uint) (recipient principal))
    (begin
        (asserts! (<= asset-id (var-get asset-counter)) err-invalid-input)
        (let ((asset (try! (get-asset-checked asset-id))))
            (asserts! (and
                    (is-eq (get owner asset) tx-sender)
                    (get transferable asset)
                    (not (is-eq recipient tx-sender)))  ;; Prevent self-transfers
                err-not-authorized)
            (map-set assets
                { asset-id: asset-id }
                { owner: recipient,
                  metadata-uri: (get metadata-uri asset),
                  transferable: (get transferable asset) })
            (ok true))))

;; List asset for sale
(define-public (list-asset (asset-id uint) (price uint))
    (begin
        (asserts! (<= asset-id (var-get asset-counter)) err-invalid-input)
        (let ((asset (try! (get-asset-checked asset-id))))
            (asserts! (and 
                    (is-eq (get owner asset) tx-sender)
                    (> price u0))  ;; Ensure positive price
                err-invalid-price)
            (map-set asset-prices
                { asset-id: asset-id }
                { price: price })
            (ok true))))

;; Purchase listed asset
(define-public (purchase-asset (asset-id uint))
    (begin
        (asserts! (<= asset-id (var-get asset-counter)) err-invalid-input)
        (let
            ((asset (try! (get-asset-checked asset-id)))
             (price-data (unwrap! (map-get? asset-prices { asset-id: asset-id }) err-not-found)))
            (asserts! (and
                    (not (is-eq (get owner asset) tx-sender))
                    (get transferable asset))
                err-not-authorized)
            (try! (stx-transfer? (get price price-data) tx-sender (get owner asset)))
            (map-set assets
                { asset-id: asset-id }
                { owner: tx-sender,
                  metadata-uri: (get metadata-uri asset),
                  transferable: (get transferable asset) })
            (map-delete asset-prices { asset-id: asset-id })
            (ok true))))

;; Update player stats with validation
(define-public (update-player-stats (experience uint) (level uint))
    (begin
        (asserts! (<= experience max-experience) err-invalid-input)
        (asserts! (<= level max-level) err-invalid-input)
        (map-set player-stats
            { player: tx-sender }
            { experience: experience, level: level })
        (ok true)))

;; Read-only Functions

;; Get asset details
(define-read-only (get-asset-details (asset-id uint))
    (if (<= asset-id (var-get asset-counter))
        (map-get? assets { asset-id: asset-id })
        none))

;; Get asset price
(define-read-only (get-asset-price (asset-id uint))
    (if (<= asset-id (var-get asset-counter))
        (map-get? asset-prices { asset-id: asset-id })
        none))

;; Get player stats
(define-read-only (get-player-stats (player principal))
    (map-get? player-stats { player: player }))

;; Get total assets minted
(define-read-only (get-total-assets)
    (var-get asset-counter))