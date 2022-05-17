#|
Simple implementation of a Deterministic Finite Automaton
Identify all the token types found in the arithmetic input string
Return a list of the tokens found
Used to validate input strings
Example calls:
(arithmetic-lexer "3.1E333 + 1")
Mateo Herrera - A01751912
Gerardo Gutierrez - A01029422
|#

#lang racket

;(require racket/trace)

; Structure that describes a Deterministic Finite Automaton
(struct dfa-str (initial-state accept-states transitions))

;Function used to call the automaton with specified conditions
(define (arithmetic-lexer string)
  (automaton (dfa-str 'start '(int var par_close float exp n_sp) delta-arithmetic) string)
)

;Automaton that identifies all the token types found in the arithmetic input string
;returns a list of the tokens found
;and validates the input string
(define (automaton dfa input-string)
  (let loop
    ([state (dfa-str-initial-state dfa)]    ; Current state
     [chars (string->list input-string)]    ; List of characters
     [result null]      ; List of tokens found
     [character null])  ; List that contains character being evaluated
    (if (empty? chars)
      ; Check that the final state is in the accept states list and
      ; appends the last state and token. 
      (if (member state (dfa-str-accept-states dfa))
        (if (eq? state 'n_sp)
          (reverse result)
          (reverse (cons (list (list->string (reverse character)) state) result))
        ) 
        #f
      )
      ; Recursive loop with the new state and the rest of the list
      (let-values
        ; Get the new token found and state by applying the transition function
        ([(token state) ((dfa-str-transitions dfa) state (car chars))])
         (loop
            state
            (cdr chars)
            ; Update the list of tokens found
            (if token (cons (list (list->string (reverse character)) token) result) result)
            ; Builds character list until change of state
            (if (eq? (car chars) #\space)
              (if token null character)
              (if token (list (car chars)) (cons (car chars) character))
            )
         )
      )
    )
  )
)

(define (operator? char)
  (member char '(#\+ #\- #\* #\/ #\^ #\=)))

(define (sign? char)
  (member char '(#\+ #\-)))

(define (e? char)
  (member char '(#\E #\e)))

; Delta function of the automaton, basically a big conditional list.
(define (delta-arithmetic state character)
  ;Transition to identify basic arithmetic operations
  (case state
    ['start (cond
        [(char-numeric? character) (values #f 'int)]
        [(sign? character) (values #f 'n_sign)]
        [(or (char-alphabetic? character) (eq? character #\_)) (values #f 'var)]
        [(eq? character #\space) (values #f 'o_sp)]
        [[eq? character #\( ] (values #f 'par_open)]
        [else (values #f 'fail)])]
    ['n_sign (cond
        [(char-numeric? character) (values #f 'int)]
        [else (values #f 'fail)])]
    ['int (cond
        [(char-numeric? character) (values #f 'int)]
        [(operator? character) (values 'int 'op)]
        [(eq? character #\space) (values 'int 'n_sp)]
        [[eq? character #\)] (values 'int 'par_close)]
        [(e? character) (values #f 'e)]
        [(eq? character #\.) (values #f 'float)]
        [else (values #f 'fail)])]
    ['var (cond
        [(or (char-alphabetic? character) (eq? character #\_)) (values #f 'var)]
        [(char-numeric? character) (values #f 'var)]
        [(operator? character) (values 'var 'op)]
        [(eq? character #\space) (values 'var 'n_sp)]
        [[eq? character #\)] (values 'var 'par_close)]
        [else (values #f 'fail)])]
    ['op (cond
        [(char-numeric? character) (values 'op 'int)]
        [(sign? character) (values 'op 'n_sign)]
        [(or (char-alphabetic? character) (eq? character #\_)) (values 'op 'var)]
        [(eq? character #\space) (values 'op 'o_sp)]
        [[eq? character #\( ] (values 'op 'par_open)]
        [else (values #f 'fail)])]
    ['o_sp (cond
        [(or (char-alphabetic? character) (eq? character #\_)) (values #f 'var)]
        [(char-numeric? character) (values #f 'int)]
        [(sign? character) (values #f 'n_sign)]
        [(eq? character #\space) (values #f 'o_sp)]
        [[eq? character #\( ] (values #f 'par_open)]
        [else (values #f 'fail)])]
    ['par_open (cond
        [(or (char-alphabetic? character) (eq? character #\_)) (values 'par_open 'var)]
        [(char-numeric? character) (values 'par_open 'int)]
        [(sign? character) (values 'par_open 'n_sign)]
        [(eq? character #\space) (values 'par_open 'o_sp)]
        [[eq? character #\( ] (values 'par_open 'par_open)]
        [else (values #f 'fail)])]
    ['par_close (cond
        [(eq? character #\space) (values 'par_close 'n_sp)]
        [(operator? character) (values 'par_close 'op)]
        [[eq? character #\)] (values 'par_close 'par_close)]
        [else (values #f 'fail)])]
    ['n_sp (cond
        [(eq? character #\space) (values #f 'n_sp)]
        [(operator? character) (values #f 'op)]
        [[eq? character #\)] (values #f 'par_close)]
        [else (values #f 'fail)])]
    ['e (cond
        [(char-numeric? character) (values #f 'exp)]
        [(sign? character) (values #f 'e_sign)]
        [else (values #f 'fail)])]
    ['e_sign (cond
        [(char-numeric? character) (values #f 'exp)]
        [else (values #f 'fail)])]
    ['float (cond
        [(char-numeric? character) (values #f 'float)]
        [(operator? character) (values 'float 'op)]
        [[eq? character #\)] (values 'float 'par_close)]
        [(e? character) (values #f 'e)]
        [(eq? character #\space) (values 'float 'n_sp)]
        [else (values #f 'fail)])]
    ['exp (cond
        [(char-numeric? character) (values #f 'exp)]
        [(operator? character) (values 'exp 'op)]
        [[eq? character #\)] (values 'exp 'par_close)]
        [(eq? character #\space) (values 'exp 'n_sp)]
        [else (values #f 'fail)])]    
    ['fail (values #f 'fail)]))

(provide arithmetic-lexer)