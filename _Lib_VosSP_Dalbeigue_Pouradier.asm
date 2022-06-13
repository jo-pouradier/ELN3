;-----------------------------------------------------------------------------
;
;  FILE NAME   :  LIB_VOSSP_SM4.ASM 
;  TARGET MCU  :  C8051F020 
;  

;-----------------------------------------------------------------------------
$include (c8051f020.inc)               ; Include register definition file. 
;-----------------------------------------------------------------------------
;******************************************************************************
;Declaration des variables et fonctions publiques
;******************************************************************************
PUBLIC   _Read_code
PUBLIC   _Read_Park_IN
PUBLIC   _Read_Park_OUT
PUBLIC   _Decod_BIN_to_BCD
PUBLIC   _Display
PUBLIC   _Test_Code
PUBLIC   _Stockage_Code

;-----------------------------------------------------------------------------
; EQUATES
;-----------------------------------------------------------------------------
GREEN_LED      	equ   	P1.6             ; Port I/O pin connected to Green LED.

;-----------------------------------------------------------------------------
; CODE SEGMENT
;-----------------------------------------------------------------------------
ProgSP_base      segment  CODE

               rseg     ProgSP_base      ; Switch to this code segment.
               using    0              ; Specify register bank for the following
                                       ; program code.
;------------------------------------------------------------------------------
;******************************************************************************                
; _Read_code
;
; Description: 
;
; Param�tres d'entr�e:  R6 (MSB)- R7 (LSB) � Adresse du p�riph�rique d�entr�e
; Valeur retourn�e: R7 : contient la valeur du code lu (sur les 6 bits de poids faible). 
; Registres modifi�s: aucun
;******************************************************************************    

_Read_code:	
			  push dpl
			  push dph
			  push Acc
			  
              mov dpl, R7
			  mov dph, R6
			  movx A, @dptr
			  rrc A
			  clr Acc.6
			  clr Acc.7
			  mov R7,A
			  
			  pop Acc
			  pop dph
			  pop dpl
			  
              RET
;******************************************************************************    			  
			  
;******************************************************************************                
; _Read_Park_IN
;
; Description: 
;
; Param�tres d'entr�e:  R6 (MSB)- R7 (LSB) � Adresse du p�riph�rique d�entr�e
; Valeur retourn�e: Bit Carry  0: pas de d�tection / 1: v�hicule d�tect� 
; Registres modifi�s: aucun
;******************************************************************************    

_Read_Park_IN:
              push dph 
			  push dpl
			  push Acc
			  
			  mov dpl, R7
			  mov dph, R6
			  movx A, @dptr
			  mov C, Acc.0
			 
			  pop Acc
			  pop dpl
			  pop dph
              RET
;******************************************************************************    						  
			  
;******************************************************************************                
; _Read_Park_OUT
;
; Description: 
;
; Param�tres d'entr�e:  R6 (MSB)- R7 (LSB) � Adresse du p�riph�rique d�entr�e
; Valeur retourn�e: Bit Carry  0: pas de d�tection / 1: v�hicule d�tect� 
; Registres modifi�s: aucun
;******************************************************************************    

_Read_Park_OUT:
              push dph 
			  push dpl
			  push Acc
			  
			  mov dpl, R7
			  mov dph, R6
			  movx A, @dptr
			  mov C, Acc.7
			 
			  pop Acc
			  pop dpl
			  pop dph
              RET
;****************************************************************************** 

;******************************************************************************                
; _Decod_BIN_to_BCD 
;
; Description: 
;
; Param�tres d'entr�e:  R6 (MSB)- R7 (LSB) � Adresse CODE de la table de conversion
;                                            "Display_7S"
; Param�tres d'entr�e:  R5  � Valeur 4 bits � convertir (4bits de poids faible)
; Valeur retourn�e: R7 - Code 7 segments (Bit 0-Segment a __ Bit6-Segment g)
; Registres modifi�s: aucun
;******************************************************************************    

_Decod_BIN_to_BCD:
			  push Acc
			  push dpl
			  push dph
				
			  mov dph,R6
			  mov dpl,R7
			  mov A, R5
			  clr Acc.7
			  clr Acc.6
			  clr Acc.5
			  clr Acc.4
			  
			  movc A, @A+DPTR
			  clr Acc.7
			  mov R7, A
			  mov A, R3
			  
			  pop dph
			  pop dpl
			  pop Acc
              RET



;****************************************************************************** 

;******************************************************************************                
; _Display  
;
; Description: 
;
; Param�tres d'entr�e:  R6 (MSB)- R7 (LSB) � Adresse du p�riph�rique de sortie
; Param�tre d�entr�e :  R5 � Code 7 segments (les 7 bits de poids faible)
; Param�tre d�entr�e :  R3 � Code LED : si 0, LED �teinte, si non nul : LED allum�e
; Valeur retourn�e: R7 : contient une recopie de la valeur envoy�e au p�riph�rique de sortie. 
; Registres modifi�s: aucun
;******************************************************************************    

_Display:
			  push Acc
			  push dpl
			  push dph
			  
			  mov A, R5
			  mov dpl, R7
			  mov dph, R6
			  mov R7, A
			  movx @dptr, A
			  jnz set_LED
			  jmp not_set_LED
set_LED: 
			  setb P1.6
not_set_LED:
			  pop dph
			  pop dpl
			  pop Acc
              RET
			  

;****************************************************************************** 

;******************************************************************************                
; _Test_Code  
;
; Description: 
;
; Param�tres d'entr�e:  R6 (MSB)- R7 (LSB) � Adresse de Tab_code
; Param�tre d�entr�e :  R5  � Code � v�rifier (sur 6 bits)
; Valeur retourn�e: R7 : non nul, il retourne la position du code trouv� dans la table,
;                        nul, il indique que le code n�a pas �t� trouv� dans la table.
; Registres modifi�s: aucun
;******************************************************************************    

_Test_Code:
              push Acc
			  push dph
			  push dpl
			  push B
			  
			  mov dph, R6
			  mov dpl, R7
			  mov B, #00h
			  mov A, #00h
boucle_code:
			  inc B
			  movc A, @A+dptr
			  cjne A, AR5 , incrementation_code
			  mov A,B
			  mov R7, A
			  jmp fin_code
incrementation_code:
			  mov A,B
			  cjne A, #10h, boucle_code
			  mov R7, #00h
fin_code:
			  pop B
			  pop dpl
			  pop dph
			  pop Acc
              RET
;****************************************************************************** 

;******************************************************************************                
; _Stockage_Code 
;
; Description: 
;
; Param�tres d'entr�e:  R6 (MSB)- R7 (LSB) � Adresse de Tab_histo
; Param�tre d�entr�e :  R5 � Code � enregistrer
; Valeur retourn�e: R7 : non nul, il retourne le nombre d�enregistrements,
;                             nul, il indique que la table est pleine (100 enregistrements). 
; Registres modifi�s: aucun
;******************************************************************************    

_Stockage_Code:
				push Acc
				push dpl
				push dph
				
				
				mov dpl, R7
				mov dph, R6
				
				movx A, @dptr
				inc A
				cjne A, #04h, Bcl_incr_dptr2
				
				mov R7, #00h
				jmp fin_histo
				
			BCL_incr_dptr2:
				movx @dptr, A

				
			BCL_incr_dptr:
				jnc fin_histo
				inc DPTR
				dec A
				jnz BCL_incr_dptr
				mov A,R5
				movx @dptr, A
				
			fin_histo:
				pop dph
				pop dpl
				pop Acc
				
				RET
				
;****************************************************************************** 


END



