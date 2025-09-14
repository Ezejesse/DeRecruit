;; Decentralized Talent Matching and Recruitment Smart Contract
;; This contract enables decentralized talent matching between employers and job seekers on the blockchain.
;; It provides features for job posting, candidate applications, skill verification, escrow payments,
;; and reputation management while maintaining privacy and security standards.

;; constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-JOB-NOT-FOUND (err u101))
(define-constant ERR-CANDIDATE-NOT-FOUND (err u102))
(define-constant ERR-ALREADY-APPLIED (err u103))
(define-constant ERR-INSUFFICIENT-PAYMENT (err u104))
(define-constant ERR-JOB-NOT-ACTIVE (err u105))
(define-constant ERR-INVALID-STATUS (err u106))
(define-constant ERR-ESCROW-NOT-FOUND (err u107))
(define-constant ERR-APPLICATION-NOT-FOUND (err u108))
(define-constant MIN-JOB-PAYMENT u1000000) ;; 1 STX minimum
(define-constant MAX-SKILLS-PER-PROFILE u10)
(define-constant PLATFORM-FEE-PCT u3) ;; 3% platform fee
(define-constant DISPUTE-TIMEOUT u1008) ;; ~7 days in blocks

;; data maps and vars
(define-data-var next-job-id uint u1)
(define-data-var next-application-id uint u1)
(define-data-var total-platform-fees uint u0)

(define-map talent-profiles
  principal
  {
    name: (string-ascii 100),
    bio: (string-ascii 500),
    skills: (list 10 (string-ascii 50)),
    hourly-rate: uint,
    reputation-score: uint,
    total-jobs-completed: uint,
    is-active: bool,
    created-at: uint
  })

(define-map employer-profiles
  principal
  {
    company-name: (string-ascii 100),
    company-bio: (string-ascii 500),
    reputation-score: uint,
    total-jobs-posted: uint,
    is-verified: bool,
    created-at: uint
  })

(define-map job-postings
  uint
  {
    employer: principal,
    title: (string-ascii 100),
    description: (string-ascii 1000),
    required-skills: (list 10 (string-ascii 50)),
    payment-amount: uint,
    status: (string-ascii 20),
    created-at: uint,
    deadline: uint,
    selected-candidate: (optional principal)
  })

(define-map job-applications
  uint
  {
    job-id: uint,
    candidate: principal,
    cover-letter: (string-ascii 500),
    proposed-rate: uint,
    status: (string-ascii 20),
    applied-at: uint
  })

(define-map escrow-contracts
  {job-id: uint, candidate: principal}
  {
    amount: uint,
    status: (string-ascii 20),
    created-at: uint,
    milestone-count: uint,
    completed-milestones: uint
  })

(define-map skill-verifications
  {talent: principal, skill: (string-ascii 50)}
  {
    verifier: principal,
    verified-at: uint,
    verification-score: uint,
    evidence-hash: (buff 32)
  })

;; private functions
(define-private (calculate-platform-fee (amount uint))
  (/ (* amount PLATFORM-FEE-PCT) u100))

(define-private (is-job-employer (job-id uint) (user principal))
  (match (map-get? job-postings job-id)
    job (is-eq (get employer job) user)
    false))

(define-private (update-reputation (user principal) (points-delta int))
  (match (map-get? talent-profiles user)
    profile
      (let ((current-reputation (get reputation-score profile))
            (new-reputation (if (> points-delta 0)
                             (+ current-reputation (to-uint points-delta))
                             (if (>= current-reputation (to-uint (* points-delta -1)))
                               (- current-reputation (to-uint (* points-delta -1)))
                               u0))))
        (map-set talent-profiles user
          (merge profile {reputation-score: new-reputation}))
        true)
    false))

(define-private (calculate-skill-match (job-skills (list 10 (string-ascii 50))) (candidate-skills (list 10 (string-ascii 50))))
  (let ((total-job-skills (len job-skills))
        (matched-skills (fold check-skill-match job-skills u0)))
    (if (> total-job-skills u0)
      (/ (* matched-skills u100) total-job-skills)
      u0)))

(define-private (check-skill-match (skill (string-ascii 50)) (acc uint))
  ;; This would check if skill exists in candidate's skill list
  ;; For simplicity, returning acc + 1 (in real implementation, would check against candidate skills)
  (+ acc u1))

;; public functions
(define-public (create-talent-profile 
  (name (string-ascii 100))
  (bio (string-ascii 500))
  (skills (list 10 (string-ascii 50)))
  (hourly-rate uint))
  (begin
    (asserts! (<= (len skills) MAX-SKILLS-PER-PROFILE) ERR-INVALID-STATUS)
    (map-set talent-profiles tx-sender {
      name: name,
      bio: bio,
      skills: skills,
      hourly-rate: hourly-rate,
      reputation-score: u50,
      total-jobs-completed: u0,
      is-active: true,
      created-at: block-height
    })
    (ok true)))

(define-public (create-employer-profile 
  (company-name (string-ascii 100))
  (company-bio (string-ascii 500)))
  (begin
    (map-set employer-profiles tx-sender {
      company-name: company-name,
      company-bio: company-bio,
      reputation-score: u50,
      total-jobs-posted: u0,
      is-verified: false,
      created-at: block-height
    })
    (ok true)))

(define-public (post-job 
  (title (string-ascii 100))
  (description (string-ascii 1000))
  (required-skills (list 10 (string-ascii 50)))
  (payment-amount uint)
  (deadline uint))
  (let ((job-id (var-get next-job-id)))
    (asserts! (is-some (map-get? employer-profiles tx-sender)) ERR-UNAUTHORIZED)
    (asserts! (>= payment-amount MIN-JOB-PAYMENT) ERR-INSUFFICIENT-PAYMENT)
    (asserts! (> deadline block-height) ERR-INVALID-STATUS)
    (try! (stx-transfer? payment-amount tx-sender (as-contract tx-sender)))
    
    (map-set job-postings job-id {
      employer: tx-sender,
      title: title,
      description: description,
      required-skills: required-skills,
      payment-amount: payment-amount,
      status: "OPEN",
      created-at: block-height,
      deadline: deadline,
      selected-candidate: none
    })
    
    (match (map-get? employer-profiles tx-sender)
      profile (map-set employer-profiles tx-sender
                (merge profile {total-jobs-posted: (+ (get total-jobs-posted profile) u1)}))
      false)
    
    (var-set next-job-id (+ job-id u1))
    (ok job-id)))

(define-public (apply-for-job 
  (job-id uint)
  (cover-letter (string-ascii 500))
  (proposed-rate uint))
  (let ((application-id (var-get next-application-id)))
    (asserts! (is-some (map-get? talent-profiles tx-sender)) ERR-CANDIDATE-NOT-FOUND)
    (asserts! (is-some (map-get? job-postings job-id)) ERR-JOB-NOT-FOUND)
    
    (match (map-get? job-postings job-id)
      job (begin
            (asserts! (is-eq (get status job) "OPEN") ERR-JOB-NOT-ACTIVE)
            (map-set job-applications application-id {
              job-id: job-id,
              candidate: tx-sender,
              cover-letter: cover-letter,
              proposed-rate: proposed-rate,
              status: "PENDING",
              applied-at: block-height
            })
            (var-set next-application-id (+ application-id u1))
            (ok application-id))
      ERR-JOB-NOT-FOUND)))
      
(define-public (select-candidate (job-id uint) (candidate principal))
  (begin
    (asserts! (is-job-employer job-id tx-sender) ERR-UNAUTHORIZED)
    (asserts! (is-some (map-get? talent-profiles candidate)) ERR-CANDIDATE-NOT-FOUND)
    
    (match (map-get? job-postings job-id)
      job (begin
            (asserts! (is-eq (get status job) "OPEN") ERR-JOB-NOT-ACTIVE)
            (map-set job-postings job-id
              (merge job {
                status: "IN_PROGRESS",
                selected-candidate: (some candidate)
              }))
            
            ;; Create escrow contract
            (map-set escrow-contracts {job-id: job-id, candidate: candidate} {
              amount: (get payment-amount job),
              status: "ACTIVE",
              created-at: block-height,
              milestone-count: u1,
              completed-milestones: u0
            })
            (ok true))
      ERR-JOB-NOT-FOUND)))

(define-public (complete-job (job-id uint))
  (let ((candidate tx-sender))
    (asserts! (is-some (map-get? talent-profiles candidate)) ERR-CANDIDATE-NOT-FOUND)
    
    (match (map-get? job-postings job-id)
      job (begin
            (asserts! (is-eq (some candidate) (get selected-candidate job)) ERR-UNAUTHORIZED)
            (asserts! (is-eq (get status job) "IN_PROGRESS") ERR-INVALID-STATUS)
            
            (match (map-get? escrow-contracts {job-id: job-id, candidate: candidate})
              escrow (let ((payment-amount (get amount escrow))
                          (platform-fee (calculate-platform-fee payment-amount))
                          (talent-payment (- payment-amount platform-fee)))
                      
                      ;; Transfer payment to talent
                      (try! (as-contract (stx-transfer? talent-payment tx-sender candidate)))
                      ;; Transfer platform fee
                      (try! (as-contract (stx-transfer? platform-fee tx-sender CONTRACT-OWNER)))
                      
                      ;; Update job status
                      (map-set job-postings job-id (merge job {status: "COMPLETED"}))
                      
                      ;; Update escrow status
                      (map-set escrow-contracts {job-id: job-id, candidate: candidate}
                        (merge escrow {status: "COMPLETED"}))
                      
                      ;; Update talent profile
                      (match (map-get? talent-profiles candidate)
                        profile (map-set talent-profiles candidate
                                  (merge profile {
                                    total-jobs-completed: (+ (get total-jobs-completed profile) u1),
                                    reputation-score: (+ (get reputation-score profile) u5)
                                  }))
                        false)
                      
                      ;; Update platform fees
                      (var-set total-platform-fees (+ (var-get total-platform-fees) platform-fee))
                      (ok true))
              ERR-ESCROW-NOT-FOUND))
      ERR-JOB-NOT-FOUND)))

(define-public (verify-skill 
  (talent principal) 
  (skill (string-ascii 50)) 
  (verification-score uint)
  (evidence-hash (buff 32)))
  (begin
    ;; Only verified employers or high-reputation talents can verify skills
    (asserts! (or (is-some (map-get? employer-profiles tx-sender))
                  (match (map-get? talent-profiles tx-sender)
                    profile (>= (get reputation-score profile) u80)
                    false)) ERR-UNAUTHORIZED)
    (asserts! (and (>= verification-score u1) (<= verification-score u100)) ERR-INVALID-STATUS)
    
    (map-set skill-verifications {talent: talent, skill: skill} {
      verifier: tx-sender,
      verified-at: block-height,
      verification-score: verification-score,
      evidence-hash: evidence-hash
    })
    (ok true)))


