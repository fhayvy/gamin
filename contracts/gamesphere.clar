;; Gamin Gaming Platform Smart Contract
;; Handles in-game asset ownership and trading functionality

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-not-authorized (err u102))

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

;; Public Functions

;; Mint new gaming asset
(define-public (mint-asset (metadata-uri (string-utf8 256)) (transferable bool))
    (let
        ((asset-id (+ (var-get asset-counter) u1)))
        (if (is-eq tx-sender contract-owner)
            (begin
                (map-set assets
                    { asset-id: asset-id }
                    { owner: tx-sender,
                      metadata-uri: metadata-uri,
                      transferable: transferable })
                (var-set asset-counter asset-id)
                (ok asset-id))
            err-owner-only)))

;; Transfer asset ownership
(define-public (transfer-asset (asset-id uint) (recipient principal))
    (let ((asset (unwrap! (map-get? assets { asset-id: asset-id }) err-not-found)))
        (if (and
                (is-eq (get owner asset) tx-sender)
                (get transferable asset))
            (begin
                (map-set assets
                    { asset-id: asset-id }
                    { owner: recipient,
                      metadata-uri: (get metadata-uri asset),
                      transferable: (get transferable asset) })
                (ok true))
            err-not-authorized)))

;; List asset for sale
(define-public (list-asset (asset-id uint) (price uint))
    (let ((asset (unwrap! (map-get? assets { asset-id: asset-id }) err-not-found)))
        (if (is-eq (get owner asset) tx-sender)
            (begin
                (map-set asset-prices
                    { asset-id: asset-id }
                    { price: price })
                (ok true))
            err-not-authorized)))

;; Purchase listed asset
(define-public (purchase-asset (asset-id uint))
    (let
        ((asset (unwrap! (map-get? assets { asset-id: asset-id }) err-not-found))
         (price-data (unwrap! (map-get? asset-prices { asset-id: asset-id }) err-not-found)))
        (if (and
                (not (is-eq (get owner asset) tx-sender))
                (get transferable asset))
            (begin
                (try! (stx-transfer? (get price price-data) tx-sender (get owner asset)))
                (map-set assets
                    { asset-id: asset-id }
                    { owner: tx-sender,
                      metadata-uri: (get metadata-uri asset),
                      transferable: (get transferable asset) })
                (map-delete asset-prices { asset-id: asset-id })
                (ok true))
            err-not-authorized)))

;; Update player stats
(define-public (update-player-stats (experience uint) (level uint))
    (begin
        (map-set player-stats
            { player: tx-sender }
            { experience: experience, level: level })
        (ok true)))

;; Read-only Functions

;; Get asset details
(define-read-only (get-asset-details (asset-id uint))
    (map-get? assets { asset-id: asset-id }))

;; Get asset price
(define-read-only (get-asset-price (asset-id uint))
    (map-get? asset-prices { asset-id: asset-id }))

;; Get player stats
(define-read-only (get-player-stats (player principal))
    (map-get? player-stats { player: player }))

;; Get total assets minted
(define-read-only (get-total-assets)
    (var-get asset-counter))