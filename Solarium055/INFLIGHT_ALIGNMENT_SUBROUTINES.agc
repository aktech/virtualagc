### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	INFLIGHT_ALIGNMENT_SUBROUTINES.agc
## Purpose:	Part of the source code for Solarium build 55. This
##		is for the Command Module's (CM) Apollo Guidance
##		Computer (AGC), for Apollo 6.
## Assembler:	yaYUL --block1
## Contact:	Jim Lawton <jim DOT lawton AT gmail DOT com>
## Website:	www.ibiblio.org/apollo/index.html
## Page Scans:	www.ibiblio.org/apollo/ScansForConversion/Solarium055/
## Mod history:	2009-10-04 JL	Created.

## Page 461

# CALCGTA		GIVEN THE DESIRED XD,YD AND ZD UNIT VECTORS REFERED TO
# ---------		PRESENT STABLE MEMBER ORIENTATION, THIS SUBROUTINE FINDS
#			THETAY, THETAZ, AND THETAX, THE REQUIRED GYRO TORQUE
#			ANGLES IN THE ORDER TO BE APPLIED TO BRING THE STABLE
#			MEMBER INTO THE DESIRED ORIENTATION.



		BANK	22
CALCGTA		ITA	1		# DEFINE THE VECTOR ZPRIME WHICH IS THE
		DMOVE
			S2		# IMAGE OF Z UNDER THE ROTATION ABOUT Y
			XDSMPR
		
		DMOVE	0		# ZPRIME =(-XD  ,0 , XD )
			ZERODP		#             2        0
		
		COMP	1
		VDEF	UNIT
			XDSMPR +4
		STORE	ZPRIME
		
		TSRT	0		# SET UP COSTH AND SINTH TO ENTER
			ZPRIME		#     ARCTRIG FOR COMPUTATION OF THETA-Y
			1
		STORE	SINTH
		
		TSRT	0
			ZPRIME +4D
			1
		STORE COSTH
		
		ITC	0
			ARCTRIG
		
		NOLOD	0
		STORE	IGC
		
		TSRT	0
			XDSMPR +2
			1
		STORE	SINTH
		
		DMP	0
			ZPRIME
			XDSMPR +4
		
		DMP	1
		DSU
			ZPRIME +4
## Page 462
			XDSMPR
		STORE	COSTH
		
		ITC	0
			ARCTRIG
		
		NOLOD	0
		STORE	MGC
		
		DOT	0
			ZPRIME
			ZDSMPR
		STORE	COSTH
		
		DOT	0
			ZPRIME
			YDSMPR
		STORE	SINTH
		
		ITC	0
			ARCTRIG
		
		NOLOD	0
		STORE	OGC
		
		ITCI	0
			S2

## Page 463

ARCTRIG		ABS	1		# GIVEN SINTH AND COSTH SCALED X1/4 FIND
		DSU	BMN		# THETA IN THE RANGE -PI TO +PI SCALED-
			SINTH		# TEMPORARY FOR SINTH		    XPI/2
			QTSN45		# CONSTANT=0.1768
			TRIG1
		
		TSLT	1
		ACOS	SIGN
			COSTH		# TEMPORARY FOR COSTH
			1
			SINTH		# TEMPORARY FOR SINTH
		STORE	THETA
		
		ITCQ	0		# RETURN TO MAIN PROGRAM
		
TRIG1		TSLT	1		# SINTH LESS THAN QTSN45
		ASIN
			SINTH		# TEMPORARY FOR SINTH
			1
		STORE	THETA
		
		BMN	0
			COSTH
			TRIG2
		
		DMOVE	1
		ITCQ
			THETA
TRIG2		SIGN	1		# COSTH NEGATIVE
		DSU
			HALFDP
			SINTH		# WITH ASIN
			THETA
		STORE	THETA
		
		ITCQ	0		# RETURN

## Page 464

#					  THIS PROGRAM COMPUTES SXT ANGLES SAC AND
#					  PAC IN HALF AND EIGHT REVOLUTIONS RESPEC
#					  GO IN WITH S1=BASE ADDRESS OF CDU'S

SMNB		ITA	1		# CHECK THAT NBSMBIT IS OFF,IF IT ISGO TO
		TEST	SWITCH		# NBSM1,OTHERWISE SWITCH IT OFF
			S2
			NBSMBIT
			SMNB1
			NBSMBIT
		
SMNB1		AXT,1	1		# NBSMBIT IS OFF
		AXT,2	ITC		# SET INDECES TO ROTATE X,Z ABOUT Y
			4
			0
			AXISROT		# DO AXIS ROTATION
		
		AXT,1	1		# SET INDECES TO ROTATE Y,X ABOUT Z
		AXT,2	ITC
			2
			4
			AXISROT		# DO AXIS ROTATION
		
		AXT,1	1		# SET INDECES TO ROTATE Z,Y ABOUT X
		AXT,2	ITC
			0
			2
			AXISROT		# DO AXIS ROTATION
		
		ITCI	0		# RETURN
			S2

## Page 465

NBSM		ITA	1
		TEST
			S2
			NBSMBIT
			NBSM1
		
NBSM2		AXT,1	1		# ROTATE Z,Y ABOUT X
		AXT,2	ITC
			0
			2
			AXISROT
		
		AXT,1	1		# ROTATE Y,X ABOUT Z
		AXT,2	ITC
			2
			4
			AXISROT
		
		AXT,1	1		# ROTATE X,Z ABOUT Y
		AXT,2	ITC
			4
			0
			AXISROT
		
		ITCI	0		# RETURN
			S2

NBSM1		SWITCH	1
		ITC
			NBSMBIT
			NBSM2

## Page 466

AXISROT		XSU,1	2		# ROTUINE FOR SINGLE AXIS ROTATIONS
		SMOVE*	RTB
		XAD,1			# REMARKS ARE FOR ROTATIONS Z,Y ABOUT X
			S1
			4,1		# INDEX1=0,INDEX2=2
			CDULOGIC	# ANGLES ARE STORED IN THE ORDER IGZ,MGA,
			S1
		STORE	30D		# OGA,SO WE PICK UP OGZ
		
ACCUROT		COS	0
			30D
		STORE	8D,1		# STORE COS(OGA) IN 8
		
		SIN	0
			30D
		STORE	10D,1		# STORE SIN(OGA) IN 10D
		
		DMP*	1
		TSLT
			10D,1
			VAC +4,2	# PUSH DOWN (VAC +2)SIN(OGA)
			1
		
		DMP*	1
		TSLT
			8D,1
			VAC +4,2	# PUSH DOWN (VAC +2)COS(OGA)
			1
		
		DMP*	2
		TSLT	TEST
		BDSU
			10D,1
			VAC +4,1
			1
			NBSMBIT
			AXISROT1
		STORE	VAC +4,2	# VAC+2=(VAC+2)COS(OGA)-(VAC+4)SIN(OGA)
		
		DMP*	1
		TSLT	DAD
			8D,1
			VAC +4,1
			1
		STORE	VAC +4,1	# VAC+4=(VAC+2)SIN(OGA)+(VAC+4)COS(OGA)
		
		VMOVE	1
		ITCQ
			VAC
## Page 467

AXISROT1	NOLOD	1		# TEST WAS 0 FOR SMNB
		DAD
		STORE	VAC +4,2	# VAC+2=(VAC+2)COS(OGA)+(VAC+4)SIN(OGA)
		
		DMP*	1
		TSLT	DSU
			8D,1
			VAC +4,1
			1
		STORE	VAC +4,1	# VAC+4=-(VAC+2)SIN(OGA)+(VAC+4)COS(OGA)
		
		VMOVE	1
		ITCQ
			VAC

## Page 468

CALCGA		VXV	1		# CALCULATE GIMBAL ANGLES GIVEN THE X,Y,Z-
		UNIT
			XNB
			YSM
		
		NOLOD	1
		DOT	ITA
			ZNB
			S2
		STORE	COSTH		# TEMPORARY FOR COSTH
		
		NOLOD	1
		DOT
			YNB
		STORE	SINTH
		
		ITC	0
			ARCTRIG
		
		NOLOD	0
		STORE	OGC
		
		DOT	2
		TSLT	BOV
		TSRT	ASIN
			YSM
			XNB
			2
			GIMLOCK1	# LOOK FOR EXCESIVE MGC
			1
		STORE	MGC
		
		ABS	1
		DSU	BPL
			MGC
			.333...
			GIMLOCK1

CALCGA1		DOT	0
			ZSM
			0		# CONTAINS AMG
		STORE	COSTH
		
		DOT	0
			XSM
		STORE	SINTH
		
		ITC	0
			ARCTRIG
## Page 469
		NOLOD	0
		STORE	IGC
		
		VMOVE	1		# OP COUNT BY UNEEDA DEBUGGING SERVICE INC
		RTB
			OGC
			V1STO2S
		STORE	THETAD		# *** BEWARE *** MODE IS NOW DP ***
		
		ITCI	0
			S2
		
GIMLOCK1	EXIT	0

		TC	ALARM
		OCT	00401
		TC	INTPRET		# RESUME ROUTINE.
		
		ITC	0
			CALCGA1

## Page 470

SXTNB		SMOVE*	1		# THIS PROGRAM COMPUTES COMPONENTS OF
		RTB	RTB		# THE STAR HALF UNIT VECTOR,STARM, GIVEN
			5,1		# THE MEASURED SXT ANGLES PAM AND SAM.
			CDULOGIC
			TRUNLOG
		
		NOLOD	1
		SIN	TSLT
			1		# STORE A=SIN(PAM.PI/4)
		
		SMOVE*	1
		RTB
			3,1
			CDULOGIC	# STORE  SAM/2 IN PD 4,RESOLVES +/- ZERO
		
		NOLOD	1
		COS	DMP
			2
		STORE	STARM		# STARM +0=(A.COS(PI.SAM))/2
		
		SIN	1		# SIN(2PI.PD4).PD2
		DMP
		STORE	STARM +2	# STARM +2=(A.SIN(PI.SAM))/2
		
		COS	0
		STORE	STARM +4	# STARM +4=0.5.COS(PAM.PI/4)
		
		ITCQ	0
		
## Page 471

# AXISGEN		GIVEN TWO STAR VECTORS     -         -
# -------		                       STARA AND STARB WRITTEN IN TWO
#			  COORDINATE SYSTEMS, THE D AND C SYSTEMS SO THAT WE
#			  HAVE       -       -           -       -
#			         STARA   STARB   AND STARB , STARA
#			              D       D           C       C
#			  THIS PROGRAM COMPUTES THE HALF UNIT AXES
#			          -   -   -
#			         XD  YD  ZD
#			           C   C   C
#			  THAT IS THE D COORDINATE SYSTEM AXES REFERRED TO THE C
#			  COORDINATE SYSTEM
#			THE INPUTS ARE STORED AS FOLLOWS
#			                                        -
#			         C(STARAD) - C(STARAD +5) = STARA
#			                                         D
#			                                        -
#			         C(STARAD+6)-C(STARAD+11D)= STARB
#			                                         D
#			                                        -
#			         C(6D) - C(11D)           = STARA
#			                                         C
#			                                        -
#			         C(12D) - C(17D)          = STARB
#			                                         C
#			RESULTS ARE LEFT IN XDC TO XDC +17D
#			  THE RETUTINE DESTROYS THE INPUTS AND USES LOCATIONS
#			     STARAD+12D TO STARAD+17D AND 18D - 23D +30D
AXISGEN		AXT,1	1
		AST,1
			STARAD +6
			STARAD -6
AXISGEN1	VXV*	1
		UNIT
			STARAD +12D,1
			STARAD +18D,1
		STORE	STARAD +18D,1
		
		VXV*	1
		VSLT
			STARAD +12D,1
			STARAD +18D,1
			1
		STORE	STARAD +24D,1
		
		TIX,1	0
			AXISGEN1
		
		AXC,1	3
		SXA,1	AXT,1
## Page 472
		AST,1	AXT,2
		AST,2
			6
			30D
			18D
			6
			6
			2
		
AXISGEN2	XCHX,1	0
			30D
		
		VXSC*	0
			0,1
			STARAD +6,2
		
		VXSC*	0
			6,1
			STARAD +12D,2
		STORE	24D
		
		VXSC*	2
		VAD	VAD
		VSLT	XCHX,1
			12D,1
			STARAD +18D,2
			-
			24D
			1
			30D
		STORE	XDC +18D,1
		
		TIX,1	0
			AXISGEN3

AXISGEN3	TIX,2	0
			AXISGEN2
		
		ITCQ	0

## Page 473

CALCSXA		VMOVE	1		# THIS PROGRAM COMPUTES THE SXT ANGLES SAC
		ITA	ITC		# AND PAC GIVEN THE STAR VECTOR IN SM AXES
			STAR
			S2		# HALF UNIT VECTOR
			SMNB
		
		NOLOD	0
		STORE	6		# STORE (STARM0,STARM1,STARM2)
		
		DMOVE	0
			ZERODP
		STORE	VAC +4		# SET VAC TO (STARM0,STARM1,0)
		
		NOLOD	1		# UNIT VAC TO (S0,S1,0)
		UNIT	TSRT
			2
		STORE	0		# STORE  COS/4 =S0/4 , SIN/4 = S1/4 ,0
		
		DMOVE	0
			0
			COSTH
		
		DMOVE	0
			2
			SINTH
		
		ITC	0
			ARCTRIG		# USES THE COS/SIN STORED ABOVE
		
		RTB	0
			1STO2S
		STORE	SAC
		
		DOT	3
		TSLT	ASIN
		TSLT	BOV
		BMN	RTB
			0		# 1/4 UNIT  (STARM0,STARM1,0)
			6		# STARM-1/2 UNIT VECTOR
			3
			3
			CALCSXA1
			CALCSXA1
			1STO2S
		STORE	PAC
		
		ITCI	0
			S2

CALCSXA1	EXIT	0		# PROGRAM ERROR,STAR OUT OF FIELD OF VIEW
## Page 474
		TC	ALARM
		OCT	00402
		TC	ENDOFJOB

## Page 475

SXTANG		VXV	1		# TIVELY FROM INPUTS STAR AND XNB,YNB,ZNB
		UNIT	VSRT		# THE HALF UNIT STAR VECOTR AND THE NAV
			ZNB		# BASE HALF AXES.
			STAR
			1
		STORE	PDA		# DEFINES PROJECTION OF STAR IN XY PLANE
		
		DOT	1
		COMP	ITA		# COMPUTE  SIN(PI.SAC)/4
			PDA
			XNB
			S2
		STORE	SINTH
		
		DOT	0		# COMPUTE  COS(PI.SAC)/4
			PDA
			YNB
		STORE	COSTH
		
		ITC	0		# COMPUTE SAC
			ARCTRIG
		
		RTB	0
			1STO2S
		STORE	SAC
		
		VXV	4
		DOT	TSLT
		ASIN	TSLT		# COMPUTE PAC
		BOV	BMN
		RTB
			PDA
			ZNB
			STAR
			2
			3
			SXTALARM
			SXTALARM	# WE NOW HAVE PRECISION ANGLE
			1STO2S
		STORE	PAC
		
		ITCI	0		# JOB IS DONE
			S2
		
SXTALARM	EXIT	0		# BRANCH TO RESTART SEQUENCE

		TC	ALARM
		OCT	00403
		TC	ENDOFJOB

## Page 476

QTSN45		2DEC	.1768
THIRD		2DEC	.167
ZPRIME		=	22D
PDA		=	22D
COSTH		=	16D
SINTH		=	18D
THETA		=	20D
STARM		=	VAC
ZERODP		2DEC	0
POSMAXDP	OCT	37777
		OCT	37777
HALFDP		2DEC	.5
.333...		2DEC	.3333333333
