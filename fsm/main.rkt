#lang typed/racket

;; Run a Simulation of Interacting Automata
(random-seed 7480)

;; =============================================================================
(require "automata-adapted.rkt")
(require "population.rkt")
(require "utilities.rkt")

;; effect: run timed simulation, create and display plot of average payoffs
;; effect: measure time needed for the simulation
(define (main)
   (simulation->lines
    (evolve (build-random-population 100) 1000 10 20))
   (void))

(: simulation->lines (-> [Listof Payoff] [Listof [List Integer Real]]))
;; turn average payoffs into a list of Cartesian points 
(define (simulation->lines data)
  (for/list : [Listof [List Integer Real]]
    ([d : Payoff (in-list data)][n : Integer (in-naturals)])
    (list n d)))

(: evolve (-> Population Natural Natural Natural [Listof Payoff]))
;; computes the list of average payoffs over the evolution of population p for
;; c cycles of of match-ups with r rounds per match and at birth/death rate of s
(define (evolve p c s r)
  (cond
    [(zero? c) '()]
    [else (define p2 (match-up* p r))
          ;; Note: r is typed as State even though State is not exported 
          (define pp (population-payoffs p2))
          (define p3 (death-birth p2 s))
          ;; Note: s same as r
          ({inst cons Payoff [Listof Payoff]}
           (cast (relative-average pp r) Payoff)
           ;; Note: evolve is assigned (-> ... [Listof Probability])
           ;; even though it is explicitly typed ... [Listof Payoff]
           (evolve p3 (- c 1) s r))]))

;; -----------------------------------------------------------------------------
(time (main))

