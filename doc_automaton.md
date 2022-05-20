# Documentation for Automaton Program
 Mateo Herrera Lavalle - A017...

 Gerardo Gutierrez Paniagua - A01029422
      
       

       
--- 
     

## User Manual 
     
To run program:

    The language that the automaton is written in is racket, therefore in order to run the program a racket terminal is needed. The instalation of Dr. Racket editor and terminal should suffice to test or use the automaton.

   
How to use the automaton:

    The first step in using the program is to call the main function with the specifications of the arithmetic expression that will define, this would take the form of:
**(automaton-2 (dfa-str 'start '**
  

    Right after, ....

  

    To end the statement, the arithmetic expression start and ends with "", for example;   
**"(34 + 9)"**

  
Exit or return:

    The end result of using the program correctly ought to be a list of lists of the tokens of the arithmetic expression identified element by element. For example:

    When running:
**((arithmetic-lexer "97 /6 = 2 + 1") '(int op int op int op int) "Multiple operators"))**

    Return: 

__A__



![](/Screenshot%202022-04-05%20104824.png)


