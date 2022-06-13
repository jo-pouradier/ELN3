;******************************************************************************
;Lib_TP_SM.asm

;   Ce fichier contient des définitions et des routines utiles au TP SM4
;   Aucune modification n'est nécessaire.
;   Il suffit d'ajouter ce fichier à votre Projet
;   TARGET MCU  :  C8051F020 
;******************************************************************************
$INCLUDE(C8051F020.INC)	; Register definition file.
;******************************************************************************
;Declaration des variables et fonctions publiques
;******************************************************************************
PUBLIC   Config_Timer3_BT
PUBLIC   __tempo
PUBLIC   Init_pgm

;******************************************************************************
;Déclarations de périphériques

GREEN_LED      EQU       P1.6

;******************************************************************************
;Consignes de segmentation
;******************************************************************************
zone_data     segment  DATA
              rseg     zone_data
tampon:       ds       6

Lib_TP_SM     segment  CODE
			  rseg     Lib_TP_SM     ; Switch to this code segment.
              using    0             ; Specify register bank for the following
                                     ; program code.

;******************************************************************************
;Initialisations de la mémoire code - Stockage de constante
;******************************************************************************

;******************************************************************************
;Init_pgm
;
; Description: Initialisations de périphériques
;              Fonctionnalités Microcontroleur
;              Configuration accès mémoire sur P4,5,6 et 7
;              Acces en mode multiplexé.
;              Sorties en Push-Pull sauf pour P4 en Drain ouvert
;              

; Paramètres d'entrée: Aucun
; Paramètres de sortie: Aucun
; Registres modifiés: Beaucoup!!!  En fait les registres de config du
;                                  circuit 
;                                 
; Pile: 0 octet (sauf pour l'appel de la sous -routine)
;******************************************************************************
Init_pgm:
         mov WDTCN, #0DEh    ; Disable WDT
         mov WDTCN, #0ADh
; Configure the XBRn Registers
         mov XBR0, #004h     ; UART0 routée sur P0.0 et P0.1
         mov XBR1, #080h     ; Sysclock routée sur P0.2
         mov XBR2, #040h     ; Crossbar validé

; Port configuration (1 = Push Pull Output)
         mov P0MDOUT,#005h   ; Output configuration for P0 
         mov P1MDOUT,#0FFh   ; Output configuration for P1 - Tout en Push-Pull
         mov P2MDOUT,#000h   ; Output configuration for P2 
         mov P3MDOUT,#000h   ; Output configuration for P3 
		 orl P3,#80H         ; P3.7 en entrée pour gstion INT7
         mov P74OUT,#0FFh    ; P4, P5, P6 et P7 configurés en Push Pull
         mov P1MDIN,#0FFh    ; Pas d'entrée analogique sur P1
         mov P4,#0DFh        ; ALE à 0 en dehors des cycles mémoires

; Configure External Memory Configuration
         mov EMI0CF, #026h   ; External Memory Configuration Register
         mov EMI0TC, #0BAh   ; External Memory Configuration Register

; Oscillator Configuration
         mov OSCXCN, #067h   ; External Oscillator Control Register	
         clr A               ;osc
         djnz ACC, $         ;wait for
         djnz ACC, $         ;at least 1ms
OX_WAIT:
         mov A, OSCXCN
         jnb ACC.7, OX_WAIT  ;poll XTLVLD
         mov OSCICN, #008h   ; Internal Oscillator Control Register
                             ; On bascule sur l'oscillateur externe 
                             ; à 22118400            
         mov RSTSRC, #000h   ; Reset Source Register
         ret

;******************************************************************************
; Gestion du Timer 3
; Routines permettant de mettre en oeuvre le timer 3
;
;******************************************************************************

;******************************************************************************                
; Config_Timer3_BT
;
; Description: Sous-programme configurant le Timer3 pour fonctionner en
;              Re-chargement automatique. Le timer va générer un overflow 
;              toutes les ((65535-N) * 0.542) micro-secondes 
;              (Avec SYSCLK = 22,1184 MHz)
;          
;
; Paramètres d'entrée:  N dans R6(MSB) et R7(LSB)
; Paramètres de sortie: aucun
; Registres modifiés: TMR3RLL,TMR3RLH,TMR3H,TMR3L,TMR3CN
; Pile: 0 octet (sauf pour l'appel de la sous -routine)
;******************************************************************************
; ATTENTION!!!   Il est impératif de remettre à zéro, par programme, le 
;*************   Timer3 Overflow Flag.  
;******************************************************************************

Config_Timer3_BT:


         mov TMR3RLL, R7   ; Timer 3 Reload Register Low Byte
         mov TMR3RLH, R6   ; Timer 3 Reload Register High Byte
         mov TMR3H, R6     ; Timer 3 High Byte
         mov TMR3L, R7     ; Timer 3 Low Byte
         mov TMR3CN, #004h ; Timer 3 Control Register
		 orl EIE2,#00000001B ; Int Timer 3 validée
		 anl EIP2,#11111110B  ; Priorité basse sut INT Timer3
        ret

;******************************************************************************
;******************************************************************************
; __tempo
;
; Description: Sous-programme produisant une temporisation logicielle
;              paramétrable par la variable csg_tempo.
;              La temporisation générée est égale à csg_tempo micro-secondes.
;              ATTENTION: csg_tempo ne doit pas être inférieure à 2
;
; Paramètres d'entrée:  csg_tempo dans R6(MSB) et R7(LSB)
; Paramètres de sortie: aucun
; Registres modifiés: R6 et R7
; Pile: 2 octets 
;******************************************************************************
__tempo:
        PUSH  ACC
        MOV   A,R5
        PUSH  ACC
        MOV  A,R7
        DEC  R7
        JNZ   ?C0006
        DEC   R6
?C0006:
?C0001:
         MOV  A,R7
         ORL  A,R6
         JZ   ?C0005

         MOV  A,R7
         DEC  R7
         JNZ  ?C0007
         DEC  R6
?C0007:
         MOV  R5,#01H
?C0003:
         MOV  A,R5
         JZ   ?C0001
         DEC  R5
         SJMP ?C0003
?C0005:
         POP ACC
         MOV R5,ACC
         POP ACC
         RET  	
      
end