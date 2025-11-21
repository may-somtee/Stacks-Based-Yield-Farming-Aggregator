
;; title: Stacks-Based-Yield-Farming-Aggregator
;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u1000))
(define-constant ERR_INVALID_POOL (err u1001))
(define-constant ERR_INVALID_PROTOCOL (err u1002))
(define-constant ERR_INVALID_AMOUNT (err u1003))
(define-constant ERR_INSUFFICIENT_BALANCE (err u1004))
(define-constant ERR_STRATEGY_NOT_FOUND (err u1005))
(define-constant ERR_PROTOCOL_PAUSED (err u1006))
(define-constant ERR_SLIPPAGE_EXCEEDED (err u1007))
(define-constant ERR_INVALID_TOKEN (err u1008))
(define-constant ERR_CALCULATION_ERROR (err u1009))
(define-constant ERR_DEPOSIT_FAILED (err u1010))
(define-constant ERR_WITHDRAW_FAILED (err u1011))
(define-constant ERR_HARVEST_FAILED (err u1012))
(define-constant ERR_INVALID_STRATEGY (err u1013))
(define-constant ERR_STRATEGY_EXECUTION_FAILED (err u1014))
(define-constant ERR_MINIMUM_DEPOSIT (err u1015))
(define-constant ERR_MAXIMUM_CAPACITY (err u1016))
(define-constant ERR_TOKEN_UNSUPPORTED (err u1017))
(define-constant ERR_REBALANCE_TOO_SOON (err u1018))


;; Protocol status
(define-data-var protocol-paused bool false)

;; Fee settings (in basis points, 1/100 of a percent)
(define-data-var performance-fee-bps uint u1000) ;; 10% performance fee
(define-data-var withdrawal-fee-bps uint u50) ;; 0.5% withdrawal fee
(define-data-var basis-points-denominator uint u10000) ;; 10000 basis points = 100%

;; Protocol fee split ratios
(define-data-var treasury-allocation uint u3000) ;; 30% to treasury
(define-data-var staking-allocation uint u5000) ;; 50% to stakers
(define-data-var insurance-allocation uint u2000) ;; 20% to insurance fund

;; Minimum deposit amounts
(define-map minimum-deposits principal uint)

;; Treasury and insurance fund addresses
(define-data-var treasury-address principal CONTRACT_OWNER)
(define-data-var insurance-fund-address principal CONTRACT_OWNER)

;; Protocol settings
(define-data-var auto-compound-interval uint u24) ;; Hours between auto-compounds
(define-data-var minimum-rebalance-interval uint u168) ;; 7 days (168 hours) between rebalances
(define-data-var maximum-slippage uint u30) ;; 0.3% maximum slippage

;; Supported protocols data
(define-map supported-protocols principal {
  name: (string-ascii 64),
  active: bool,
  tvl-cap: uint, ;; Maximum TVL allowed in this protocol
  risk-score: uint, ;; Risk score from 1-100 (1 is safest)
  audited: bool,
  last-harvest-block: uint,
  last-apr: uint, ;; Last recorded APR in basis points
  protocol-type: (string-ascii 32) ;; lending, AMM, staking, etc.
})

;; Token risk assessments
(define-map token-risk-scores principal {
  volatility-score: uint, ;; 1-100 (1 is lowest volatility)
  liquidity-score: uint, ;; 1-100 (1 is highest liquidity)
  market-cap-score: uint, ;; 1-100 (1 is highest market cap)
  composite-score: uint, ;; Weighted average of above
  risk-level: (string-ascii 16) ;; "low", "medium", "high"
})

;; Token pricing data
(define-map token-prices principal {
  price-in-ustx: uint,
  last-updated: uint,
  source: (string-ascii 32)
})

;; Farming pool data
(define-map farming-pools {protocol: principal, pool-id: uint} {
  input-token: principal, ;; Token to deposit
  reward-token: principal, ;; Token received as reward
  total-staked: uint, ;; Total tokens staked in this pool
  current-apr: uint, ;; Current APR in basis points
  max-capacity: uint, ;; Max capacity of this pool
  active: bool,
  compounded: bool, ;; Whether rewards auto-compound
  last-harvest-block: uint,
  last-rebalance-block: uint,
  historical-apr: (list 30 uint), ;; Last 30 days APR in basis points
  impermanent-loss-factor: uint, ;; IL factor if applicable (0 for single-asset)
  address: principal ;; Contract address
})

;; User positions
(define-map user-positions {user: principal, strategy-id: uint} {
  principal-amount: uint, ;; Original deposit amount
  share-amount: uint, ;; Shares in the strategy
  entry-price: uint, ;; Entry price for perf calculation
  deposit-block: uint, ;; Block when deposited
  last-harvest-block: uint, ;; Last block when user harvested
  claimed-rewards: uint, ;; Total rewards claimed
  unclaimed-rewards: uint ;; Pending rewards
})

;; User totals across all strategies
(define-map user-totals principal {
  total-value-locked: uint,
  total-earnings: uint,
  strategies-count: uint,
  compound-preference: bool ;; Whether user prefers auto-compounding
})
